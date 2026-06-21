#' Plot brms diagnostics for a fitted response model
#'
#' Produces trace plots for the four nonlinear parameters (b, c, d, e) and a
#' posterior predictive check, arranged vertically as a patchwork.
#'
#' Use this to assess MCMC convergence and model fit after calling
#' [fit_response()]. This is equivalent to `mrm_plot(mrm, type = "diagnostics")`.
#'
#' @param mrm A fitted model object of class \code{mrmfit}, returned by
#'   [fit_response()].
#' @return A patchwork plot object.
#'
#' @seealso [mrm_plot()] for the curve dashboard; [fit_response()] for model
#'   fitting.
#' @export

mrm_plot_diagnostics <- function(mrm) {

  if (!inherits(mrm, "mrmfit")) {
    stop("mrm must be a fitted model object created by fit_response()", call. = FALSE)
  }

  if (inherits(mrm, "mrmfit_hier_unit")) {
    stop(
      "MCMC diagnostics are not available for a per-unit view from ",
      "`as_mrmfit_list()` (it carries no posterior sampler state). Run ",
      "diagnostics on the parent hierarchical fit:\n",
      "  mrm_plot_hier(<fit>, type = \"diagnostics\")",
      call. = FALSE
    )
  }

  channel <- hlpr_channel_name(mrm)
  rc_type <- mrm$rc_type

  # Trace plots for the four nonlinear parameters.
  # Use posterior::as_draws_array() — brms::as.mcmc() is deprecated.
  # Subset to the four curve parameters and rename to short labels (b, c, d, e)
  # so strip text fits without truncation.
  draws <- posterior::as_draws_array(
    mrm,
    variable = c("b_b_Intercept", "b_c_Intercept", "b_d_Intercept", "b_e_Intercept")
  )
  draws <- posterior::rename_variables(
    draws,
    b = "b_b_Intercept", c = "b_c_Intercept",
    d = "b_d_Intercept", e = "b_e_Intercept"
  )

  trace_plot <- bayesplot::mcmc_trace(
    draws,
    facet_args = list(ncol = 1, strip.position = "left")
  ) +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = "Trace Plots")

  # Posterior predictive check
  pp_plot <- brms::pp_check(mrm, ndraws = 200) +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = "Posterior Predictive Check")

  combined <- patchwork::wrap_elements(trace_plot) / pp_plot +
    patchwork::plot_layout(heights = c(2, 1)) +
    patchwork::plot_annotation(
      title = paste0(channel, " \u2014 ", rc_type, " Diagnostics"),
      theme = ggplot2::theme(plot.title = ggplot2::element_text(face = "bold", size = 14))
    )

  combined
}
