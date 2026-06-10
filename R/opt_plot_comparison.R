#' Dumbbell chart of spend reallocation
#'
#' Produces a dumbbell/segment chart showing the shift from current to optimal
#' weekly spend per channel.
#'
#' @param x An `opt_mix_result` object returned by [opt_mix()].
#' @param ... Additional arguments (currently unused).
#' @return A ggplot object.
#' @import ggplot2
#' @importFrom rlang .data
#' @export

opt_plot_comparison <- function(x, ...) {

  if (!inherits(x, "opt_mix_result")) {
    stop("`x` must be an opt_mix_result object returned by opt_mix().")
  }

  sol <- x$solution

  # Order by magnitude of change
  sol$change <- sol$weekly_spend - sol$current_weekly_spend
  ch_order <- sol$channel[order(sol$change)]
  sol$channel <- factor(sol$channel, levels = ch_order)

  ggplot(sol, aes(y = .data$channel)) +
    geom_segment(
      aes(x = .data$current_weekly_spend, xend = .data$weekly_spend,
          yend = .data$channel),
      linewidth = 0.8, color = "grey50"
    ) +
    geom_point(aes(x = .data$current_weekly_spend), color = "firebrick", size = 3) +
    geom_point(aes(x = .data$weekly_spend), color = "steelblue", size = 3) +
    scale_x_continuous(labels = scales::comma_format()) +
    labs(
      x = "Weekly Spend ($)",
      y = NULL,
      title = "Spend Reallocation: Current \u2192 Optimal",
      subtitle = "Red = current  |  Blue = optimal"
    ) +
    theme_minimal()
}
