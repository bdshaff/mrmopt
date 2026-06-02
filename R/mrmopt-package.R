#' @keywords internal
"_PACKAGE"

## Suppress R CMD check NOTEs for variables used in dplyr/ggplot pipelines
utils::globalVariables(c(
  "center", "lower", "upper",
  "weekly_spend", "weekly_conversions", "lb", "ub", "x0", "cp",
  "x", "y", "channel",
  "model"
))

#' @importFrom stats as.formula predict sd smooth.spline
#' @importFrom bayesplot mcmc_trace
NULL
