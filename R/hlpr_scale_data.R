#' Helper function to scale the data for model prep
#'
#' This function scales the data using min-max scaling and also calculates the inferred x-range for the model. It returns a list containing the scaled data, the inferred x-range, and the min-max values used for scaling.
#' @param data The input data frame containing the x and y variables to be scaled.
#' @return A list containing the scaled data, the inferred x-range, and the min-max values used for scaling.

hlpr_scale_data = function(data, x, y, scale_method){
  if(scale_method == "std"){
    #calculate mean and sd for x and y
    mean_sd_values = list(
      x_mean = mean(data[[x]], na.rm = TRUE),
      x_sd = sd(data[[x]], na.rm = TRUE),
      y_mean = mean(data[[y]], na.rm = TRUE),
      y_sd = sd(data[[y]], na.rm = TRUE)
    )

    infer_xrange <- c(min(data[[x]], na.rm = TRUE), 2*max(data[[x]], na.rm = TRUE))

    #apply the standard scaling to both x and y and keep the mean and sd values for later use
    data[[x]] <- (data[[x]] - mean(data[[x]], na.rm = TRUE)) / sd(data[[x]], na.rm = TRUE)
    data[[y]] <- (data[[y]] - mean(data[[y]], na.rm = TRUE)) / sd(data[[y]], na.rm = TRUE)

    infer_xrange <- c(min(data[[x]], na.rm = TRUE), 2*max(data[[x]], na.rm = TRUE))

    res = list(
      scaled_data = data,
      scaled_xrange = infer_xrange,
      scale_values = mean_sd_values
    )
  }else if(scale_method == "min_max"){
  min_max_values = list(
    x_min = min(data[[x]], na.rm = TRUE),
    x_max = max(data[[x]], na.rm = TRUE),
    y_min = min(data[[y]], na.rm = TRUE),
    y_max = max(data[[y]], na.rm = TRUE)
  )

  infer_xrange = c(-min_max_values$x_min/(min_max_values$x_max - min_max_values$x_min), 2)

  #apply the min max scaling to both x and y and keep the min and max values for later use
  data[[x]] <- (data[[x]] - min(data[[x]], na.rm = TRUE)) / (max(data[[x]], na.rm = TRUE) - min(data[[x]], na.rm = TRUE))
  data[[y]] <- (data[[y]] - min(data[[y]], na.rm = TRUE)) / (max(data[[y]], na.rm = TRUE) - min(data[[y]], na.rm = TRUE))

  res = list(
    scaled_data = data,
    scaled_xrange = infer_xrange,
    scale_values = min_max_values
  )
  }else{
    stop("Invalid scale method. Please choose either 'min_max' or 'std'.")
  }
}
