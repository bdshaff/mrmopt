#' Print method for mrmfit objects
#'
#' Displays a formatted summary of a fitted response curve model, including
#' current performance, parameters, recommended spend range, and week
#' distribution.
#'
#' @param x An mrmfit object returned by \code{\link{fit_response}}.
#' @param ... Additional arguments (ignored).
#' @return The object \code{x}, invisibly.
#'
#' @export

print.mrmfit <- function(x, ...) {

  s  <- x$summary
  ps <- x$params_summary

  # If summary or params_summary are missing (e.g. older model), fall back to brms
  if (is.null(s) || is.null(ps)) {
    NextMethod()
    return(invisible(x))
  }

  # Delegate all formatting to print.mrm_summary, then add the mrmfit footer
  print(s)
  cat("\nUse summary(x) for brms model diagnostics.\n")

  invisible(x)
}


# Simple rule-drawing helper (avoids cli dependency)
cli_rule <- function(title = "") {
  width <- getOption("width", 70)
  if (nchar(title) > 0) {
    title_str <- paste0(" ", title, " ")
    n_dash <- max(width - nchar(title_str) - 2, 4)
    left <- 2
    right <- n_dash - left
    paste0(strrep("-", left), title_str, strrep("-", right))
  } else {
    strrep("-", width)
  }
}
