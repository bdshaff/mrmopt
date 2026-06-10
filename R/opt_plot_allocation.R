#' Plot current vs. optimal spend or KPI allocation
#'
#' Produces a grouped bar chart comparing current and optimal weekly spend
#' (or KPI) per channel. For posterior method results, 95% CI error bars
#' are added to the optimal bars.
#'
#' @param x An `opt_mix_result` object returned by [opt_mix()].
#' @param metric Character; `"spend"` (default) or `"kpi"`.
#' @param ... Additional arguments (currently unused).
#' @return A ggplot object.
#' @import ggplot2
#' @importFrom tidyr pivot_longer
#' @importFrom rlang .data
#' @export

opt_plot_allocation <- function(x, metric = c("spend", "kpi"), ...) {

  if (!inherits(x, "opt_mix_result")) {
    stop("`x` must be an opt_mix_result object returned by opt_mix().")
  }

  metric <- match.arg(metric)
  sol <- x$solution
  is_posterior <- x$method == "posterior"

  if (metric == "spend") {
    current_col <- "current_weekly_spend"
    optimal_col <- "weekly_spend"
    lower_col <- "weekly_spend_lower"
    upper_col <- "weekly_spend_upper"
    y_label <- "Weekly Spend ($)"
    title <- "Current vs. Optimal Spend Allocation"
  } else {
    current_col <- "current_weekly_kpi"
    optimal_col <- "weekly_kpi"
    lower_col <- "weekly_kpi_lower"
    upper_col <- "weekly_kpi_upper"
    y_label <- "Weekly KPI"
    title <- "Current vs. Optimal KPI"
  }

  plot_df <- tidyr::pivot_longer(
    sol[, c("channel", current_col, optimal_col)],
    cols = -channel,
    names_to = "type",
    values_to = "value"
  )
  plot_df$type <- ifelse(
    grepl("current", plot_df$type), "Current", "Optimal"
  )
  # Order channels by optimal value descending
  ch_order <- sol$channel[order(sol[[optimal_col]], decreasing = TRUE)]
  plot_df$channel <- factor(plot_df$channel, levels = ch_order)

  p <- ggplot(plot_df, aes(x = .data$channel, y = .data$value, fill = .data$type)) +
    geom_col(position = position_dodge(width = 0.7), width = 0.6) +
    scale_y_continuous(labels = scales::comma_format()) +
    labs(x = NULL, y = y_label, title = title, fill = NULL) +
    coord_flip() +
    theme_minimal() +
    theme(legend.position = "top")

  # Add error bars for posterior
  if (is_posterior && !all(is.na(sol[[lower_col]]))) {
    err_df <- data.frame(
      channel = factor(sol$channel, levels = ch_order),
      type = "Optimal",
      value = sol[[optimal_col]],
      lower = sol[[lower_col]],
      upper = sol[[upper_col]]
    )
    p <- p + geom_errorbar(
      data = err_df,
      aes(ymin = .data$lower, ymax = .data$upper),
      position = position_dodge(width = 0.7),
      width = 0.2
    )
  }

  p
}
