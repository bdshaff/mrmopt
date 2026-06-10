#' Plot cost per KPI of a fitted model
#'
#' Draws the cost-per-KPI efficiency curve with a credible-interval ribbon.
#' This is the third panel of the dashboard produced by [plot.mrmfit()]; call
#' it directly when you need a standalone cost-per plot or want to control
#' parameters not exposed by `plot()`.
#'
#' @param mrm A fitted model object returned by \code{\link{fit_response}}.
#' @param xrange Numeric vector of length 2 for the x range. NULL uses defaults.
#' @param length.out Number of points. Default is 1000.
#' @param scaled Logical; plot on original scale? Default is TRUE.
#' @param markup Logical; add range annotations and current-point marker?
#'   Default is TRUE.
#' @param x_var Character; \code{"spend"} (default) or \code{"units"}.
#' @param interval Type of credible interval. \code{"prediction"} (default)
#'   includes observation noise. \code{"confidence"} shows uncertainty about
#'   the mean curve only (tighter bands).
#' @return A ggplot object.
#'
#' @seealso [plot.mrmfit()] for the combined dashboard,
#'   [mrm_plot_response()], [mrm_plot_return()] for the other panels.
#' @export

mrm_plot_costper <- function(mrm,
                             xrange = NULL,
                             length.out = 1000,
                             scaled = TRUE,
                             markup = TRUE,
                             x_var = c("spend", "units"),
                             interval = c("prediction", "confidence")) {

  if (!inherits(mrm, "mrmfit")) {
    stop("mrm must be a fitted model object created by fit_response()", call. = FALSE)
  }

  x_var <- match.arg(x_var)
  interval <- match.arg(interval)
  pal <- mrmopt_palette()

  # --- Data ---
  if (!is.null(xrange) || length.out != 1000 || !isTRUE(scaled)) {
    response_df <- mrm_infer(mrm, xrange = xrange, length.out = length.out, scaled = scaled)
  } else {
    response_df <- mrm$response_df
  }

  # Select interval type for derived metrics
  if (interval == "confidence") {
    response_df$cp_lower <- response_df$cp_lower  # cp_lower is always from center
    response_df$cp_upper <- response_df$cp_upper_mu
  }

  x_col <- names(response_df)[1]

  # --- Resolve x-axis ---
  has_units <- !is.null(mrm$units_col) && !is.null(mrm$cost_per_unit)
  if (x_var == "units") {
    if (!has_units) stop("Units not available; fit the model with a `units` column.", call. = FALSE)
    if (!"units" %in% names(response_df)) {
      response_df$units <- response_df[[x_col]] / mrm$cost_per_unit
    }
    x_plot <- "units"
    x_lab <- "Units"
    x_scale <- ggplot2::scale_x_continuous(labels = scales::comma)
  } else {
    x_plot <- x_col
    x_lab <- "Spend"
    x_scale <- ggplot2::scale_x_continuous(labels = scales::dollar_format())
  }

  # --- Title ---
  channel <- hlpr_channel_name(mrm)
  ptitle <- paste0(channel, " \u2014 Cost per KPI")

  # --- Filter infinite values ---
  plot_data <- response_df[is.finite(response_df$cp), ]

  # --- Base plot with CI ribbon ---
  p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = !!ggplot2::sym(x_plot), y = .data$cp)) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = .data$cp_lower, ymax = .data$cp_upper),
      fill = pal[["ci_band"]], alpha = 0.5,
      data = plot_data[is.finite(plot_data$cp_lower) & is.finite(plot_data$cp_upper), ]
    ) +
    ggplot2::geom_line(color = pal[["cp"]], linewidth = 0.8) +
    x_scale +
    ggplot2::scale_y_continuous(labels = scales::dollar_format(), limits = c(0, NA)) +
    ggplot2::labs(title = ptitle, x = x_lab, y = "Cost per KPI") +
    ggplot2::theme_minimal()

  # --- Markup ---
  if (markup) {
    p <- p + hlpr_range_annotations(mrm, x_var = x_var)

    # Current point marker
    s <- mrm$summary
    if (!is.null(s)) {
      if (x_var == "units" && has_units) {
        x_cur <- s$weekly_spend / mrm$cost_per_unit
      } else {
        x_cur <- s$weekly_spend
      }
      cur_df <- data.frame(xc = x_cur, yc = s$cp_at_current)
      p <- p + ggplot2::geom_point(
        data = cur_df,
        ggplot2::aes(x = .data$xc, y = .data$yc),
        shape = 21, size = 3, fill = pal[["current"]], color = "white",
        stroke = 0.8, inherit.aes = FALSE
      )
    }
  }

  p
}
