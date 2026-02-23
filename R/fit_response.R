#' Fit a response curve model using brms
#'
#' This function fits a response curve model using the brms package.
#'
#' @param data A data frame containing the data to be fitted.
#' @param x The name of the independent variable (predictor).
#' @param y The name of the dependent variable (response).
#' @param type The type of response curve model to fit. Options are "gompertz", "logistic", "weibull", or "exponential".
#' @param auto Logical indicating whether to automatically scale the data and set priors. Default is TRUE.
#' @param infer_xrange Optional range of x values for inference. If NULL, uses the range of x in the data.
#' @param infer_length The number of points to generate for inference. Default is 1000.
#' @param infer_scaled Logical indicating whether to return scaled inference results. Default is TRUE.
#' @param cost_per_unit The cost per unit of the independent variable. Default is 1.0.
#' @param response_rate The response rate to be used in return calculations. Default is 1.0.
#' @param ... Additional arguments to be passed to the brms::brm function.
#' @return A fitted model object.
#' @details The function fits a response curve model using the specified type and returns the fitted model object.
#' @export


fit_response = function(data, x = NULL, y = NULL,
                        auto = TRUE,
                        type = "gompertz",
                        scale_data = TRUE,
                        prior = NULL,
                        chains = 4,
                        iter = 4000,
                        warmup = 1000,
                        control = list(adapt_delta = 0.95),
                        infer_xrange = NULL,
                        infer_length = 1000,
                        cost_per_unit = 1.0,
                        response_rate = 1.0,
                        ...){

  if (!(x %in% names(data)) || !(y %in% names(data))) {
    stop("Both 'x' and 'y' must be columns in the provided data.")
  }

  data <- data[,c(x,y)]

  if(auto){
    scale_data = TRUE
    prior = NULL
  }

  # if auto is true data will be scaled and a default prior will be set
  # if auto is false, but scale_data is true then data is scaled. If prior is not provided then default prior is set. But prior can be provided
  if(scale_data){
    min_max_values = list(
      x_min = min(data[[x]], na.rm = TRUE),
      x_max = max(data[[x]], na.rm = TRUE),
      y_min = min(data[[y]], na.rm = TRUE),
      y_max = max(data[[y]], na.rm = TRUE)
    )

    #apply the min max scaling to both x and y and keep the min and max values for later use
    data[[x]] <- (data[[x]] - min(data[[x]], na.rm = TRUE)) / (max(data[[x]], na.rm = TRUE) - min(data[[x]], na.rm = TRUE))
    data[[y]] <- (data[[y]] - min(data[[y]], na.rm = TRUE)) / (max(data[[y]], na.rm = TRUE) - min(data[[y]], na.rm = TRUE))

    if(is.null(prior)){
      prior = c(
        prior(normal(-4, 10), nlpar = "b", lb = -10, ub = 0.00),
        prior(normal(0, 10), nlpar = "c", lb = -0.25, ub = 0.25),
        prior(normal(1, 10), nlpar = "d", lb = 1.00, ub = 10.0),
        prior(normal(0.50, 10), nlpar = "e", lb = 0.10, ub = 0.90)
      )
    }else{
      prior = prior
    }

  }else{
    #if auto is false and scale data is false we can't set a default prior and a prior is required
    # test that prior is is not null and that it is of the correct expected format
    if(is.null(prior)){
      stop("If auto is false and scale_data is false, a prior must be provided.")
    }else{
      #test that prior is is.brmsprior
      if(!inherits(prior, "brmsprior")){
        stop("The provided prior is not of class 'brmsprior'. Please provide a valid prior.")
      }
      #test that prior has prior$nlpar that contains b, c, d, and e
      if(!all(c("b", "c", "d", "e") %in% prior$nlpar)){
        stop("The provided prior does not contain all required parameters (b, c, d, e). Please provide a valid prior.")
      }
    }
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
  fit$response_df =
    mrm_infer(
      fit,
      xrange = infer_xrange,
      length.out = infer_length,
      scaled = scale_data,
      cost_per_unit = cost_per_unit,
      response_rate = response_rate
      )
  fit$returnes_ranges = mrm_returns_ranges(fit, cost_per_unit = cost_per_unit, response_rate = response_rate)
  fit$cost_per_unit = cost_per_unit
  fit$response_rate = response_rate

  return(fit)
}
