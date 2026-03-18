#' Get Weekly Spend helper function
#'
#' This function calculates the weekly spend based on the scaling method and values provided in the MRM object.
#' @param mrm An MRM object containing the scaling method, scaling values, and data.
#' @return A numeric value representing the weekly spend.
#' @details The function checks the scaling method used in the MRM object and calculates the weekly spend accordingly. If the scaling method is "min_max", it uses the mean of the data and the min-max scaling values to calculate the weekly spend. If the scaling method is "std", it uses the mean of the data and the standard deviation scaling values to calculate the weekly spend. If an invalid scaling method is provided, an error is raised.

hlpr_get_weekly_spend = function(mrm){
  scale_method <- mrm$scale_method
  scale_values <- mrm$scale_values
  data <- mrm$data

  if(scale_method == "min_max"){
    s <- mean(data[[2]]) * (scale_values$x_max - scale_values$x_min) + scale_values$x_min
  }else if(scale_method == "std"){
    s <- mean(data[[2]]) * (scale_values$x_sd) + scale_values$x_mean
  }else{
    stop("Invalid scale method. Please choose either 'min_max' or 'std'.")
  }
  return(s)
}
