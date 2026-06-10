#' Helper function to scale the data for model prep
#'
#' This function scales the data and calculates the inferred x-range for the
#' model. For log-based response forms, x is ratio-scaled (divided by max)
#' to preserve positivity, since log(x) requires x > 0. If the data contains
#' zero x values, a small data-adaptive offset is added before scaling.
#'
#' @param data The input data frame containing the x and y variables to be scaled.
#' @param x Name of the x column.
#' @param y Name of the y column.
#' @param scale_method Either \code{"min_max"} or \code{"std"}.
#' @param type The response form type. Log-based forms (\code{"log_logistic"},
#'   \code{"weibull"}, \code{"reflected_weibull"}) trigger ratio x-scaling
#'   and a positive offset if zeros are present. Default is \code{"gompertz"}.
#' @return A list containing the scaled data, the inferred x-range, and the
#'   scaling values used for rescaling.

hlpr_scale_data = function(data, x, y, scale_method, type = "gompertz") {

  log_forms <- c("log_logistic", "weibull", "reflected_weibull")
  is_log_form <- type %in% log_forms

  # --- For log-based forms: apply data-adaptive offset if x has zeros ---
  x_offset <- 0
  if (is_log_form) {
    if (any(data[[x]] < 0, na.rm = TRUE)) {
      stop(
        "Log-based response form '", type, "' requires all x values to be ",
        "non-negative. Found negative x values in the data.",
        call. = FALSE
      )
    }

    if (any(data[[x]] == 0, na.rm = TRUE)) {
      pos_vals <- data[[x]][data[[x]] > 0]
      if (length(pos_vals) == 0) {
        stop(
          "All x values are zero; cannot fit a log-based form.",
          call. = FALSE
        )
      }
      x_offset <- min(pos_vals, na.rm = TRUE) / 2
      data[[x]] <- data[[x]] + x_offset
    }
  }

  if (!scale_method %in% c("min_max", "std")) {
    stop("Invalid scale method. Please choose either 'min_max' or 'std'.")
  }

  # --- Y scaling: always follows the user's chosen scale_method ---
  y_min_raw <- min(data[[y]], na.rm = TRUE)
  y_max_raw <- max(data[[y]], na.rm = TRUE)

  if (scale_method == "min_max") {
    data[[y]] <- (data[[y]] - y_min_raw) / (y_max_raw - y_min_raw)
  } else if (scale_method == "std") {
    y_mean_raw <- mean(data[[y]], na.rm = TRUE)
    y_sd_raw <- sd(data[[y]], na.rm = TRUE)
    data[[y]] <- (data[[y]] - y_mean_raw) / y_sd_raw
  }

  # --- X scaling ---
  if (is_log_form) {
    # Ratio scaling for x: x_scaled = x / x_max
    # Preserves positivity. Works regardless of scale_method.
    x_max_raw <- max(data[[x]], na.rm = TRUE)
    data[[x]] <- data[[x]] / x_max_raw

    infer_xrange <- c(min(data[[x]], na.rm = TRUE), 2)

    if (scale_method == "min_max") {
      scale_values <- list(
        x_min = 0,
        x_max = x_max_raw,
        x_offset = x_offset,
        y_min = y_min_raw,
        y_max = y_max_raw
      )
    } else {
      # std for y, ratio for x
      scale_values <- list(
        x_min = 0,
        x_max = x_max_raw,
        x_offset = x_offset,
        y_mean = y_mean_raw,
        y_sd = y_sd_raw,
        y_min = y_min_raw,
        y_max = y_max_raw
      )
    }

  } else {
    # Non-log forms: standard scaling for x
    if (scale_method == "min_max") {
      x_min_raw <- min(data[[x]], na.rm = TRUE)
      x_max_raw <- max(data[[x]], na.rm = TRUE)

      data[[x]] <- (data[[x]] - x_min_raw) / (x_max_raw - x_min_raw)

      infer_xrange <- c(-x_min_raw / (x_max_raw - x_min_raw), 2)

      scale_values <- list(
        x_min = x_min_raw,
        x_max = x_max_raw,
        x_offset = 0,
        y_min = y_min_raw,
        y_max = y_max_raw
      )

    } else {
      # std scaling for both x and y
      x_mean_raw <- mean(data[[x]], na.rm = TRUE)
      x_sd_raw <- sd(data[[x]], na.rm = TRUE)

      data[[x]] <- (data[[x]] - x_mean_raw) / x_sd_raw

      infer_xrange <- c(min(data[[x]], na.rm = TRUE), 2 * max(data[[x]], na.rm = TRUE))

      scale_values <- list(
        x_mean = x_mean_raw,
        x_sd = x_sd_raw,
        x_offset = 0,
        y_mean = y_mean_raw,
        y_sd = y_sd_raw,
        y_min = y_min_raw,
        y_max = y_max_raw
      )
    }
  }

  return(list(
    scaled_data = data,
    scaled_xrange = infer_xrange,
    scale_values = scale_values
  ))
}
