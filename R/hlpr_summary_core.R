# Internal helper: build a single-row mrm_summary tibble from an already-computed
# response data frame plus current-state inputs. This is the shared computational
# core of mrm_summary(); fit_response_hier()'s per-unit summaries reuse it so the
# range logic lives in exactly one place.
#
# rdf                response_df for ONE curve (x column first; center/ar/mr/cp)
# x_col              name of the x (spend) column in rdf
# rc_type            response curve type string
# weekly_spend       current weekly spend (scalar, raw units)
# obs_spend          vector of observed weekly spends (raw units) for week dist.
# has_units, cpu     whether units were supplied, and cost-per-unit
# params             list with b, c, d, e (center, original units)
# r2                 a 1-row tibble (Estimate/Q2.5/Q97.5) or NULL
# log_curve_no_peak  logical; monotonically-decreasing-MR (log) form
# mr_decay           fraction of peak MR for the standard-curve upper bound
# channel            channel/unit label
# params_full        optional list(center, lower, upper) for the params_summary attr

hlpr_summary_core <- function(rdf, x_col, rc_type,
                              weekly_spend, obs_spend,
                              has_units, cpu, params, r2,
                              log_curve_no_peak, mr_decay = 0.7,
                              channel = x_col, params_full = NULL) {

  weekly_units <- if (has_units) weekly_spend / cpu else NA_real_

  interp <- function(col, at) {
    stats::approx(rdf[[x_col]], rdf[[col]], xout = at, rule = 2)$y
  }

  kpi_at_current <- interp("center", weekly_spend)
  ar_at_current  <- interp("ar", weekly_spend)
  mr_at_current  <- interp("mr", weekly_spend)
  cp_at_current  <- interp("cp", weekly_spend)
  rr_at_current  <- if (has_units) kpi_at_current / weekly_units else NA_real_

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
    above_2x <- which(!is.na(rdf$mr) & rdf$mr >= 2 * mr_at_current)
    range_min_spend <- if (length(above_2x) > 0) {
      rdf[[x_col]][max(above_2x)]
    } else {
      rdf[[x_col]][2]
    }
    range_peak_spend <- weekly_spend
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

  n_weeks   <- length(obs_spend)
  pct_below <- mean(obs_spend < range_min_spend) * 100
  pct_in    <- mean(obs_spend >= range_min_spend & obs_spend <= range_max_spend) * 100
  pct_above <- mean(obs_spend > range_max_spend) * 100

  result <- tibble::tibble(
    channel          = channel,
    rc_type          = rc_type,

    weekly_spend     = weekly_spend,
    weekly_units     = weekly_units,
    kpi_at_current   = kpi_at_current,
    ar_at_current    = ar_at_current,
    mr_at_current    = mr_at_current,
    cp_at_current    = cp_at_current,
    rr_at_current    = rr_at_current,

    b = params$b, c = params$c, d = params$d, e = params$e,

    range_min_spend  = rmin$spend,
    range_min_units  = rmin$units,
    range_min_kpi    = rmin$kpi,
    range_min_cp     = rmin$cp,
    range_min_ar     = rmin$ar,
    range_min_mr     = rmin$mr,
    range_min_rr     = rmin$rr,

    range_peak_spend = rpeak$spend,
    range_peak_units = rpeak$units,
    range_peak_kpi   = rpeak$kpi,
    range_peak_cp    = rpeak$cp,
    range_peak_ar    = rpeak$ar,
    range_peak_mr    = rpeak$mr,
    range_peak_rr    = rpeak$rr,

    range_max_spend  = rmax$spend,
    range_max_units  = rmax$units,
    range_max_kpi    = rmax$kpi,
    range_max_cp     = rmax$cp,
    range_max_ar     = rmax$ar,
    range_max_mr     = rmax$mr,
    range_max_rr     = rmax$rr,

    n_weeks          = n_weeks,
    pct_weeks_below  = pct_below,
    pct_weeks_in     = pct_in,
    pct_weeks_above  = pct_above
  )

  attr(result, "params_summary")    <- params_full
  attr(result, "log_curve_no_peak") <- log_curve_no_peak
  attr(result, "R2")                <- r2
  class(result) <- c("mrm_summary", class(result))

  result
}
