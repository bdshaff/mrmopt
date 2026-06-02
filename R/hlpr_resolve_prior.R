#' Resolve an mrm_prior specification into a brms prior object
#'
#' Converts user-friendly prior specifications from \code{\link{mrm_prior}}
#' into \code{brms::prior} objects appropriate for the given scaling method,
#' scale values, and response form type. Also performs form-aware validation
#' to prevent mathematically invalid prior configurations.
#'
#' @param mrm_prior An object of class \code{mrm_prior}, or \code{NULL} for
#'   package defaults.
#' @param scaled_data The scaled data frame.
#' @param x Name of the x column.
#' @param y Name of the y column.
#' @param scale_method Either \code{"min_max"} or \code{"std"}.
#' @param scale_values List of scaling parameters (min/max or mean/sd values).
#' @param type The response form type (e.g., \code{"gompertz"}, \code{"log_logistic"}).
#' @return A \code{brmsprior} object.
#' @keywords internal

hlpr_resolve_prior <- function(mrm_prior = NULL,
                               scaled_data,
                               x, y,
                               scale_method,
                               scale_values,
                               type) {

  if (is.null(mrm_prior)) {
    mrm_prior <- mrm_prior()
  }

  # --- Identify log-based forms ---
  log_forms <- c("log_logistic", "weibull", "reflected_weibull")
  is_log_form <- type %in% log_forms

  # --- Validate form-specific constraints ---
  hlpr_validate_prior_for_form(mrm_prior, type, is_log_form)


  # --- Get data ranges in scaled space ---
  x_min_s <- min(scaled_data[[x]], na.rm = TRUE)
  x_max_s <- max(scaled_data[[x]], na.rm = TRUE)
  x_range_s <- x_max_s - x_min_s
  y_min_s <- min(scaled_data[[y]], na.rm = TRUE)
  y_max_s <- max(scaled_data[[y]], na.rm = TRUE)

  # --- Convert midpoint_range (x-axis fractions) to scaled x bounds ---
  e_lb <- x_min_s + mrm_prior$midpoint_range[1] * x_range_s
  e_ub <- x_min_s + mrm_prior$midpoint_range[2] * x_range_s
  e_mean <- (e_lb + e_ub) / 2

  # For log-based forms, midpoint must be > 0

  if (is_log_form) {
    e_lb <- max(e_lb, 1e-6)
    if (e_lb >= e_ub) {
      stop(
        "After enforcing e > 0 for log-based form '", type,
        "', the midpoint lower bound (", round(e_lb, 4),
        ") >= upper bound (", round(e_ub, 4),
        "). Widen `midpoint_range` or check your data.",
        call. = FALSE
      )
    }
  }

  # --- Convert ceiling_max (multiplier on observed max of y) to scaled space ---
  # ceiling_max is a multiplier on the observed max of y in original units.
  # We need to convert ceiling_max * max(y_original) into scaled units.
  if (scale_method == "min_max") {
    # In min_max space, observed max of y is 1.0, so this is straightforward
    d_ub <- mrm_prior$ceiling_max * 1.0
    d_lb <- 0.8  # ceiling should be at least near the observed max
    d_mean <- (d_lb + d_ub) / 2
  } else if (scale_method == "std") {
    # max(y_original) = y_max_s * y_sd + y_mean
    # ceiling_in_original = ceiling_max * max(y_original)
    # ceiling_in_scaled = (ceiling_in_original - y_mean) / y_sd
    y_max_original <- y_max_s * scale_values$y_sd + scale_values$y_mean
    d_ub <- (mrm_prior$ceiling_max * y_max_original - scale_values$y_mean) /
      scale_values$y_sd
    d_lb <- y_max_s * 0.8
    d_mean <- (d_lb + d_ub) / 2
  }

  # --- Convert floor_min (original data units) to scaled space ---
  # floor_min is specified in original data units. Convert to scaled space.
  if (scale_method == "min_max") {
    c_lb <- (mrm_prior$floor_min - scale_values$y_min) /
      (scale_values$y_max - scale_values$y_min)
    c_ub <- c_lb + 0.25
    c_mean <- (c_lb + c_ub) / 2
  } else if (scale_method == "std") {
    c_lb <- (mrm_prior$floor_min - scale_values$y_mean) / scale_values$y_sd
    # Scale the upper bound relative to the data spread rather than a fixed offset
    # Allow the floor to range up to ~10% of the observed y range in scaled units
    y_range_s <- y_max_s - y_min_s
    c_ub <- c_lb + 0.25 * y_range_s
    c_mean <- (c_lb + c_ub) / 2
  }

  # --- Steepness (b): internal defaults ---
  # b is negative for all increasing S-curve forms. The "reflected" forms
  # reflect the curve shape (swapping concavity) along the x=y diagonal,
  # not the direction — so b remains negative for both standard and
  # reflected forms.
  #
  # The same b range works for both standard and log-based forms: the log
  # transform is part of the model formula itself, so b operates on the
  # log-scale argument directly and doesn't need prior compensation.
  b_mean <- -4
  b_lb <- -10
  b_ub <- 0

  # Broad SD for all parameters — let the data speak
  prior_sd <- 10

  # --- Assemble brms prior ---
  prior <- c(
    brms::prior_string(
      paste0("normal(", b_mean, ", ", prior_sd, ")"),
      nlpar = "b", lb = b_lb, ub = b_ub
    ),
    brms::prior_string(
      paste0("normal(", round(c_mean, 4), ", ", prior_sd, ")"),
      nlpar = "c", lb = round(c_lb, 4), ub = round(c_ub, 4)
    ),
    brms::prior_string(
      paste0("normal(", round(d_mean, 4), ", ", prior_sd, ")"),
      nlpar = "d", lb = round(d_lb, 4), ub = round(d_ub, 4)
    ),
    brms::prior_string(
      paste0("normal(", round(e_mean, 4), ", ", prior_sd, ")"),
      nlpar = "e", lb = round(e_lb, 4), ub = round(e_ub, 4)
    )
  )

  return(prior)
}


#' Validate prior specification against response form constraints
#'
#' Checks that the prior configuration is mathematically valid for the
#' chosen response form type.
#'
#' @param mrm_prior An \code{mrm_prior} object.
#' @param type The response form type.
#' @param is_log_form Logical; whether the form uses log transforms.
#' @keywords internal

hlpr_validate_prior_for_form <- function(mrm_prior, type, is_log_form) {

  valid_types <- c("logistic", "log_logistic", "gompertz",
                   "reflected_gompertz", "weibull", "reflected_weibull")

  if (!type %in% valid_types) {
    stop(
      "Unknown response form type '", type,
      "'. Must be one of: ", paste(valid_types, collapse = ", "),
      call. = FALSE
    )
  }

  if (is_log_form && mrm_prior$midpoint_range[1] == 0) {
    warning(
      "midpoint_range starts at 0, but '", type,
      "' uses log(x) and log(e) which require positive values. ",
      "The lower bound will be shifted slightly above 0.",
      call. = FALSE
    )
  }
}
