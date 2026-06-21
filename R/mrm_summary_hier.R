#' Per-unit, per-level, and channel summary from a hierarchical fit
#'
#' The hierarchical counterpart to \code{\link{mrm_summary}}. Produces a tibble
#' with one row per unit at every level of the hierarchy plus a channel-level
#' row, each summarising current performance, fitted curve parameters, and the
#' recommended spend range. Rows are built with the same computational core as
#' \code{\link{mrm_summary}} (\code{hlpr_summary_core}), so the columns match
#' the single-fit summary, with two extra leading columns: \code{id} and
#' \code{level}.
#'
#' @param mrm A fitted \code{mrmfit_hier} object from
#'   \code{\link{fit_response_hier}}.
#' @param mr_decay Fraction of peak MR used to define the upper bound of the
#'   response range (standard curves). Default 0.7.
#' @return A tibble of class \code{mrm_summary_hier}.
#'
#' @seealso \code{\link{mrm_summary}}, \code{\link{mrm_infer_hier}}
#' @export

mrm_summary_hier <- function(mrm, mr_decay = 0.7) {

  if (!inherits(mrm, "mrmfit_hier")) {
    stop("mrm must be a fitted model object created by fit_response_hier()",
         call. = FALSE)
  }

  rdf_all <- if (!is.null(mrm$response_df)) mrm$response_df else mrm_infer_hier(mrm)
  x_col   <- names(rdf_all)[1]

  rc_type <- mrm$rc_type
  log_forms <- c("log_logistic", "weibull", "reflected_weibull")
  log_curve_no_peak <- !is.null(rc_type) && rc_type %in% log_forms

  has_units <- !is.null(mrm$units_col) && !is.null(mrm$cost_per_unit)
  cpu <- if (has_units) mrm$cost_per_unit else NA_real_

  ph         <- hlpr_params_hier(mrm, scaled = !is.null(mrm$scale_values))
  group_cols <- mrm$group
  L          <- length(group_cols)
  term_name  <- function(i) paste(group_cols[seq_len(i)], collapse = ":")

  # --- Observed spend (raw) and per-level labels on the fit data ---
  rc_data    <- mrm$data
  sv         <- mrm$scale_values
  x_offset   <- if (!is.null(sv) && !is.null(sv$x_offset)) sv$x_offset else 0
  x_data_col <- setdiff(names(rc_data),
                        c(mrm$formula$resp, group_cols,
                          grep(":", names(rc_data), value = TRUE)))[1]
  unscale_obs <- function(xs) {
    if (is.null(sv)) return(xs)
    if (!is.null(sv$x_min) && !is.null(sv$x_max)) {
      xs * (sv$x_max - sv$x_min) + sv$x_min - x_offset
    } else if (!is.null(sv$x_mean) && !is.null(sv$x_sd)) {
      xs * sv$x_sd + sv$x_mean - x_offset
    } else xs
  }
  obs_spend_all <- unscale_obs(rc_data[[x_data_col]])
  data_label <- function(i) {
    if (i == 1) as.character(rc_data[[group_cols[1]]])
    else apply(rc_data[, group_cols[seq_len(i)], drop = FALSE], 1,
               function(r) paste(as.character(r), collapse = "_"))
  }

  build_row <- function(id, level, rdf, obs_spend, params, r2) {
    s <- hlpr_summary_core(
      rdf = rdf, x_col = x_col, rc_type = rc_type,
      weekly_spend = mean(obs_spend), obs_spend = obs_spend,
      has_units = has_units, cpu = cpu,
      params = as.list(params), r2 = r2,
      log_curve_no_peak = log_curve_no_peak, mr_decay = mr_decay,
      channel = id
    )
    s <- tibble::as_tibble(s)
    tibble::add_column(s, id = id, level = level, .before = 1)
  }

  rows <- list()

  # --- Per-level unit rows ---
  for (i in seq_len(L)) {
    tnm      <- term_name(i)
    unit_tbl <- ph$levels[[tnm]]
    lab_data <- data_label(i)
    for (k in seq_len(nrow(unit_tbl))) {
      id   <- unit_tbl$id[k]
      rdf  <- rdf_all[rdf_all$id == id & rdf_all$level == tnm, , drop = FALSE]
      obs  <- obs_spend_all[lab_data == id]
      prms <- list(b = unit_tbl$b[k], c = unit_tbl$c[k],
                   d = unit_tbl$d[k], e = unit_tbl$e[k])
      rows[[length(rows) + 1]] <- build_row(id, tnm, rdf, obs, prms, r2 = NULL)
    }
  }

  # --- Channel-level row ---
  chan_rdf <- rdf_all[rdf_all$id == "(channel)", , drop = FALSE]
  if (nrow(chan_rdf) > 0) {
    rows[[length(rows) + 1]] <- build_row(
      "(channel)", "channel", chan_rdf, obs_spend_all,
      params = ph$channel$center, r2 = mrm$R2)
  }

  out <- do.call(rbind, rows)
  class(out) <- c("mrm_summary_hier", class(tibble::tibble()))
  out
}
