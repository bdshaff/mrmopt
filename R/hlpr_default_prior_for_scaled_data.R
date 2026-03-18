#' Helper function to set default priors for scaled data
#'
#' This function sets default priors for the parameters of the four-parameter logistic model when the data has been scaled. The priors are based on the expected range of the parameters after scaling.
#' @param scale_method The method used for scaling the data. Currently, only "min_max" is supported.
#' @return A list of priors for the parameters of the four-parameter logistic model.
#' @importFrom brms prior


hlpr_default_prior_for_scaled_data <- function(scaled_data, x, y, scale_method) {

  if(scale_method == "min_max"){
    prior = c(
      brms::prior(normal(-4, 10), nlpar = "b", lb = -10, ub = 0.00),
      brms::prior(normal(0, 10), nlpar = "c", lb = -0.25, ub = 0.25),
      brms::prior(normal(1, 10), nlpar = "d", lb = 1.00, ub = 10.0),
      brms::prior(normal(0.50, 10), nlpar = "e", lb = 0.10, ub = 0.90)
    )
  }else if(scale_method == "std"){

    val_min_x <- min(scaled_data[[x]], na.rm = TRUE)
    val_max_x <- max(scaled_data[[x]], na.rm = TRUE)
    val_min_y <- min(scaled_data[[y]], na.rm = TRUE)
    val_max_y <- max(scaled_data[[y]], na.rm = TRUE)

    prior <- c(
      brms::prior(normal(-4, 10), nlpar = "b", lb = -10, ub = 0.00),
      brms::prior_string(paste0("normal(", val_min_x, ", 10)"), nlpar = "c", lb = val_min_y * 2.0, ub = val_min_y * 0.5),
      brms::prior_string(paste0("normal(", val_max_y, ", 10)"), nlpar = "d", lb = val_max_y, ub = 10.0),
      brms::prior_string("normal(0, 10)", nlpar = "e", lb = val_min_x * 0.9, ub = val_max_x * 0.9)
    )
  }else{
    stop("Scaling method not supported for setting default priors. Please provide a valid scaling method or specify priors manually.")
  }

  return(prior)

}
