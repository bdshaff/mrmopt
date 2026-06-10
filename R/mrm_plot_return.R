#' Plot Absolute and Marginal Rates of Return
#'
#' Draws absolute return (AR) and marginal return (MR) curves on a dual y-axis.
#' This is the second panel of the dashboard produced by [plot.mrmfit()]; call
#' it directly when you need a standalone return-curve plot or want to control
#' parameters not exposed by `plot()`.
#'
#' @param mrm A fitted model object returned by \code{\link{fit_response}}.
#' @param location Which parameter estimate to use: \code{"center"} (default),
#'   \code{"lower"}, or \code{"upper"}.
#' @param xrange Numeric vector of length 2 for the x range. NULL uses defaults.
#' @param length.out Number of points. Default is 1000.
#' @param scaled Logical; plot on original scale? Default is TRUE.
#' @param markup Logical; add range annotations and current-point markers?
#'   Default is TRUE.
#' @param x_var Character; \code{"spend"} (default) or \code{"units"}.
#' @param interval Type of credible interval. \code{"prediction"} (default)
#'   includes observation noise. \code{"confidence"} shows uncertainty about
#'   the mean curve only (tighter bands).
#' @return A ggplot object.
#'
#' @seealso [plot.mrmfit()] for the combined dashboard,
#'   [mrm_plot_response()], [mrm_plot_costper()] for the other panels.
#' @export

mrm_plot_return <- function(mrm,
                            location = "center",
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

  x_col <- names(response_df)[1]

  # --- Select location (with interval type) ---
  suffix <- if (interval == "confidence") "_mu" else ""
  if (location == "lower") {
    response_df$ar_plot <- response_df[[paste0("ar_lower", suffix)]]
    response_df$mr_plot <- response_df[[paste0("mr_lower", suffix)]]
  } else if (location == "upper") {
    response_df$ar_plot <- response_df[[paste0("ar_upper", suffix)]]
    response_df$mr_plot <- response_df[[paste0("mr_upper", suffix)]]
  } else {
    response_df$ar_plot <- response_df$ar
    response_df$mr_plot <- response_df$mr
  }

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

  # --- Title / subtitle ---
  channel <- hlpr_channel_name(mrm)
  ptitle <- paste0(channel, " \u2014 AR & MR")

  # --- Pivot to long for proper legend ---
  plot_df <- data.frame(
    x = rep(response_df[[x_plot]], 2),
    value = c(response_df$ar_plot, response_df$mr_plot),
    metric = rep(c("Absolute Return (AR)", "Marginal Return (MR)"),
                 each = nrow(response_df))
  )

  color_map <- c(
    "Absolute Return (AR)" = pal[["ar"]],
    "Marginal Return (MR)" = pal[["mr"]]
  )

  p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, y = .data$value, color = .data$metric)) +
    ggplot2::geom_line(linewidth = 0.7, na.rm = TRUE) +
    ggplot2::scale_color_manual(values = color_map, name = NULL) +
    x_scale +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::labs(title = ptitle, x = x_lab, y = "Rate") +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "top")

  # --- Markup ---
  if (markup) {
    p <- p + hlpr_range_annotations(mrm, x_var = x_var)

    # Current point markers on both curves
    s <- mrm$summary
    if (!is.null(s)) {
      if (x_var == "units" && has_units) {
        x_cur <- s$weekly_spend / mrm$cost_per_unit
      } else {
        x_cur <- s$weekly_spend
      }

      cur_pts <- data.frame(
        x = c(x_cur, x_cur),
        value = c(s$ar_at_current, s$mr_at_current),
        metric = c("Absolute Return (AR)", "Marginal Return (MR)")
      )

      p <- p + ggplot2::geom_point(
        data = cur_pts,
        ggplot2::aes(x = .data$x, y = .data$value, color = .data$metric),
        shape = 21, size = 3, fill = pal[["current"]], stroke = 0.8
      )
    }
  }

  p
}
