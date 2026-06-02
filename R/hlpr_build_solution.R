#' Build the unified solution tibble for opt_mix
#'
#' Assembles current-state metrics, optimal allocations, units (assuming
#' static cost-per-unit), response rates, period totals, and shares into
#' a single tibble. Used by both point and posterior paths so they return
#' identically-structured output.
#'
#' @param channels Character vector of channel names.
#' @param mrms Named list of `mrmfit` objects (same order as `channels`).
#' @param weekly_spend Numeric vector of optimal weekly spend per channel.
#' @param weekly_kpi Numeric vector of optimal weekly KPI per channel.
#' @param weekly_spend_lower Numeric vector of 2.5\% quantile (or \code{NULL} for point estimate).
#' @param weekly_spend_upper Numeric vector of 97.5\% quantile (or \code{NULL}).
#' @param weekly_kpi_lower Numeric vector of 2.5\% quantile (or \code{NULL}).
#' @param weekly_kpi_upper Numeric vector of 97.5\% quantile (or \code{NULL}).
#' @param n_weeks Number of weeks the budget covers.
#' @return A tibble with current-state, optimal, period, and share columns.
#' @keywords internal

hlpr_build_solution <- function(
    channels,
    mrms,
    weekly_spend,
    weekly_kpi,
    weekly_spend_lower = NULL,
    weekly_spend_upper = NULL,
    weekly_kpi_lower = NULL,
    weekly_kpi_upper = NULL,
    n_weeks = 1
) {

  n <- length(channels)

  # --- Current-state metrics from summary ---
  current_weekly_spend <- vapply(mrms, function(m) m$summary$weekly_spend, numeric(1))
  current_weekly_kpi   <- vapply(mrms, function(m) m$summary$kpi_at_current, numeric(1))
  current_cost_per     <- vapply(mrms, function(m) m$summary$cp_at_current, numeric(1))

  current_weekly_units <- vapply(mrms, function(m) {
    wu <- m$summary$weekly_units
    if (is.null(wu) || is.na(wu)) NA_real_ else wu
  }, numeric(1))

  current_rr <- vapply(mrms, function(m) {
    rr <- m$summary$rr_at_current
    if (is.null(rr) || is.na(rr)) NA_real_ else rr
  }, numeric(1))

  # --- Cost per unit (for computing optimal units) ---
  cpu <- vapply(mrms, function(m) {
    v <- m$cost_per_unit
    if (is.null(v) || is.na(v)) NA_real_ else v
  }, numeric(1))

  has_units <- !all(is.na(cpu))

  # --- Optimal units (static CPU assumption) ---
  weekly_units       <- weekly_spend / cpu
  weekly_units_lower <- if (!is.null(weekly_spend_lower)) weekly_spend_lower / cpu else rep(NA_real_, n)
  weekly_units_upper <- if (!is.null(weekly_spend_upper)) weekly_spend_upper / cpu else rep(NA_real_, n)

  # --- Derived metrics ---
  cost_per <- weekly_spend / weekly_kpi
  rr       <- ifelse(is.na(weekly_units), NA_real_, weekly_kpi / weekly_units)

  # --- CI columns (NA for point) ---
  wsl <- if (!is.null(weekly_spend_lower)) weekly_spend_lower else rep(NA_real_, n)
  wsu <- if (!is.null(weekly_spend_upper)) weekly_spend_upper else rep(NA_real_, n)
  wkl <- if (!is.null(weekly_kpi_lower))   weekly_kpi_lower   else rep(NA_real_, n)
  wku <- if (!is.null(weekly_kpi_upper))   weekly_kpi_upper   else rep(NA_real_, n)
  wul <- weekly_units_lower
  wuu <- weekly_units_upper

  # --- Shares ---
  current_spend_share <- current_weekly_spend / sum(current_weekly_spend, na.rm = TRUE)
  current_kpi_share   <- current_weekly_kpi / sum(current_weekly_kpi, na.rm = TRUE)
  spend_share         <- weekly_spend / sum(weekly_spend)
  kpi_share           <- weekly_kpi / sum(weekly_kpi)

  # --- Assemble tibble ---
  dplyr::arrange(
    tibble::tibble(
    channel = channels,

    # Current state
    current_weekly_spend = current_weekly_spend,
    current_weekly_units = current_weekly_units,
    current_weekly_kpi   = current_weekly_kpi,
    current_cost_per     = current_cost_per,
    current_rr           = current_rr,
    current_spend_share  = current_spend_share,
    current_kpi_share    = current_kpi_share,

    # Optimal state
    weekly_spend       = weekly_spend,
    weekly_spend_lower = wsl,
    weekly_spend_upper = wsu,
    weekly_kpi         = weekly_kpi,
    weekly_kpi_lower   = wkl,
    weekly_kpi_upper   = wku,
    weekly_units       = weekly_units,
    weekly_units_lower = wul,
    weekly_units_upper = wuu,
    cost_per           = cost_per,
    rr                 = rr,

    # Period totals
    period_spend = weekly_spend * n_weeks,
    period_kpi   = weekly_kpi * n_weeks,
    period_units = weekly_units * n_weeks,

    # Shares
    spend_share = spend_share,
    kpi_share   = kpi_share
    ), cost_per)
}

