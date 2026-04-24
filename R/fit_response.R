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
                        scale_method = "min_max",
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

  if(auto){
    scale_data = TRUE
    prior = NULL
  }

  data <- data[,c(x,y)]

  # if auto is true data will be scaled and a default prior will be set
  # if auto is false, but scale_data is true then data is scaled.
  # If prior is not provided then default prior is set. But prior can be provided
  if(scale_data){

    scaled_data_list <- hlpr_scale_data(data, x, y, scale_method)

    data <- scaled_data_list$scaled_data
    scale_values <- scaled_data_list$scale_values
    infer_xrange <- scaled_data_list$scaled_xrange

    if(is.null(prior)){
      prior = hlpr_default_prior_for_scaled_data(data, x, y, scale_method)
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

  rc_formula = hlpr_define_response_form(type, colnames(data)[1], colnames(data)[2])
  print(rc_formula)

  if(auto){
    fit <- brms::brm(
      rc_formula,
      data = data,
      prior = prior,
      chains = chains,
      iter = iter,
      warmup = warmup,
      control = control,
      ...
      )
    fit$scale_values = scale_values
    fit$scale_method = scale_method
  } else{
    fit <- brms::brm(
      rc_formula,
      data = data,
      chains = chains,
      iter = iter,
      warmup = warmup,
      control = control,
      ...
      )
    if(scale_data){
      fit$scale_values = scale_values
      fit$scale_method = scale_method
    }else{
      fit$scale_values = NULL
      fit$scale_method = NULL
    }
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
