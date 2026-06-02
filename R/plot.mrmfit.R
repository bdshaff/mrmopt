#' Plot method for mrmfit objects
#'
#' Produces either a three-panel curve dashboard (response, AR/MR, cost per KPI)
#' or brms model diagnostics (trace plots and posterior predictive check).
#'
#' @param x A fitted model object of class \code{mrmfit}.
#' @param type Character; \code{"dashboard"} (default) for the three-panel
#'   curve display, or \code{"diagnostics"} for brms convergence plots.
#' @param x_var Character; \code{"spend"} (default) or \code{"units"}.
#' @param show_mr Logical; overlay MR on the response panel? Default is FALSE.
#' @param markup Logical; show range/current annotations? Default is TRUE.
#' @param ... Additional arguments (currently unused).
#' @return A patchwork plot object (invisibly for diagnostics).
#' @export

plot.mrmfit <- function(x,
                        type = c("dashboard", "diagnostics"),
                        x_var = c("spend", "units"),
                        show_mr = FALSE,
                        markup = TRUE,
                        ...) {

  type <- match.arg(type)
  x_var <- match.arg(x_var)

  if (type == "diagnostics") {
    return(hlpr_plot_diagnostics(x))
  }

  # --- Dashboard: response + return + costper ---
  p1 <- mrm_plot_response(x, x_var = x_var, show_mr = show_mr, markup = markup)
  p2 <- mrm_plot_return(x, x_var = x_var, markup = markup)
  p3 <- mrm_plot_costper(x, x_var = x_var, markup = markup)

  channel <- hlpr_channel_name(x)
  rc_type <- x$rc_type

  combined <- p1 / p2 / p3 +
    patchwork::plot_layout(heights = c(2, 1, 1)) +
    patchwork::plot_annotation(
      title = paste0(channel, " \u2014 ", rc_type),
      theme = ggplot2::theme(plot.title = ggplot2::element_text(face = "bold", size = 14))
    )

  # Suppress individual titles to avoid redundancy with the shared title
  combined[[1]] <- combined[[1]] + ggplot2::labs(title = NULL)
  combined[[2]] <- combined[[2]] + ggplot2::labs(title = NULL)
  combined[[3]] <- combined[[3]] + ggplot2::labs(title = NULL)

  combined
}


#' Plot brms diagnostics for an mrmfit object
#'
#' Produces trace plots and a posterior predictive check arranged vertically.
#'
#' @param mrm A fitted model object of class \code{mrmfit}.
#' @return A patchwork plot object.
#' @keywords internal

hlpr_plot_diagnostics <- function(mrm) {

  channel <- hlpr_channel_name(mrm)
  rc_type <- mrm$rc_type

  # Trace plots for the nonlinear parameters
  # Rename chains to short labels so strip text fits without truncation
  draws_raw <- brms::as.mcmc(mrm, pars = c("b_b_Intercept", "b_c_Intercept",
                                             "b_d_Intercept", "b_e_Intercept"))
  draws_labeled <- lapply(draws_raw, function(chain) {
    colnames(chain) <- c("b", "c", "d", "e")
    chain
  })
  class(draws_labeled) <- "mcmc.list"

  trace_plot <- bayesplot::mcmc_trace(
    draws_labeled,
    facet_args = list(ncol = 1, strip.position = "left")
  ) +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = "Trace Plots")

  # Posterior predictive check
  pp_plot <- brms::pp_check(mrm, ndraws = 200) +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = "Posterior Predictive Check")

  combined <- trace_plot / pp_plot +
    patchwork::plot_layout(heights = c(2, 1)) +
    patchwork::plot_annotation(
      title = paste0(channel, " \u2014 ", rc_type, " Diagnostics"),
      theme = ggplot2::theme(plot.title = ggplot2::element_text(face = "bold", size = 14))
    )

  combined
}
