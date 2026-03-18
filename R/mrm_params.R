#' Extract parameters from a fitted model
#'
#' This function extracts the parameters from a fitted model object.
#'
#' @param rc_fit A fitted model object.
#' @param scaled A logical indicating whether the model was fitted on scaled data. Default is TRUE.
#' @param cost_per_unit The cost per unit of the independent variable. Default is 1.0.
#' @param response_rate The response rate to be used in return calculations. Default is 1.0.
#' @return A list containing the center, lower, and upper bounds of the parameters.
#' @details The function extracts the parameters from the fitted model object and returns them in a list.
#'
#' @export

mrm_params <- function(rc_fit, scaled = TRUE, cost_per_unit = 1.0, response_rate = 1.0) {

  # Extract posterior summaries for parameters b, c, d, e
  posterior_summary <- summary(rc_fit)$fixed
  params <- posterior_summary[grepl("b|c|d|e", rownames(posterior_summary)), ]
  params <- as.data.frame(params)

  center = params$Estimate
  names(center) = c("b","c","d","e")

  lower = params$`l-95% CI`
  names(lower) = c("b","c","d","e")

  upper = params$`u-95% CI`
  names(upper) = c("b","c","d","e")

  # Rescale parameters if the model was fitted on scaled data
  if(scaled & rc_fit$scale_method == "min_max"){
    #rescale the parameters back to the original scale
    x_min = rc_fit$scale_values$x_min
    x_max = rc_fit$scale_values$x_max
    y_min = rc_fit$scale_values$y_min
    y_max = rc_fit$scale_values$y_max

    #rescale c and d
    center["c"] = center["c"] * (y_max - y_min) + y_min
    lower["c"] = lower["c"] * (y_max - y_min) + y_min
    upper["c"] = upper["c"] * (y_max - y_min) + y_min

    center["d"] = center["d"] * (y_max - y_min) + y_min
    lower["d"] = lower["d"] * (y_max - y_min) + y_min
    upper["d"] = upper["d"] * (y_max - y_min) + y_min

    #rescale b and e
    center["b"] = center["b"] / (x_max - x_min)
    lower["b"] = lower["b"] / (x_max - x_min)
    upper["b"] = upper["b"] / (x_max - x_min)

    center["e"] = center["e"] * (x_max - x_min) + x_min
    lower["e"] = lower["e"] * (x_max - x_min) + x_min
    upper["e"] = upper["e"] * (x_max - x_min) + x_min
  }else if(scaled & rc_fit$scale_method == "std"){
    #rescale the parameters back to the original scale
    x_mean = rc_fit$scale_values$x_mean
    x_sd = rc_fit$scale_values$x_sd
    y_mean = rc_fit$scale_values$y_mean
    y_sd = rc_fit$scale_values$y_sd

    #rescale c and d
    center["c"] = center["c"] * y_sd + y_mean
    lower["c"] = lower["c"] * y_sd + y_mean
    upper["c"] = upper["c"] * y_sd + y_mean

    center["d"] = center["d"] * y_sd + y_mean
    lower["d"] = lower["d"] * y_sd + y_mean
    upper["d"] = upper["d"] * y_sd + y_mean

    #rescale b and e
    center["b"] = center["b"] / x_sd
    lower["b"] = lower["b"] / x_sd
    upper["b"] = upper["b"] / x_sd

    center["e"] = center["e"] * x_sd + x_mean
    lower["e"] = lower["e"] * x_sd + x_mean
    upper["e"] = upper["e"] * x_sd + x_mean
  }

  center["c"] = center["c"] * response_rate
  lower["c"] = lower["c"] * response_rate
  upper["c"] = upper["c"] * response_rate

  center["d"] = center["d"] * response_rate
  lower["d"] = lower["d"] * response_rate
  upper["d"] = upper["d"] * response_rate

  center["e"] = center["e"] * cost_per_unit
  lower["e"] = lower["e"] * cost_per_unit
  upper["e"] = upper["e"] * cost_per_unit

  center["b"] = center["b"] / cost_per_unit
  lower["b"] = lower["b"] / cost_per_unit
  upper["b"] = upper["b"] / cost_per_unit

  # Create a list to hold the parameters
  params_list <- list(
    center = as.list(center),
    lower = as.list(lower),
    upper = as.list(upper)
  )

  # Return the list of parameters
  return(params_list)
}
