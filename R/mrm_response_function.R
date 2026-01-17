#' Get the response function from a fitted model
#'
#' This function extracts the response function from a fitted model object. It allows you to specify which location's parameters to use (lower, center, or upper).
#' @param mrm A fitted model object returned by `fit_response()`.
#' @param location A string specifying which location's parameters to use. Must be one of "lower", "center", or "upper". Default is "center".
#' @param scaled A logical indicating whether the model was fitted on scaled data. Default is TRUE.
#' @return A function that takes a numeric vector of x values and returns the corresponding y values based on the specified response model and parameters.
#'
#' @export
mrm_response_function = function(mrm, location = "center", scaled = TRUE){

  if(!(location %in% c("lower", "center", "upper"))){
    stop("location must be one of 'left', 'center', or 'right'")
  }

  f = rm_dispatch(mrm$rc_type)
  p = mrm_params(mrm, scaled = scaled)[[location]]
  func = function(x) {
    f(x, b = p$b, c = p$c, d = p$d, e = p$e)
  }

  return(func)
}
