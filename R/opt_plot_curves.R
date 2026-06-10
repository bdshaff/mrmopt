#' Response curves with current and optimal spend points
#'
#' Produces faceted response curves for each channel with points marking
#' the current and optimal weekly spend positions.
#'
#' @param x An `opt_mix_result` object returned by [opt_mix()].
#' @param ... Additional arguments (currently unused).
#' @return A ggplot object.
#' @import ggplot2
#' @importFrom rlang .data
#' @export

opt_plot_curves <- function(x, ...) {

  if (!inherits(x, "opt_mix_result")) {
    stop("`x` must be an opt_mix_result object returned by opt_mix().")
  }

  if (is.null(x$mrms)) {
    stop("Models (mrms) not stored on result. Re-run opt_mix() with the current package version.")
  }

  sol <- x$solution
  mrms <- x$mrms

  curve_dfs <- list()
  point_dfs <- list()

  for (ch in names(mrms)) {
    mrm <- mrms[[ch]]
    rdf <- mrm$response_df
    x_col <- names(rdf)[1]

    cdf <- data.frame(
      channel = ch,
      spend = rdf[[x_col]],
      kpi = rdf$center,
      lower = rdf$lower,
      upper = rdf$upper
    )
    curve_dfs[[ch]] <- cdf

    # Current and optimal points
    sol_row <- sol[sol$channel == ch, ]
    opt_kpi <- hlpr_opt_metrics(mrm, sol_row$weekly_spend)$kpi

    point_dfs[[ch]] <- data.frame(
      channel = ch,
      spend = c(sol_row$current_weekly_spend, sol_row$weekly_spend),
      kpi = c(sol_row$current_weekly_kpi, opt_kpi),
      point_type = c("Current", "Optimal")
    )
  }

  curves <- do.call(rbind, curve_dfs)
  points <- do.call(rbind, point_dfs)

  ggplot(curves, aes(x = .data$spend, y = .data$kpi)) +
    geom_ribbon(aes(ymin = .data$lower, ymax = .data$upper), alpha = 0.2) +
    geom_line(linewidth = 0.6) +
    geom_point(
      data = points,
      aes(x = .data$spend, y = .data$kpi, color = .data$point_type),
      size = 3
    ) +
    scale_color_manual(
      values = c("Current" = "firebrick", "Optimal" = "steelblue"),
      name = NULL
    ) +
    scale_x_continuous(labels = scales::dollar_format()) +
    scale_y_continuous(labels = scales::comma_format()) +
    facet_wrap(~channel, scales = "free") +
    labs(
      x = "Weekly Spend",
      y = "Weekly KPI",
      title = "Response Curves: Current vs. Optimal Spend"
    ) +
    theme_minimal() +
    theme(legend.position = "top")
}
