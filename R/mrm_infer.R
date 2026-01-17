#' Infer response from a fitted model
#'
#' This function infers the response from a fitted model object.
#' @param mrm A fitted model object.
#' @param xrange A numeric vector of length 2 specifying the range of x values for prediction. Default is NULL, which uses the range of x in the data.
#' @param length.out An integer specifying the number of points to predict. Default is 1000.
#' @param scaled A logical indicating whether the model was fitted on scaled data. Default is TRUE.
#' @return A data frame containing the predicted response values and the model response.
#' @details The function infers the response from the fitted model object and returns a data frame with the predicted response values and the model response.
#' @export

mrm_infer = function(mrm, xrange = NULL, length.out = 1000, scaled = TRUE){

  #Extract necessary components from the model
  rc_type = mrm$rc_type
  rc_data = mrm$data
  y = mrm$formula$resp
  x = names(rc_data)[names(rc_data) != y]
  response_params <- mrm_params(mrm, scaled = scaled)

  if(is.null(xrange)){
    xrange = c(0, 2 * max(rc_data[,x]))
  }

  if (!is.numeric(xrange) || length(xrange) != 2 || xrange[1] >= xrange[2]) {
    stop("xrange must be a numeric vector of length 2 with the first element less than the second.")
  }

  # Generate model prediction/extrapolation data frame
  xseq = seq(xrange[1], xrange[2], length.out = length.out)
  new_df = data.frame(x = xseq)
  colnames(new_df) = x

  pred_df = as.data.frame(predict(mrm, newdata = new_df))
  pred_df$Est.Error = smooth.spline(pred_df$Est.Error)$y

  # Rescale back to original scale if necessary
  if(!is.null(mrm$min_max_values) & scaled){

    x_min = mrm$min_max_values$x_min
    x_max = mrm$min_max_values$x_max
    y_min = mrm$min_max_values$y_min
    y_max = mrm$min_max_values$y_max

    xseq = xseq * (x_max - x_min) + x_min
    new_df[[x]] = new_df[[x]] * (x_max - x_min) + x_min

    for(col in colnames(pred_df)){
      if(grepl("Est.Error", col)){
        pred_df[[col]] = pred_df[[col]] * (y_max - y_min)
      } else {
        pred_df[[col]] = pred_df[[col]] * (y_max - y_min) + y_min
      }
    }
  }

  # Compute model response using the extracted parameters
  model_response = purrr::map_dfc(response_params, ~response(xseq, .x, type = rc_type))
  model_response$lower = model_response$center - 1.96 * pred_df$Est.Error
  model_response$upper = model_response$center + 1.96 * pred_df$Est.Error
  model_response$lower  = if_else(model_response$lower < 0, 0, model_response$lower)

  # Combine all results into a single data frame
  colnames(pred_df) = paste0(y,"_", colnames(pred_df))
  colnames(model_response) = paste0(y,"_",rc_type,"_", colnames(model_response))
  res_df = cbind(new_df, pred_df, model_response)

  # Calculate additional metrics: absolute response (ar) and marginal response (mr)
  y = paste0(y,"_",rc_type,"_","center")
  res_df$ar = (res_df[[y]] - min(res_df[[y]]))/res_df[[x]]
  res_df$mr = c(NA, diff(res_df[[y]])/diff(res_df[[x]]))

  y = stringr::str_replace(y,"center","lower")
  res_df$ar_lower = (res_df[[y]] - min(res_df[[y]]))/res_df[[x]]
  res_df$mr_lower = c(NA, diff(res_df[[y]])/diff(res_df[[x]]))

  y = stringr::str_replace(y,"lower","upper")
  res_df$ar_upper = (res_df[[y]] - min(res_df[[y]]))/res_df[[x]]
  res_df$mr_upper = c(NA, diff(res_df[[y]])/diff(res_df[[x]]))

  return(res_df)
}
