#' Get Ranges of Maximum Marginal Returns and Average Returns
#' This function computes the ranges of x values corresponding to the maximum marginal returns (MR)
#' and average returns (AR) for a list of marginal response models (MRMs).
#' @param mrm A list of fitted model objects (e.g., brmsfit objects).
#' @param xrange A numeric vector of length 2 specifying the range of x values to consider. If NULL, the range is determined from the data.
#' @param length.out An integer specifying the number of points to generate for the x-axis. Default is 1000.
#' @param scaled A logical value indicating whether to use scaled values for the calculations. Default is TRUE.
#' @return A data frame containing the channels and their corresponding x ranges for maximum MR and AR.
#' @details The function computes the MR and AR for each model in the list and identifies the x values where MR and AR are maximized. It returns a data frame with the channel names and their respective x ranges.
#' @export

mrm_returns_ranges <- function(mrm, xrange = NULL, length.out = 1000, scaled = TRUE, cost_per_unit = 1.0, response_rate = 1.0) {

  if(!is.brmsfit(mrm)){
    stop("mrm must be a fitted model object created by fit_response()")
  }

  if(!is.null(xrange) | length.out != 1000 | scaled != TRUE | cost_per_unit != 1.0 | response_rate != 1.0){
    response_df = mrm_infer(mrm, xrange = xrange, length.out = length.out, scaled = scaled, cost_per_unit = cost_per_unit, response_rate = response_rate)
  } else {
    response_df = mrm$response_df
  }

  #response_df = mrm_infer(mrm, xrange = xrange)
  x = names(response_df)[1]
  response_df$channel = x

  maxmr_df =
    response_df |>
    dplyr::filter(mr == max(mr, na.rm = TRUE)) |>
    select(channel, x, mr)

  maxar_df =
    response_df |>
    dplyr::filter(ar == max(ar, na.rm = TRUE)) |>
    select(channel, x, ar)

  x_range_df =
    maxmr_df |>
    dplyr::left_join(
      maxar_df, by = "channel", suffix = c("_min", "_max")
    )

  return(x_range_df)
}
