#' Plot method for opt_mix_result objects
#'
#' Dispatches to various visualization functions for optimization results.
#' Supports response curves, allocation comparisons, posterior distributions,
#' and more.
#'
#' @param x An `opt_mix_result` object returned by [opt_mix()].
#' @param type Type of plot. One of:
#'   - `"allocation"` (default): Current vs optimal spend per channel
#'   - `"kpi"`: Current vs optimal KPI per channel
#'   - `"comparison"`: Dumbbell chart (current → optimal)
#'   - `"posterior"`: Posterior distribution of optimal spend (posterior method only)
#'   - `"curves"`: Response curves with current and optimal points
#'   - `"returns"`: Average and marginal return curves with current and optimal points
#' @param ... Additional arguments passed to the plot function.
#'
#' @return A ggplot object (or composite plot for some types).
#' @export

plot.opt_mix_result <- function(x, type = c("allocation", "kpi", "comparison",
                                              "posterior", "curves", "returns"),
                                ...) {
  type <- match.arg(type)

  switch(type,
    allocation   = opt_plot_allocation(x, metric = "spend", ...),
    kpi          = opt_plot_allocation(x, metric = "kpi", ...),
    comparison   = opt_plot_comparison(x, ...),
    posterior    = opt_plot_posterior(x, ...),
    curves       = opt_plot_curves(x, ...),
    returns      = opt_plot_returns(x, ...)
  )
}
