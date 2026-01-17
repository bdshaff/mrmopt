#' Extract parameters from a fitted model
#'
#' This function extracts the parameters from a fitted model object.
#'
#' @param rc_fit A fitted model object.
#' @param scaled A logical indicating whether the model was fitted on scaled data. Default is TRUE.
#' @return A list containing the center, lower, and upper bounds of the parameters.
#' @details The function extracts the parameters from the fitted model object and returns them in a list.
#'
#' @export

mrm_params <- function(rc_fit, scaled = TRUE) {

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
  if(!is.null(rc_fit$min_max_values) & scaled){
    #rescale the parameters back to the original scale
    x_min = rc_fit$min_max_values$x_min
    x_max = rc_fit$min_max_values$x_max
    y_min = rc_fit$min_max_values$y_min
    y_max = rc_fit$min_max_values$y_max

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
