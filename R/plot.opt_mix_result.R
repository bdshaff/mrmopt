#' Plot method for opt_mix_result objects
#'
#' Produces visualizations of the optimization result.
#'
#' @param x An `opt_mix_result` object returned by [opt_mix()].
#' @param type Character; one of `"allocation"`, `"kpi"`, `"comparison"`,
#'   `"posterior"`, `"curves"`, or `"returns"`. Defaults to `"allocation"`.
#'   \itemize{
#'     \item `"allocation"`: Grouped bar chart comparing current vs. optimal
#'       weekly spend. For posterior results, includes 95\% CI error bars.
#'     \item `"kpi"`: Same as allocation but for KPI values.
#'     \item `"comparison"`: Dumbbell/segment chart showing current to optimal
#'       spend shift per channel.
#'     \item `"posterior"`: Violin + boxplot of spend distributions from
#'       posterior draws. Only available when method = `"posterior"`;
#'       falls back to `"allocation"` for point results.
#'     \item `"curves"`: Response curves with current and optimal spend points.
#'     \item `"returns"`: Average and marginal return curves with current and
#'       optimal points.
#'   }
#' @param ... Additional arguments (currently unused).
#' @return A ggplot object.
#' @import ggplot2
#' @importFrom tidyr pivot_longer
#' @importFrom rlang .data
#' @export

plot.opt_mix_result <- function(x,
                                type = c("allocation", "kpi", "comparison",
                                         "posterior", "curves", "returns"),
                                ...) {

  type <- match.arg(type)
  sol <- x$solution
  is_posterior <- x$method == "posterior"

  if (type == "posterior" && !is_posterior) {
    message("Posterior plot not available for point method; showing allocation instead.")
    type <- "allocation"
  }

  if (type %in% c("curves", "returns") && is.null(x$mrms)) {
    stop("Models (mrms) not stored on result. Re-run opt_mix() with the current package version.")
  }

  switch(type,
    allocation = plot_opt_allocation(sol, is_posterior, metric = "spend"),
    kpi        = plot_opt_allocation(sol, is_posterior, metric = "kpi"),
    comparison = plot_opt_comparison(sol),
    posterior  = plot_opt_posterior(x),
    curves     = plot_opt_curves(x),
    returns    = plot_opt_returns(x)
  )
}


# --- Internal plot helpers ---

plot_opt_allocation <- function(sol, is_posterior, metric = "spend") {

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


plot_opt_comparison <- function(sol) {
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


plot_opt_posterior <- function(x) {
  draws_df <- as.data.frame(x$draws_matrix)
  draws_long <- tidyr::pivot_longer(
    draws_df,
    cols = everything(),
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


plot_opt_curves <- function(x) {
  sol <- x$solution
  mrms <- x$mrms

  # Build curve + points data for each channel
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


plot_opt_returns <- function(x) {
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
