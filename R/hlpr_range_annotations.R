#' Generate consistent range and current-point annotations for mrmopt plots
#'
#' Returns a list of ggplot2 layers that annotate the current operating point
#' and the three range points from \code{mrm_summary()}.
#'
#' @param mrm A fitted model object returned by \code{\link{fit_response}}.
#' @param x_var Character; \code{"spend"} or \code{"units"}.
#' @param show_current Logical; whether to mark the current operating point.
#' @param show_range Logical; whether to shade the range region and mark
#'   range_min / range_max with vertical lines.
#' @return A list of ggplot2 layers.
#' @keywords internal

hlpr_range_annotations <- function(mrm,
                                   x_var = "spend",
                                   show_current = TRUE,
                                   show_range = TRUE) {

  pal <- mrmopt_palette()
  s <- mrm$summary
  if (is.null(s)) return(list())

  log_forms <- c("log_logistic", "weibull", "reflected_weibull")
  is_log <- !is.null(mrm$rc_type) && mrm$rc_type %in% log_forms

  # Pick x values based on x_var
  if (x_var == "units") {
    has_units <- !is.null(mrm$units_col) && !is.null(mrm$cost_per_unit)
    if (!has_units) return(list())
    cpu <- mrm$cost_per_unit
    x_current <- s$weekly_spend / cpu
    x_min     <- s$range_min_spend / cpu
    x_peak    <- s$range_peak_spend / cpu
    x_max     <- s$range_max_spend / cpu
  } else {
    x_current <- s$weekly_spend
    x_min     <- s$range_min_spend
    x_peak    <- s$range_peak_spend
    x_max     <- s$range_max_spend
  }

  layers <- list()

  # Range shading
  if (show_range) {
    layers <- c(layers, list(
      ggplot2::annotate(
        "rect",
        xmin = x_min, xmax = x_max,
        ymin = -Inf, ymax = Inf,
        fill = pal[["range_fill"]], alpha = 0.2
      ),
      ggplot2::geom_vline(
        xintercept = x_min,
        linetype = "dashed", color = pal[["range_line"]], linewidth = 0.4
      ),
      ggplot2::geom_vline(
        xintercept = x_max,
        linetype = "dashed", color = pal[["range_line"]], linewidth = 0.4
      )
    ))
  }

  # Current operating point (vertical line only — the point marker is
  # added by each plot function on the relevant y-axis series)
  if (show_current) {
    layers <- c(layers, list(
      ggplot2::geom_vline(
        xintercept = x_current,
        linetype = "solid", color = pal[["current"]], linewidth = 0.5,
        alpha = 0.6
      )
    ))
  }

  layers
}


#' Generate range labels appropriate for the curve form
#'
#' Returns a named list with labels for range_min, range_peak, and range_max
#' that differ for log-form vs standard curves.
#'
#' @param mrm A fitted model object.
#' @return A named list with elements \code{min}, \code{peak}, \code{max}.
#' @keywords internal

hlpr_range_labels <- function(mrm) {
  log_forms <- c("log_logistic", "weibull", "reflected_weibull")
  is_log <- !is.null(mrm$rc_type) && mrm$rc_type %in% log_forms

  if (is_log) {
    list(min = "2\u00d7 MR", peak = "Current", max = "0.5\u00d7 MR")
  } else {
    list(min = "Peak MR", peak = "Peak AR", max = "70% MR")
  }
}
