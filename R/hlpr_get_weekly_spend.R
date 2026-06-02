#' Get Weekly Spend helper function
#'
#' This function calculates the weekly spend based on the scaling method and values provided in the MRM object.
#' @param mrm An MRM object containing the scaling method, scaling values, and data.
#' @return A numeric value representing the weekly spend.
#' @details The function checks the scaling values stored in the MRM object and
#'   calculates the weekly spend accordingly. Dispatches on the keys present in
#'   scale_values rather than scale_method, to support log-based forms that use
#'   ratio scaling for x regardless of the user's scale_method choice.

hlpr_get_weekly_spend = function(mrm){
  sv <- mrm$scale_values
  data <- mrm$data
  x_offset <- if (!is.null(sv$x_offset)) sv$x_offset else 0

  # Exclude synthetic anchor (0,0) row if present
  anchor_zero <- attr(mrm$summary, "anchor_zero")
  if (!is.null(anchor_zero) && isTRUE(anchor_zero)) {
    data <- utils::head(data, -1)
  }

  if (!is.null(sv$x_min) && !is.null(sv$x_max)) {
    x_range <- sv$x_max - sv$x_min
    s <- mean(data[[2]]) * x_range + sv$x_min - x_offset
  } else if (!is.null(sv$x_mean) && !is.null(sv$x_sd)) {
    s <- mean(data[[2]]) * sv$x_sd + sv$x_mean - x_offset
  } else {
    stop("Could not determine scaling method from scale_values.")
  }

  return(s)
}
