#' Plot a fitted response model
#'
#' Produces either a three-panel curve dashboard or brms model diagnostics.
#'
#' The **dashboard** (default) composes three individual panel functions into a
#' single patchwork layout:
#' \enumerate{
#'   \item [mrm_plot_response()] — response curve with credible interval
#'   \item [mrm_plot_return()] — absolute and marginal return curves
#'   \item [mrm_plot_costper()] — cost per KPI curve
#' }
#'
#' Use `mrm_plot()` for a quick overview. Use the individual `mrm_plot_*()`
#' functions when you need a single panel, want to control parameters not
#' exposed here (e.g., `xrange`, `length.out`), or need to compose your own
#' multi-panel layout. For convergence diagnostics, use
#' [mrm_plot_diagnostics()].
#'
#' @param mrm A fitted model object of class \code{mrmfit}, returned by
#'   [fit_response()].
#' @param type Character; \code{"dashboard"} (default) for the three-panel
#'   curve display, or \code{"diagnostics"} for brms convergence plots
#'   (trace plots + posterior predictive check). For diagnostics, prefer
#'   calling [mrm_plot_diagnostics()] directly.
#' @param x_var Character; \code{"spend"} (default) or \code{"units"} for the
#'   x-axis variable.
#' @param show_mr Logical; overlay the marginal return curve on the response
#'   panel? Default is \code{FALSE}.
#' @param markup Logical; show range/current annotations? Default is
#'   \code{TRUE}.
#' @param interval Type of credible interval. \code{"prediction"} (default)
#'   includes observation noise. \code{"confidence"} shows uncertainty about
#'   the mean curve only (tighter bands).
#' @param ... Additional arguments (currently unused).
#' @return A patchwork plot object.
#'
#' @seealso [mrm_plot_response()], [mrm_plot_return()], [mrm_plot_costper()]
#'   for individual panels; [mrm_plot_diagnostics()] for convergence plots;
#'   [mrms_plot_compare()] for comparing multiple fitted models.
#' @export

mrm_plot <- function(mrm,
                     type = c("dashboard", "diagnostics"),
                     x_var = c("spend", "units"),
                     show_mr = FALSE,
                     markup = TRUE,
                     interval = c("prediction", "confidence"),
                     ...) {

  if (!inherits(mrm, "mrmfit")) {
    stop("mrm must be a fitted model object created by fit_response()", call. = FALSE)
  }

  type     <- match.arg(type)
  x_var    <- match.arg(x_var)
  interval <- match.arg(interval)

  if (type == "diagnostics") {
    return(mrm_plot_diagnostics(mrm))
  }

  # --- Dashboard: response + return + costper ---
  p1 <- mrm_plot_response(mrm, x_var = x_var, show_mr = show_mr,
                           markup = markup, interval = interval)
  p2 <- mrm_plot_return(mrm, x_var = x_var, markup = markup,
                         interval = interval)
  p3 <- mrm_plot_costper(mrm, x_var = x_var, markup = markup,
                          interval = interval)

  channel <- hlpr_channel_name(mrm)
  rc_type <- mrm$rc_type

  # Use wrap_plots() instead of the / operator to avoid S7 Ops dispatch
  # conflict in R 4.5+ which intercepts /.gg before patchwork can handle it.
  combined <- patchwork::wrap_plots(p1, p2, p3, ncol = 1, heights = c(2, 1, 1)) +
    patchwork::plot_annotation(
      title = paste0(channel, " \u2014 ", rc_type),
      theme = ggplot2::theme(plot.title = ggplot2::element_text(face = "bold", size = 14))
    )

  # Suppress individual panel titles to avoid redundancy with the shared title
  combined[[1]] <- combined[[1]] + ggplot2::labs(title = NULL)
  combined[[2]] <- combined[[2]] + ggplot2::labs(title = NULL)
  combined[[3]] <- combined[[3]] + ggplot2::labs(title = NULL)

  combined
}
