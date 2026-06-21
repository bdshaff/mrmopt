#' Plot the response curve of a fitted model
#'
#' Draws the response curve with a credible-interval ribbon and optional data
#' points, range annotations, and marginal-return overlay. This is the first
#' panel of the dashboard produced by [plot.mrmfit()]; call it directly when
#' you need a standalone response-curve plot or want to control parameters
#' (e.g., `xrange`, `length.out`) not exposed by `plot()`.
#'
#' @param mrm A fitted model object returned by \code{\link{fit_response}}.
#' @param xrange A vector of length 2 specifying the x range. If NULL, uses
#'   the default from inference.
#' @param length.out Number of points to generate. Default is 1000.
#' @param scaled Logical; plot on the original (unscaled) data scale? Default
#'   is TRUE.
#' @param points Logical; overlay observed data points? Default is TRUE.
#' @param markup Logical; add range annotations and current-point marker?
#'   Default is TRUE.
#' @param show_mr Logical; overlay the marginal return curve on a secondary
#'   y-axis? Default is FALSE.
#' @param x_var Character; \code{"spend"} (default) or \code{"units"} for the
#'   x-axis variable.
#' @param interval Type of credible interval. \code{"prediction"} (default)
#'   includes observation noise. \code{"confidence"} shows uncertainty about
#'   the mean curve only (tighter bands).
#' @return A ggplot object.
#'
#' @seealso [plot.mrmfit()] for the combined dashboard,
#'   [mrm_plot_return()], [mrm_plot_costper()] for the other panels.
#' @export

mrm_plot_response <- function(mrm,
                              xrange = NULL,
                              length.out = 1000,
                              scaled = TRUE,
                              points = TRUE,
                              markup = TRUE,
                              show_mr = FALSE,
                              x_var = c("spend", "units"),
                              interval = c("prediction", "confidence")) {

  if (!inherits(mrm, "mrmfit")) {
    stop("mrm must be a fitted model object created by fit_response()", call. = FALSE)
  }
  if (inherits(mrm, "mrmfit_hier_unit")) hlpr_unit_view_warn("mrm_plot_response")

  x_var <- match.arg(x_var)
  interval <- match.arg(interval)
  pal <- mrmopt_palette()

  # --- Data ---
  if (!is.null(xrange) || length.out != 1000 || !isTRUE(scaled)) {
    response_df <- mrm_infer(mrm, xrange = xrange, length.out = length.out,
                             scaled = scaled)
  } else {
    response_df <- mrm$response_df
  }

  # Select which interval columns to use for the ribbon
  if (interval == "confidence") {
    response_df$lower <- response_df$lower_mu
    response_df$upper <- response_df$upper_mu
  }

  rc_data <- mrm$data
  y_var <- mrm$formula$resp
  x_col <- names(rc_data)[names(rc_data) != y_var]

  # --- Resolve x-axis variable ---
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
    x_plot <- names(response_df)[1]
    x_lab <- "Spend"
    x_scale <- ggplot2::scale_x_continuous(labels = scales::dollar_format())
  }

  # --- Title / subtitle ---
  channel <- hlpr_channel_name(mrm)
  rc_type <- mrm$rc_type
  ptitle <- paste0(channel, " \u2014 ", rc_type)

  r2_str <- if (!is.null(mrm$R2)) {
    paste0("R\u00b2 = ", round(mrm$R2$Estimate, 3))
  } else {
    NULL
  }
  n_weeks <- if (!is.null(mrm$summary)) {
    paste0(mrm$summary$n_weeks, " weeks")
  } else {
    NULL
  }
  psubtitle <- paste(c(r2_str, n_weeks), collapse = " | ")

  # --- Base plot ---
  p <- ggplot2::ggplot(response_df, ggplot2::aes(!!ggplot2::sym(x_plot), center)) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = lower, ymax = upper),
      fill = pal[["ci_band"]], alpha = 0.5
    ) +
    ggplot2::geom_line(color = pal[["response"]], linewidth = 0.8) +
    x_scale +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::labs(title = ptitle, subtitle = psubtitle, x = x_lab, y = "KPI") +
    ggplot2::theme_minimal()

  # --- Data points ---
  if (points) {
    rc_pts <- hlpr_unscale_data_points(mrm, x_var)
    p <- p + ggplot2::geom_point(
      data = rc_pts,
      ggplot2::aes(x = .data$x_plot_val, y = .data$y_plot_val),
      color = pal[["data_pts"]], alpha = 0.5
    )
  }

  # --- Markup (range + current point) ---
  if (markup) {
    p <- p + hlpr_range_annotations(mrm, x_var = x_var)

    # Current point marker on the curve
    s <- mrm$summary
    if (!is.null(s)) {
      if (x_var == "units" && has_units) {
        x_cur <- s$weekly_spend / mrm$cost_per_unit
      } else {
        x_cur <- s$weekly_spend
      }
      cur_df <- data.frame(xc = x_cur, yc = s$kpi_at_current)
      p <- p + ggplot2::geom_point(
        data = cur_df,
        ggplot2::aes(x = .data$xc, y = .data$yc),
        shape = 21, size = 3, fill = pal[["current"]], color = "white",
        stroke = 0.8, inherit.aes = FALSE
      )
    }
  }

  # --- MR overlay via secondary axis ---
  if (show_mr && "mr" %in% names(response_df)) {
    mr_vals <- response_df$mr
    mr_range <- range(mr_vals, na.rm = TRUE)
    y_range <- range(response_df$center, na.rm = TRUE)

    # Scaling factor: map MR range onto the KPI y-axis range
    mr_span <- diff(mr_range)
    y_span <- diff(y_range)
    if (mr_span > 0 && y_span > 0) {
      scale_factor <- y_span / mr_span
      offset <- y_range[1] - mr_range[1] * scale_factor

      response_df$.mr_scaled <- response_df$mr * scale_factor + offset

      p <- p +
        ggplot2::geom_line(
          data = response_df[!is.na(response_df$.mr_scaled), ],
          ggplot2::aes(y = .data$.mr_scaled),
          color = pal[["mr"]], linewidth = 0.5, linetype = "dashed", alpha = 0.7
        ) +
        ggplot2::scale_y_continuous(
          labels = scales::comma,
          sec.axis = ggplot2::sec_axis(
            ~ (. - offset) / scale_factor,
            name = "Marginal Return",
            labels = scales::comma
          )
        )
    }
  }

  p
}


#' Unscale observed data points for plotting
#'
#' @param mrm A fitted model object.
#' @param x_var Character; \code{"spend"} or \code{"units"}.
#' @return A data frame with columns \code{x_plot_val} and \code{y_plot_val}.
#' @keywords internal

hlpr_unscale_data_points <- function(mrm, x_var = "spend") {
  rc_data <- mrm$data
  y_var <- mrm$formula$resp
  x_col <- names(rc_data)[names(rc_data) != y_var]

  x_vals <- rc_data[[x_col]]
  y_vals <- rc_data[[y_var]]

  if (!is.null(mrm$scale_values)) {
    sv <- mrm$scale_values
    x_offset <- if (!is.null(sv$x_offset)) sv$x_offset else 0

    if (!is.null(sv$x_min) && !is.null(sv$x_max)) {
      x_vals <- x_vals * (sv$x_max - sv$x_min) + sv$x_min - x_offset
    } else if (!is.null(sv$x_mean) && !is.null(sv$x_sd)) {
      x_vals <- x_vals * sv$x_sd + sv$x_mean - x_offset
    }

    if (!is.null(sv$y_min) && !is.null(sv$y_max)) {
      y_vals <- y_vals * (sv$y_max - sv$y_min) + sv$y_min
    } else if (!is.null(sv$y_mean) && !is.null(sv$y_sd)) {
      y_vals <- y_vals * sv$y_sd + sv$y_mean
    }
  }

  if (x_var == "units" && !is.null(mrm$cost_per_unit)) {
    x_vals <- x_vals / mrm$cost_per_unit
  }

  data.frame(x_plot_val = x_vals, y_plot_val = y_vals)
}
