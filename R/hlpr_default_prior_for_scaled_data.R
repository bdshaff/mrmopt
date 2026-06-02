#' Helper function to set default priors for scaled data
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function is deprecated in favor of [mrm_prior()] and the internal
#' [hlpr_resolve_prior()]. It is retained for backward compatibility and
#' now delegates to the new prior resolution system.
#'
#' @param scaled_data The scaled data frame.
#' @param x Name of the x column.
#' @param y Name of the y column.
#' @param scale_method The method used for scaling the data.
#' @param type The response form type. Default is \code{"gompertz"}.
#' @param scale_values List of scaling parameters. Required for the new
#'   prior system. If NULL, a minimal set is constructed from the data,
#'   which may not be fully accurate.
#' @return A list of priors for the four-parameter model.
#' @importFrom brms prior
#' @keywords internal

hlpr_default_prior_for_scaled_data <- function(scaled_data, x, y, scale_method,
                                                type = "gompertz",
                                                scale_values = NULL) {

  # If no scale_values provided, construct approximate values from scaled data
  # This preserves backward compatibility but may be less accurate

  if (is.null(scale_values)) {
    if (scale_method == "min_max") {
      scale_values <- list(
        x_min = 0, x_max = 1,
        y_min = 0, y_max = 1
      )
    } else if (scale_method == "std") {
      scale_values <- list(
        x_mean = 0, x_sd = 1,
        y_mean = 0, y_sd = 1
      )
    }
  }

  hlpr_resolve_prior(
    mrm_prior = mrm_prior(),
    scaled_data = scaled_data,
    x = x, y = y,
    scale_method = scale_method,
    scale_values = scale_values,
    type = type
  )
}
