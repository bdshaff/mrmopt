#' Print method for mrm_prior objects
#'
#' @param x An object of class \code{mrm_prior}, created by [mrmopt_prior()].
#' @param ... Currently unused.
#' @return \code{x} invisibly.
#' @export

print.mrm_prior <- function(x, ...) {
  cat("mrm_prior specification:\n")
  cat("  midpoint range : [", x$midpoint_range[1], ", ", x$midpoint_range[2],
      "] (x-axis fraction)\n", sep = "")
  cat("  ceiling max    :", x$ceiling_max, "x observed max of y\n")
  cat("  floor min      :", x$floor_min, "(original data units)\n")
  if (!is.null(x$anchor_strength)) {
    cat("  anchor strength:", x$anchor_strength, "(fraction of y range)\n")
  } else {
    cat("  anchor strength: NULL (loose)\n")
  }
  invisible(x)
}
