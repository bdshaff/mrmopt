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

  weekly_units <- if (has_units) weekly_spend / cpu else NA_real_

  # Interpolate response_df at current spend
  interp <- function(col, at) {
    stats::approx(rdf[[x_col]], rdf[[col]], xout = at, rule = 2)$y
  }

  kpi_at_current <- interp("center", weekly_spend)
  ar_at_current  <- interp("ar", weekly_spend)
  mr_at_current  <- interp("mr", weekly_spend)
  cp_at_current  <- interp("cp", weekly_spend)
  rr_at_current  <- if (has_units) kpi_at_current / weekly_units else NA_real_

  # --- RC parameters ---
  params <- hlpr_params(mrm, scaled = TRUE)$center

  # --- Detect if curve is a log-form type (monotonically decreasing MR) ---
  log_forms <- c("log_logistic", "weibull", "reflected_weibull")
  log_curve_no_peak <- !is.null(rc_type) && rc_type %in% log_forms

  # --- Helper: metrics at a spend level ---
  metrics_at <- function(spend) {
    kpi <- interp("center", spend)
    units_val <- if (has_units) spend / cpu else NA_real_
    cp_val <- if (kpi > 0) spend / kpi else NA_real_
    ar_val <- interp("ar", spend)
    mr_val <- interp("mr", spend)
    rr_val <- if (has_units && units_val > 0) kpi / units_val else NA_real_
    list(spend = spend, units = units_val, kpi = kpi,
         cp = cp_val, ar = ar_val, mr = mr_val, rr = rr_val)
  }

  if (!log_curve_no_peak) {
    # --- Standard range: peak MR / peak AR / MR decay threshold ---

    peak_mr_idx      <- which.max(rdf$mr)
    range_min_spend  <- rdf[[x_col]][peak_mr_idx]

    peak_ar_idx      <- which.max(rdf$ar)
    range_peak_spend <- rdf[[x_col]][peak_ar_idx]

    peak_mr_val <- rdf$mr[peak_mr_idx]
    threshold   <- mr_decay * peak_mr_val
    tail_rdf    <- rdf[peak_mr_idx:nrow(rdf), ]
    decay_idx   <- which(tail_rdf$mr <= threshold)[1]
    range_max_spend <- if (is.na(decay_idx)) {
      max(rdf[[x_col]], na.rm = TRUE)
    } else {
      tail_rdf[[x_col]][decay_idx]
    }

  } else {
    # --- Log-form range: MR fractions around current spend ---

    # range_min: last spend where MR >= 2x MR at current spend
    above_2x <- which(!is.na(rdf$mr) & rdf$mr >= 2 * mr_at_current)
    range_min_spend <- if (length(above_2x) > 0) {
      rdf[[x_col]][max(above_2x)]
    } else {
      rdf[[x_col]][2]
    }

    # range_peak: current spend (operational anchor)
    range_peak_spend <- weekly_spend

    # range_max: first spend above current where MR <= 0.5x MR at current spend
    below_half <- which(rdf[[x_col]] > weekly_spend &
                          !is.na(rdf$mr) &
                          rdf$mr <= 0.5 * mr_at_current)
    range_max_spend <- if (length(below_half) > 0) {
      rdf[[x_col]][below_half[1]]
    } else {
      max(rdf[[x_col]], na.rm = TRUE)
    }
  }

  rmin  <- metrics_at(range_min_spend)
  rpeak <- metrics_at(range_peak_spend)
  rmax  <- metrics_at(range_max_spend)

  # --- Week distribution ---
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

  n_weeks   <- length(obs_spend)
  pct_below <- mean(obs_spend < range_min_spend) * 100
  pct_in    <- mean(obs_spend >= range_min_spend & obs_spend <= range_max_spend) * 100
  pct_above <- mean(obs_spend > range_max_spend) * 100

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

  # --- Assemble tibble ---
  result <- tibble::tibble(
    channel          = channel,
    rc_type          = rc_type,

    # Current state
    weekly_spend     = weekly_spend,
    weekly_units     = weekly_units,
    kpi_at_current   = kpi_at_current,
    ar_at_current    = ar_at_current,
    mr_at_current    = mr_at_current,
    cp_at_current    = cp_at_current,
    rr_at_current    = rr_at_current,

    # RC parameters
    b = params$b, c = params$c, d = params$d, e = params$e,

    # Range — min
    range_min_spend  = rmin$spend,
    range_min_units  = rmin$units,
    range_min_kpi    = rmin$kpi,
    range_min_cp     = rmin$cp,
    range_min_ar     = rmin$ar,
    range_min_mr     = rmin$mr,
    range_min_rr     = rmin$rr,

    # Range — peak
    range_peak_spend = rpeak$spend,
    range_peak_units = rpeak$units,
    range_peak_kpi   = rpeak$kpi,
    range_peak_cp    = rpeak$cp,
    range_peak_ar    = rpeak$ar,
    range_peak_mr    = rpeak$mr,
    range_peak_rr    = rpeak$rr,

    # Range — max
    range_max_spend  = rmax$spend,
    range_max_units  = rmax$units,
    range_max_kpi    = rmax$kpi,
    range_max_cp     = rmax$cp,
    range_max_ar     = rmax$ar,
    range_max_mr     = rmax$mr,
    range_max_rr     = rmax$rr,

    # Week distribution
    n_weeks          = n_weeks,
    pct_weeks_below  = pct_below,
    pct_weeks_in     = pct_in,
    pct_weeks_above  = pct_above
  )

  attr(result, "params_summary")    <- hlpr_params(mrm, scaled = TRUE)
  attr(result, "log_curve_no_peak") <- log_curve_no_peak
  attr(result, "R2")                <- r2
  class(result) <- c("mrm_summary", class(result))

  result
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
