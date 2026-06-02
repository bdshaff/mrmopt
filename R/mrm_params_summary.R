#' Generate an interpretive summary of response curve parameters
#'
#' Returns a 4-row tibble describing each response curve parameter (b, c, d, e)
#' with its name, plain-language description, and posterior center/lower/upper
#' estimates in original data units.
#'
#' @param mrm A fitted model object returned by \code{\link{fit_response}}.
#' @return A tibble with columns: \code{param}, \code{name}, \code{description},
#'   \code{center}, \code{lower}, \code{upper}.
#'
#' @export

mrm_params_summary <- function(mrm) {

  if (!brms::is.brmsfit(mrm)) {
    stop("mrm must be a fitted model object created by fit_response()", call. = FALSE)
  }

  p <- mrm_params(mrm, scaled = TRUE)

  tibble::tibble(
    param       = c("b", "c", "d", "e"),
    name        = c("Growth Rate", "Floor", "Ceiling", "Midpoint"),
    description = c(
      "Controls how quickly the curve rises (steepness of the S-curve)",
      "Baseline KPI level at zero spend (lower asymptote)",
      "Maximum achievable KPI at saturation (upper asymptote)",
      "Spend level at the inflection point (steepest growth)"
    ),
    center = c(p$center$b, p$center$c, p$center$d, p$center$e),
    lower  = c(p$lower$b,  p$lower$c,  p$lower$d,  p$lower$e),
    upper  = c(p$upper$b,  p$upper$c,  p$upper$d,  p$upper$e)
  )
}
