#' Print method for opt_mix_result objects
#'
#' Displays a formatted summary of the optimization result by calling
#' [opt_summary()].
#'
#' @param x An `opt_mix_result` object returned by [opt_mix()].
#' @param ... Additional arguments passed to [opt_summary()].
#' @return The object `x`, invisibly.
#' @export

print.opt_mix_result <- function(x, ...) {
  opt_summary(x, ...)
  invisible(x)
}
