#' Average and marginal return curves with current and optimal points
#'
#' Produces faceted average return (AR) and marginal return (MR) curves for
#' each channel, with points marking the current and optimal spend positions.
#'
#' @param x An `opt_mix_result` object returned by [opt_mix()].
#' @param ... Additional arguments (currently unused).
#' @return A ggplot object.
#' @import ggplot2
#' @importFrom rlang .data
#' @export

opt_plot_returns <- function(x, ...) {

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
    s <- mrm$summary
    sol_row <- sol[sol$channel == ch, ]

    # AR and MR curves
    cdf <- data.frame(
      channel = ch,
      spend = rep(rdf[[x_col]], 2),
      value = c(rdf$ar, rdf$mr),
      metric = rep(c("AR", "MR"), each = nrow(rdf))
    )
    curve_dfs[[ch]] <- cdf

    # AR/MR at optimal
    opt_m <- hlpr_opt_metrics(mrm, sol_row$weekly_spend)

    point_dfs[[ch]] <- data.frame(
      channel = ch,
      spend = rep(c(s$weekly_spend, sol_row$weekly_spend), each = 2),
      value = c(s$ar_at_current, s$mr_at_current, opt_m$ar, opt_m$mr),
      metric = rep(c("AR", "MR"), 2),
      point_type = rep(c("Current", "Optimal"), each = 2)
    )
  }

  curves <- do.call(rbind, curve_dfs)
  points <- do.call(rbind, point_dfs)

  ggplot(curves, aes(x = .data$spend, y = .data$value, linetype = .data$metric)) +
    geom_line(linewidth = 0.5, na.rm = TRUE) +
    geom_point(
      data = points,
      aes(x = .data$spend, y = .data$value, color = .data$point_type, shape = .data$metric),
      size = 2.5
    ) +
    scale_color_manual(
      values = c("Current" = "firebrick", "Optimal" = "steelblue"),
      name = NULL
    ) +
    scale_linetype_manual(values = c("AR" = "solid", "MR" = "dashed"), name = NULL) +
    scale_shape_manual(values = c("AR" = 16, "MR" = 17), name = NULL) +
    scale_x_continuous(labels = scales::dollar_format()) +
    scale_y_continuous(labels = scales::comma_format()) +
    facet_wrap(~channel, scales = "free") +
    labs(
      x = "Weekly Spend",
      y = "Rate",
      title = "Average & Marginal Return: Current vs. Optimal"
    ) +
    theme_minimal() +
    theme(legend.position = "top")
}
