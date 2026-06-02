#' Extract a clean channel name from a fitted model
#'
#' Derives a human-readable channel name from the original spend column name
#' stored on the fit object.
#'
#' @param mrm A fitted model object returned by \code{\link{fit_response}}.
#' @return A character string with the cleaned channel name.
#' @keywords internal

hlpr_channel_name <- function(mrm) {
  raw <- mrm$spend_col
  if (is.null(raw)) {
    # Fallback for models fit before spend_col was stored
    raw <- names(mrm$data)[names(mrm$data) != mrm$formula$resp]
  }
  cleaned <- sub("^spend[_.]?", "", raw)
  trimws(gsub("[_.]", " ", cleaned))
}
