#' Posterior distribution of optimal spend allocation
#'
#' Produces a violin + boxplot showing the distribution of optimal spend per
#' channel across posterior draws. Only available for results from
#' `method = "posterior"`.
#'
#' @param x An `opt_mix_result` object returned by [opt_mix()] with
#'   `method = "posterior"`.
#' @param ... Additional arguments (currently unused).
#' @return A ggplot object.
#' @import ggplot2
#' @importFrom tidyr pivot_longer
#' @importFrom rlang .data
#' @export

opt_plot_posterior <- function(x, ...) {

  if (!inherits(x, "opt_mix_result")) {
    stop("`x` must be an opt_mix_result object returned by opt_mix().")
  }

  if (x$method != "posterior") {
    stop(
      "opt_plot_posterior() requires a posterior method result. ",
      "Use opt_plot_allocation() for point method results."
    )
  }

  draws_df <- as.data.frame(x$draws_matrix)
  draws_long <- tidyr::pivot_longer(
    draws_df,
    cols = tidyr::everything(),
    names_to = "channel",
    values_to = "spend"
  )

  # Order by median
  medians <- apply(x$draws_matrix, 2, stats::median)
  ch_order <- names(sort(medians, decreasing = TRUE))
  draws_long$channel <- factor(draws_long$channel, levels = ch_order)

  ggplot(draws_long, aes(x = .data$channel, y = .data$spend)) +
    geom_violin(fill = "steelblue", alpha = 0.3) +
    geom_boxplot(width = 0.15, outlier.size = 0.5) +
    scale_y_continuous(labels = scales::comma_format()) +
    labs(
      x = NULL,
      y = "Weekly Spend ($)",
      title = "Posterior Distribution of Optimal Allocation",
      subtitle = paste0(x$n_draws, " draws")
    ) +
    coord_flip() +
    theme_minimal()
}
