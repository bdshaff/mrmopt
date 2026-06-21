#' Extract response curve parameters from a fitted model
#'
#' Returns a 4-row tibble describing each response curve parameter (b, c, d, e)
#' with its name, plain-language description, and posterior center/lower/upper
#' estimates in original data units.
#'
#' @param mrm A fitted model object returned by [fit_response()].
#' @return A tibble with columns: \code{param}, \code{name}, \code{description},
#'   \code{center}, \code{lower}, \code{upper}.
#'
#' @seealso [mrm_summary()] for a full channel-level summary,
#'   [fit_response()] for model fitting.
#' @export

mrm_params <- function(mrm) {

  if (!inherits(mrm, "mrmfit")) {
    stop("mrm must be a fitted model object created by fit_response()", call. = FALSE)
  }
  if (inherits(mrm, "mrmfit_hier_unit")) hlpr_unit_view_warn("mrm_params")

  p <- hlpr_params(mrm, scaled = TRUE)

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
