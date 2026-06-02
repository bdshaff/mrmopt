#' Interpolate response metrics at an arbitrary spend level
#'
#' Uses linear interpolation on the pre-computed `response_df` to obtain
#' KPI, AR, MR, and CP at a given spend value. Avoids re-fitting or
#' re-predicting from the brms model.
#'
#' @param mrm An `mrmfit` object with a `$response_df`.
#' @param spend Numeric; the spend value to evaluate at (original units).
#' @return A named list with elements `kpi`, `ar`, `mr`, `cp`.
#' @keywords internal

hlpr_opt_metrics <- function(mrm, spend) {
  rdf <- mrm$response_df
  x_col <- names(rdf)[1]
  x_vals <- rdf[[x_col]]

  list(
    kpi = stats::approx(x_vals, rdf$center, xout = spend, rule = 2)$y,
    ar  = stats::approx(x_vals, rdf$ar,     xout = spend, rule = 2)$y,
    mr  = stats::approx(x_vals, rdf$mr,     xout = spend, rule = 2)$y,
    cp  = stats::approx(x_vals, rdf$cp,     xout = spend, rule = 2)$y
  )
}
