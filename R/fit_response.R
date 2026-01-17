#' Fit a response curve model using brms
#'
#' This function fits a response curve model using the brms package.
#'
#' @param data A data frame containing the data to be fitted.
#' @param x The name of the independent variable (predictor).
#' @param y The name of the dependent variable (response).
#' @param type The type of response curve model to fit. Options are "gompertz", "logistic", "weibull", or "exponential".
#' @param auto Logical indicating whether to automatically scale the data and set priors. Default is TRUE.
#' @param ... Additional arguments to be passed to the brms::brm function.
#' @return A fitted model object.
#' @details The function fits a response curve model using the specified type and returns the fitted model object.
#' @export


fit_response = function(data, x = NULL, y = NULL, auto = TRUE, type = "gompertz", ...){

  if (!(x %in% names(data)) || !(y %in% names(data))) {
    stop("Both 'x' and 'y' must be columns in the provided data.")
  }

  data <- data[,c(x,y)]

  if(auto){
    min_max_values = list(
      x_min = min(data[[x]], na.rm = TRUE),
      x_max = max(data[[x]], na.rm = TRUE),
      y_min = min(data[[y]], na.rm = TRUE),
      y_max = max(data[[y]], na.rm = TRUE)
    )

    #apply the min max scaling to both x and y and keep the min and max values for later use
    data[[x]] <- (data[[x]] - min(data[[x]], na.rm = TRUE)) / (max(data[[x]], na.rm = TRUE) - min(data[[x]], na.rm = TRUE))
    data[[y]] <- (data[[y]] - min(data[[y]], na.rm = TRUE)) / (max(data[[y]], na.rm = TRUE) - min(data[[y]], na.rm = TRUE))


    prior = c(
      prior(normal(-4, 10), nlpar = "b", lb = -10, ub = 0.0),
      prior(normal(0, 10), nlpar = "c", lb = 0.0, ub = 0.5),
      prior(normal(1, 10), nlpar = "d", lb = 1.0, ub = 10.0),
      prior(normal(0.6, 10), nlpar = "e", lb = 0.1, ub = 1.0)
    )
  }

  #rename the columns of data by removing any _ or . in the column names
  colnames(data) <- gsub("[_.]", "", colnames(data))

  rc_formula = define_response_form(type, colnames(data)[1], colnames(data)[2])
  print(rc_formula)

  if(auto){
    fit <- brms::brm(rc_formula, data = data, prior = prior, ...)
    fit$min_max_values = min_max_values
  } else{
    fit <- brms::brm(rc_formula, data = data, ...)
    fit$min_max_values = NULL
  }

  fit$rc_type = type

  return(fit)
}
