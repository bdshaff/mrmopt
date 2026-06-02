#' Extract parameters from a fitted model
#'
#' This function extracts the parameters from a fitted model object.
#'
#' @param rc_fit A fitted model object.
#' @param scaled A logical indicating whether the model was fitted on scaled data. Default is TRUE.
#' @return A list containing the center, lower, and upper bounds of the parameters.
#' @details The function extracts the parameters from the fitted model object
#'   and returns them in a list. When \code{scaled = TRUE}, parameters are
#'   unscaled back to original data units (spend for b/e, KPI for c/d).
#'
#' @export

mrm_params <- function(rc_fit, scaled = TRUE) {

  # Extract posterior summaries for parameters b, c, d, e
  posterior_summary <- summary(rc_fit)$fixed
  params <- posterior_summary[grepl("b|c|d|e", rownames(posterior_summary)), , drop = FALSE]
  params <- as.data.frame(params)

  center = params$Estimate
  names(center) = c("b","c","d","e")

  lower = params$`l-95% CI`
  names(lower) = c("b","c","d","e")

  upper = params$`u-95% CI`
  names(upper) = c("b","c","d","e")

  # Rescale parameters if the model was fitted on scaled data
  if (scaled && !is.null(rc_fit$scale_values)) {
    sv <- rc_fit$scale_values
    x_offset <- if (!is.null(sv$x_offset)) sv$x_offset else 0
    log_forms <- c("log_logistic", "weibull", "reflected_weibull")
    is_log_form <- !is.null(rc_fit$rc_type) && rc_fit$rc_type %in% log_forms

    # --- Unscale x-related params (b, e) ---
    if (is_log_form) {
      x_max <- sv$x_max
      for (est in c("center", "lower", "upper")) {
        env <- environment()
        v <- get(est, envir = env)
        v["e"] <- v["e"] * x_max - x_offset
        assign(est, v, envir = env)
      }
    } else if (!is.null(sv$x_min) && !is.null(sv$x_max)) {
      x_range <- sv$x_max - sv$x_min
      for (est in c("center", "lower", "upper")) {
        env <- environment()
        v <- get(est, envir = env)
        v["b"] <- v["b"] / x_range
        v["e"] <- v["e"] * x_range + sv$x_min - x_offset
        assign(est, v, envir = env)
      }
    } else if (!is.null(sv$x_mean) && !is.null(sv$x_sd)) {
      for (est in c("center", "lower", "upper")) {
        env <- environment()
        v <- get(est, envir = env)
        v["b"] <- v["b"] / sv$x_sd
        v["e"] <- v["e"] * sv$x_sd + sv$x_mean - x_offset
        assign(est, v, envir = env)
      }
    }

    # --- Unscale y-related params (c, d) ---
    if (!is.null(sv$y_min) && !is.null(sv$y_max)) {
      y_range <- sv$y_max - sv$y_min
      for (est in c("center", "lower", "upper")) {
        env <- environment()
        v <- get(est, envir = env)
        v["c"] <- v["c"] * y_range + sv$y_min
        v["d"] <- v["d"] * y_range + sv$y_min
        assign(est, v, envir = env)
      }
    } else if (!is.null(sv$y_mean) && !is.null(sv$y_sd)) {
      for (est in c("center", "lower", "upper")) {
        env <- environment()
        v <- get(est, envir = env)
        v["c"] <- v["c"] * sv$y_sd + sv$y_mean
        v["d"] <- v["d"] * sv$y_sd + sv$y_mean
        assign(est, v, envir = env)
      }
    }
  }

  # Create a list to hold the parameters
  params_list <- list(
    center = as.list(center),
    lower = as.list(lower),
    upper = as.list(upper)
  )

  # Return the list of parameters
  return(params_list)
}
