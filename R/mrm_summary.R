#' Generate a channel-level summary from a fitted response model
#'
#' This function produces a single-row tibble summarising the current
#' performance, fitted response-curve parameters, analytically important points
#' on the curve, and the distribution of observed weeks relative to those points.
#'
#' @param mrm A fitted model object returned by \code{\link{fit_response}}.
#' @param mr_decay Fraction of peak MR used to define the upper bound of the
#'   response curve summary range (standard curves only). Default is 0.7.
#' @return A single-row tibble.
#'
#' @details
#' For standard (non-log) curves, the three summary points are:
#' \itemize{
#'   \item \strong{range_min}: Spend at peak marginal return (MR). Below this
#'     the channel is under-invested.
#'   \item \strong{range_peak}: Spend at peak absolute return (AR). This is
#'     the most efficient operating point.
#'   \item \strong{range_max}: Spend where MR has declined to
#'     \code{mr_decay × peak MR}. Beyond this, diminishing returns accelerate.
#' }
#'
#' For log-form curves (log_logistic, weibull, reflected_weibull) with
#' monotonically decreasing MR (i.e. no interior efficiency peak), the three
#' summary points are anchored to MR fractions around current spend:
#' \itemize{
#'   \item \strong{range_min}: Last spend level where MR >= 2x MR at current spend.
#'   \item \strong{range_peak}: Current spend (operational anchor).
#'   \item \strong{range_max}: First spend level above current where MR <= 0.5x MR at current spend.
#' }
#'
#' @export

mrm_summary <- function(mrm, mr_decay = 0.7) {

  if (!inherits(mrm, "mrmfit")) {
    stop("mrm must be a fitted model object created by fit_response()", call. = FALSE)
  }
  if (inherits(mrm, "mrmfit_hier_unit")) hlpr_unit_view_warn("mrm_summary")

  # --- Fresh inference (or use cached) ---
  rdf <- mrm_infer(mrm, scaled = TRUE)
  x_col <- names(rdf)[1]

  # --- Channel identity ---
  channel <- x_col
  rc_type <- mrm$rc_type

  # --- Current state ---
  weekly_spend <- hlpr_get_weekly_spend(mrm)
  has_units <- !is.null(mrm$units_col) && !is.null(mrm$cost_per_unit)
  cpu <- if (has_units) mrm$cost_per_unit else NA_real_

  # --- RC parameters ---
  params_full <- hlpr_params(mrm, scaled = TRUE)

  # --- Detect if curve is a log-form type (monotonically decreasing MR) ---
  log_forms <- c("log_logistic", "weibull", "reflected_weibull")
  log_curve_no_peak <- !is.null(rc_type) && rc_type %in% log_forms

  # --- Observed spend for week distribution ---
  rc_data <- mrm$data
  n_anchor <- if (!is.null(mrm$n_anchor_rows)) mrm$n_anchor_rows else 0L
  if (n_anchor > 0L) {
    rc_data <- rc_data[-seq_len(n_anchor), , drop = FALSE]
  }

  sv <- mrm$scale_values
  x_obs_col <- names(rc_data)[names(rc_data) != mrm$formula$resp]
  x_offset <- if (!is.null(sv$x_offset)) sv$x_offset else 0

  if (!is.null(sv$x_min) && !is.null(sv$x_max)) {
    obs_spend <- rc_data[[x_obs_col]] * (sv$x_max - sv$x_min) + sv$x_min - x_offset
  } else if (!is.null(sv$x_mean) && !is.null(sv$x_sd)) {
    obs_spend <- rc_data[[x_obs_col]] * sv$x_sd + sv$x_mean - x_offset
  } else {
    obs_spend <- rc_data[[x_obs_col]]
  }

  # --- Bayes R2 ---
  # Use pre-computed R2 if available on the fit object, otherwise compute now
  r2 <- if (!is.null(mrm$R2)) {
    mrm$R2
  } else {
    tryCatch(
      tibble::as_tibble(brms::bayes_R2(mrm)),
      error = function(e) NULL
    )
  }

  # --- Assemble via the shared core ---
  hlpr_summary_core(
    rdf = rdf, x_col = x_col, rc_type = rc_type,
    weekly_spend = weekly_spend, obs_spend = obs_spend,
    has_units = has_units, cpu = cpu,
    params = params_full$center, r2 = r2,
    log_curve_no_peak = log_curve_no_peak, mr_decay = mr_decay,
    channel = channel, params_full = params_full
  )
}


#' @export
print.mrm_summary <- function(x, ...) {
  # If not a single-row summary (e.g. result of bind_rows), fall back to
  # default tibble printing — the custom formatter requires exactly one row
  # and the attributes set by mrm_summary().
  if (nrow(x) != 1 || is.null(attr(x, "R2"))) {
    NextMethod()
    return(invisible(x))
  }

  s       <- x
  no_peak <- isTRUE(attr(x, "log_curve_no_peak"))
  r2      <- attr(x, "R2")
  has_units <- !is.na(s$weekly_units)

  dollar <- function(v) paste0("$", formatC(v, format = "f", big.mark = ",", digits = 0))
  comma  <- function(v) formatC(v, format = "f", big.mark = ",", digits = 0)
  pct    <- function(v) paste0(round(v, 1), "%")

  cat(cli_rule(paste0("Response Curve Summary: ", s$rc_type)), "\n")
  cat("Channel: ", s$channel, "\n", sep = "")
  cat("Weeks: ", s$n_weeks, sep = "")
  cat("\n")

  cat(cli_rule("Current Performance"), "\n")
  cat("Weekly Spend: ", dollar(s$weekly_spend), sep = "")
  if (has_units) cat("  |  Weekly Units: ", comma(s$weekly_units), sep = "")
  cat("\n")
  cat("KPI: ", comma(s$kpi_at_current),
      "  |  CP: ", dollar(s$cp_at_current),
      "  |  AR: ", round(s$ar_at_current, 4),
      "  |  MR: ", round(s$mr_at_current, 4), "\n", sep = "")

  cat(cli_rule("Parameters"), "\n")
  params <- list(
    list("b", "growth rate", s$b),
    list("c", "floor",       s$c),
    list("d", "ceiling",     s$d),
    list("e", "midpoint",    s$e)
  )
  for (p in params) {
    label <- paste0("  ", p[[1]], " (", p[[2]], "):")
    val <- p[[3]]
    if (p[[1]] == "e") {
      val_str <- dollar(val)
    } else if (p[[1]] %in% c("c", "d")) {
      val_str <- comma(val)
    } else {
      val_str <- formatC(val, format = "e", digits = 2)
    }
    cat(sprintf("%-22s %s\n", label, val_str))
  }

  if (no_peak) {
    cat(cli_rule("Response Curve Summary"), "\n")
    cat("  Note: MR declines monotonically \u2014 no interior efficiency peak.\n")
    cat("  Points anchored to \u00d72 and \u00d70.5 of MR at current spend.\n")
    range_line_mr <- function(label, spend, kpi, cp, mr) {
      cat(sprintf("  %-22s %s  ->  KPI: %s  |  CP: %s  |  MR: %s\n",
                  paste0(label, ":"),
                  dollar(spend), comma(kpi), dollar(cp), round(mr, 4)))
    }
    range_line_mr("2x Current MR",    s$range_min_spend,  s$range_min_kpi,  s$range_min_cp,  s$range_min_mr)
    range_line_mr("Current Spend",    s$range_peak_spend, s$range_peak_kpi, s$range_peak_cp, s$range_peak_mr)
    range_line_mr("0.5x Current MR",  s$range_max_spend,  s$range_max_kpi,  s$range_max_cp,  s$range_max_mr)
    cat("\n")
    cat(pct(s$pct_weeks_below), " of weeks in high-MR zone | ",
        pct(s$pct_weeks_in),    " near current | ",
        pct(s$pct_weeks_above), " in low-MR zone\n", sep = "")
  } else {
    cat(cli_rule("Response Curve Summary"), "\n")
    range_line_std <- function(label, spend, kpi, cp) {
      cat(sprintf("  %-18s %s  ->  KPI: %s  |  CP: %s\n",
                  paste0(label, ":"), dollar(spend), comma(kpi), dollar(cp)))
    }
    range_line_std("Min (peak MR)",  s$range_min_spend,  s$range_min_kpi,  s$range_min_cp)
    range_line_std("Peak (peak AR)", s$range_peak_spend, s$range_peak_kpi, s$range_peak_cp)
    range_line_std("Max (70% MR)",   s$range_max_spend,  s$range_max_kpi,  s$range_max_cp)
    cat("\n")
    cat(pct(s$pct_weeks_below), " of weeks below range | ",
        pct(s$pct_weeks_in),    " in range | ",
        pct(s$pct_weeks_above), " above range\n", sep = "")
  }

  cat(cli_rule("Bayes R2"), "\n")
  if (!is.null(r2)) {
    cat(sprintf("  R2: %.4f (95%% CI: [%.4f, %.4f])\n",
                r2$Estimate, r2$Q2.5, r2$Q97.5))
  } else {
    cat("  R2 not available.\n")
  }

  invisible(x)
}
