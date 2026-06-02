#' Package-level color palette for mrmopt plots
#'
#' A consistent set of named colors used across all plotting functions.
#'
#' @return A named character vector of hex colors.
#' @export
mrm_palette <- function() {
 c(
    response   = "#2171B5",
    ci_band    = "#C6DBEF",
    data_pts   = "#E6550D",
    ar         = "#2171B5",
    mr         = "#CB181D",
    cp         = "#6A51A3",
    current    = "#222222",
    range_fill = "#A1D99B",
    range_line = "#31A354",
    floor      = "#006D2C",
    ceiling    = "#006D2C",
    midpoint   = "#7B2D8E"
  )
}
