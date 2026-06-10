#' Create a prior specification for response curve fitting
#'
#' Provides a simplified, user-friendly interface for setting priors on
#' response curve parameters. Users specify constraints in intuitive,
#' scale-invariant terms rather than working with internal parameter names
#' and raw brms prior objects.
#'
#' @param midpoint_range A two-element numeric vector specifying the lower and
#'   upper bounds for the midpoint (inflection point) as fractions of the
#'   x-axis range. Values should be between 0 and 1. For example,
#'   `c(0.1, 0.9)` means the midpoint is expected to fall between the
#'   10th and 90th percentile of the x range. Default is `c(0.1, 0.9)`.
#' @param ceiling_max A multiplier on the observed maximum of the response
#'   variable, defining the upper bound for the upper asymptote (ceiling).
#'   For example, `ceiling_max = 3` means the ceiling can be at most
#'   3 times the observed max of y. Must be >= 1. Default is `5`.
#' @param floor_min A scalar specifying the lower bound for the lower
#'   asymptote (floor), in original data units. Default is `0`, meaning
#'   the response cannot go below zero.
#' @param anchor_strength A single positive numeric value controlling how
#'   tightly the floor parameter (`c`) is constrained around `floor_min`.
#'   Expressed as a fraction of the observed y range: `0.05` means the prior
#'   SD on `c` equals 5\% of the observed y range in scaled space. Smaller
#'   values produce narrower credible intervals at low spend. Set to `NULL`
#'   for loose behavior (broad prior, minimal constraint on the floor).
#'   Default is `0.05`.
#'
#' @return An object of class `mrm_prior` containing the prior specification.
#' @details
#' The response curve model has four parameters:
#' \describe{
#'   \item{floor (c)}{Lower asymptote — the minimum response value.}
#'   \item{ceiling (d)}{Upper asymptote — the maximum response value.}
#'   \item{steepness (b)}{Growth rate controlling how sharply the curve rises.}
#'   \item{midpoint (e)}{Inflection point — where the curve reaches half its range.}
#' }
#'
#' This function allows you to set constraints on the midpoint and ceiling,
#' which are the parameters users typically have the most intuition about.
#' Steepness is managed internally with broad, scale-aware defaults.
#' The floor defaults to zero but can be overridden for models with
#' non-zero baselines.
#'
#' For full control, you can bypass this interface and pass a raw
#' \code{\link[brms]{prior}} object directly to \code{\link{fit_response}}.
#'
#' @examples
#' # Default priors
#' mrmopt_prior()
#'
#' # Expect midpoint in the first half of the x range, ceiling up to 2x observed max
#' mrmopt_prior(midpoint_range = c(0.05, 0.5), ceiling_max = 2)
#'
#' # Allow a non-zero floor
#' mrmopt_prior(floor_min = 100)
#'
#' @export
mrmopt_prior <- function(midpoint_range = c(0.1, 0.9),
                      ceiling_max = 5,
                      floor_min = 0,
                      anchor_strength = 0.05) {

  # --- Validate midpoint_range ---
 if (!is.numeric(midpoint_range) || length(midpoint_range) != 2) {
    stop("`midpoint_range` must be a two-element numeric vector.", call. = FALSE)
  }
  if (any(midpoint_range < 0) || any(midpoint_range > 1)) {
    stop("`midpoint_range` values must be between 0 and 1 (x-axis fractions).", call. = FALSE)
  }
  if (midpoint_range[1] >= midpoint_range[2]) {
    stop("`midpoint_range[1]` must be less than `midpoint_range[2]`.", call. = FALSE)
  }

  # --- Validate ceiling_max ---
  if (!is.numeric(ceiling_max) || length(ceiling_max) != 1) {
    stop("`ceiling_max` must be a single numeric value.", call. = FALSE)
  }
  if (ceiling_max < 1) {
    stop("`ceiling_max` must be >= 1 (a multiplier on the observed max).", call. = FALSE)
  }

  # --- Validate floor_min ---
  if (!is.numeric(floor_min) || length(floor_min) != 1) {
    stop("`floor_min` must be a single numeric value.", call. = FALSE)
  }

  # --- Validate anchor_strength ---
  if (!is.null(anchor_strength)) {
    if (!is.numeric(anchor_strength) || length(anchor_strength) != 1) {
      stop("`anchor_strength` must be a single positive numeric value or NULL.",
           call. = FALSE)
    }
    if (anchor_strength <= 0) {
      stop("`anchor_strength` must be positive. Use NULL for loose (unconstrained) behavior.",
           call. = FALSE)
    }
  }

  structure(
    list(
      midpoint_range = midpoint_range,
      ceiling_max = ceiling_max,
      floor_min = floor_min,
      anchor_strength = anchor_strength
    ),
    class = "mrm_prior"
  )
}

