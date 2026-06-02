#' Compare two opt_mix_result objects side by side
#'
#' Creates a tidy tibble showing how two optimization results differ per
#' channel. Useful for comparing point vs. posterior methods, different budgets,
#' or different constraint scenarios.
#'
#' @param a An `opt_mix_result` object (labeled as the first result).
#' @param b An `opt_mix_result` object (labeled as the second result).
#' @param labels Character vector of length 2 giving labels for each result.
#'   Defaults to `c("a", "b")` or the method names if both are `opt_mix_result`
#'   objects with different methods.
#' @return A tibble with one row per channel, showing spend/KPI/CP from each
#'   result and the deltas between them.
#' @importFrom rlang :=
#' @export

compare <- function(a, b, labels = NULL) {
  UseMethod("compare")
}

#' @rdname compare
#' @export
compare.opt_mix_result <- function(a, b, labels = NULL) {

  if (!inherits(b, "opt_mix_result")) {
    stop("`b` must be an opt_mix_result object.")
  }

  # Auto-generate labels
  if (is.null(labels)) {
    if (a$method != b$method) {
      labels <- c(a$method, b$method)
    } else {
      labels <- c("a", "b")
    }
  }
  if (length(labels) != 2) stop("`labels` must be length 2.")

  sa <- a$solution
  sb <- b$solution

  # Align by channel — both must have the same channels
  if (!setequal(sa$channel, sb$channel)) {
    warning("Channel sets differ; comparing only shared channels.")
    shared <- intersect(sa$channel, sb$channel)
    sa <- sa[sa$channel %in% shared, ]
    sb <- sb[sb$channel %in% shared, ]
  }

  # Reorder b to match a's channel order
  sb <- sb[match(sa$channel, sb$channel), ]

  spend_a <- paste0("spend_", labels[1])
  spend_b <- paste0("spend_", labels[2])
  kpi_a   <- paste0("kpi_", labels[1])
  kpi_b   <- paste0("kpi_", labels[2])
  cp_a    <- paste0("cp_", labels[1])
  cp_b    <- paste0("cp_", labels[2])
  share_a <- paste0("share_", labels[1])
  share_b <- paste0("share_", labels[2])

  result <- tibble::tibble(
    channel = sa$channel,
    current_spend = sa$current_weekly_spend,
    !!spend_a := sa$weekly_spend,
    !!spend_b := sb$weekly_spend,
    spend_diff = sb$weekly_spend - sa$weekly_spend,
    spend_diff_pct = (sb$weekly_spend / sa$weekly_spend) - 1,

    current_kpi = sa$current_weekly_kpi,
    !!kpi_a := sa$weekly_kpi,
    !!kpi_b := sb$weekly_kpi,
    kpi_diff = sb$weekly_kpi - sa$weekly_kpi,
    kpi_diff_pct = (sb$weekly_kpi / sa$weekly_kpi) - 1,

    !!cp_a := sa$cost_per,
    !!cp_b := sb$cost_per,
    cp_diff = sb$cost_per - sa$cost_per,

    !!share_a := sa$spend_share,
    !!share_b := sb$spend_share,
    share_diff = sb$spend_share - sa$spend_share
  )

  # Totals row
  totals <- tibble::tibble(
    channel = "TOTAL",
    current_spend = sum(sa$current_weekly_spend),
    !!spend_a := sum(sa$weekly_spend),
    !!spend_b := sum(sb$weekly_spend),
    spend_diff = sum(sb$weekly_spend) - sum(sa$weekly_spend),
    spend_diff_pct = (sum(sb$weekly_spend) / sum(sa$weekly_spend)) - 1,
    current_kpi = sum(sa$current_weekly_kpi),
    !!kpi_a := sum(sa$weekly_kpi),
    !!kpi_b := sum(sb$weekly_kpi),
    kpi_diff = sum(sb$weekly_kpi) - sum(sa$weekly_kpi),
    kpi_diff_pct = (sum(sb$weekly_kpi) / sum(sa$weekly_kpi)) - 1,
    !!cp_a := sum(sa$weekly_spend) / sum(sa$weekly_kpi),
    !!cp_b := sum(sb$weekly_spend) / sum(sb$weekly_kpi),
    cp_diff = .data[[cp_b]] - .data[[cp_a]],
    !!share_a := 1,
    !!share_b := 1,
    share_diff = 0
  )

  result <- dplyr::bind_rows(result, totals)

  attr(result, "labels") <- labels
  attr(result, "methods") <- c(a$method, b$method)
  attr(result, "budgets") <- c(a$budget_info$weekly_budget, b$budget_info$weekly_budget)

  class(result) <- c("opt_mix_compare", class(result))
  result
}
