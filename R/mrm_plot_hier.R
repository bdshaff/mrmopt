#' Plot a hierarchical response curve fit
#'
#' Produces either a multi-panel dashboard or brms convergence diagnostics for a
#' model fitted with \code{\link{fit_response_hier}}, analogous to
#' \code{\link{mrm_plot}}.
#'
#' The \strong{dashboard} (default) composes:
#' \itemize{
#'   \item one response-curve panel per level of the hierarchy
#'     (\code{\link{mrm_plot_hier_response}}, one for each entry of
#'     \code{names(mrm$params_hier$levels)});
#'   \item one shrinkage panel for each of the shape/scale parameters
#'     \code{e}, \code{b}, \code{d} (\code{\link{mrm_plot_hier_shrinkage}}).
#' }
#'
#' The \strong{diagnostics} view (\code{type = "diagnostics"}) shows trace plots
#' for the channel-level parameters and the partial-pooling SDs, plus a
#' posterior predictive check (\code{\link{mrm_plot_hier_diagnostics}}).
#'
#' Use the standalone \code{mrm_plot_hier_*()} functions when you want a single
#' panel or finer control.
#'
#' @param mrm A fitted \code{mrmfit_hier} object from
#'   \code{\link{fit_response_hier}}.
#' @param type Character; \code{"dashboard"} (default) or \code{"diagnostics"}.
#' @param x_var Character; \code{"spend"} (default) or \code{"units"} for the
#'   x-axis of the response panels.
#' @param ... Additional arguments (currently unused).
#' @return A \code{patchwork} plot object.
#'
#' @seealso \code{\link{mrm_plot_hier_response}},
#'   \code{\link{mrm_plot_hier_shrinkage}},
#'   \code{\link{mrm_plot_hier_diagnostics}}, \code{\link{fit_response_hier}}
#' @export

mrm_plot_hier <- function(mrm,
                          type = c("dashboard", "diagnostics"),
                          x_var = c("spend", "units"),
                          ...) {

  if (!inherits(mrm, "mrmfit_hier")) {
    stop("mrm must be a fitted model object created by fit_response_hier()",
         call. = FALSE)
  }

  type  <- match.arg(type)
  x_var <- match.arg(x_var)

  if (type == "diagnostics") {
    return(mrm_plot_hier_diagnostics(mrm))
  }

  # --- Dashboard: one response panel per level + one shrinkage panel per param ---
  ph <- if (is.null(mrm$params_hier)) hlpr_params_hier(mrm) else mrm$params_hier
  level_terms <- names(ph$levels)
  shrink_pars <- c("e", "b", "d")

  # Short per-panel titles (the descriptive subtitles from the standalone
  # functions are dropped in the dashboard to avoid overlap/redundancy; the
  # shared conventions are stated once in the annotation subtitle below).
  resp_panels <- lapply(level_terms, function(lv) {
    mrm_plot_hier_response(mrm, level = lv, x_var = x_var) +
      ggplot2::labs(title = lv, subtitle = NULL)
  })

  # Shrinkage panels share one y-axis (a common unit order) and one legend.
  # Order the shared axis by the first shrinkage parameter; show the y-axis
  # labels only on the leftmost panel and collect the single size legend.
  innermost  <- paste(mrm$group, collapse = ":")
  lvl_tbl    <- ph$levels[[innermost]]
  common_ids <- lvl_tbl$id[order(lvl_tbl[[shrink_pars[1]]])]

  shrink_titles <- c(e = "Midpoint (e)", b = "Growth Rate (b)", d = "Ceiling (d)")
  shrink_panels <- lapply(seq_along(shrink_pars), function(k) {
    p <- shrink_pars[k]
    pl <- mrm_plot_hier_shrinkage(mrm, param = p) +
      ggplot2::labs(title = shrink_titles[[p]], subtitle = NULL) +
      ggplot2::scale_y_discrete(limits = common_ids)
    if (k > 1) {
      pl <- pl + ggplot2::theme(
        axis.text.y  = ggplot2::element_blank(),
        axis.ticks.y = ggplot2::element_blank()
      )
    }
    pl
  })

  top <- patchwork::wrap_plots(resp_panels, nrow = 1)
  bot <- patchwork::wrap_plots(shrink_panels, nrow = 1, guides = "collect")

  patchwork::wrap_plots(top, bot, ncol = 1) +
    patchwork::plot_annotation(
      title    = paste0(mrm$spend_col, " - ", mrm$rc_type),
      subtitle = "Response curves by level (channel mean dashed) - parameter shrinkage (point size = observed weeks)",
      theme = ggplot2::theme(
        plot.title = ggplot2::element_text(face = "bold", size = 14))
    )
}


#' Per-level response curves from a hierarchical fit
#'
#' Plots one response curve per unit at a chosen level of the hierarchy,
#' overlaid with the channel-level mean curve (dashed). Shows how partial
#' pooling spreads the units around the channel mean.
#'
#' @param mrm A fitted \code{mrmfit_hier} object.
#' @param level Optional cumulative grouping term selecting which level's units
#'   to plot (e.g. \code{"subtype"} or \code{"subtype:station"}). Defaults to the
#'   innermost level.
#' @param x_var Character; \code{"spend"} (default) or \code{"units"}.
#' @return A ggplot object.
#'
#' @seealso \code{\link{mrm_plot_hier}}, \code{\link{mrm_plot_hier_shrinkage}}
#' @export
mrm_plot_hier_response <- function(mrm, level = NULL, x_var = c("spend", "units")) {

  if (!inherits(mrm, "mrmfit_hier")) {
    stop("mrm must be a fitted model object created by fit_response_hier()",
         call. = FALSE)
  }
  x_var <- match.arg(x_var)
  if (is.null(level)) level <- paste(mrm$group, collapse = ":")
  pal    <- mrmopt_palette()
  ptitle <- paste0(mrm$spend_col, " - ", mrm$rc_type)

  rdf <- if (!is.null(mrm$response_df)) mrm$response_df else mrm_infer_hier(mrm)

  x_col <- names(rdf)[1]
  has_units <- !is.null(mrm$units_col) && !is.null(mrm$cost_per_unit)

  if (x_var == "units") {
    if (!has_units) stop("Units not available; fit with a `units` column.", call. = FALSE)
    if (!"units" %in% names(rdf)) rdf$units <- rdf[[x_col]] / mrm$cost_per_unit
    x_plot <- "units"; x_lab <- "Units"
    x_scale <- ggplot2::scale_x_continuous(labels = scales::comma)
  } else {
    x_plot <- x_col; x_lab <- "Spend"
    x_scale <- ggplot2::scale_x_continuous(labels = scales::dollar_format())
  }

  units_df <- rdf[rdf$level == level, , drop = FALSE]
  if (nrow(units_df) == 0) {
    stop("Level '", level, "' not found in the fit.", call. = FALSE)
  }
  channel_df <- rdf[rdf$id == "(channel)", , drop = FALSE]

  p <- ggplot2::ggplot(
    units_df,
    ggplot2::aes(!!ggplot2::sym(x_plot), .data$center, color = .data$id)
  ) +
    ggplot2::geom_line(linewidth = 0.7, alpha = 0.85)

  if (nrow(channel_df) > 0) {
    p <- p + ggplot2::geom_line(
      data = channel_df,
      ggplot2::aes(!!ggplot2::sym(x_plot), .data$center),
      color = pal[["current"]], linewidth = 1.2, linetype = "dashed",
      inherit.aes = FALSE
    )
  }

  p +
    x_scale +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::labs(
      title    = ptitle,
      subtitle = paste0(level, " curves  |  channel mean dashed"),
      x = x_lab, y = "KPI", color = "Unit"
    ) +
    ggplot2::theme_minimal()
}


#' Partial-pooling shrinkage plot from a hierarchical fit
#'
#' Dot plot of a single curve parameter across the units at a chosen level,
#' sorted by value, with unit-level credible intervals, point size scaled by the
#' number of observed weeks, and a dashed line at the channel-level value.
#' Reveals which units are pulled toward the mean and how strongly.
#'
#' @param mrm A fitted \code{mrmfit_hier} object.
#' @param param Which parameter to display: \code{"e"} (midpoint, default),
#'   \code{"b"} (growth rate), \code{"d"} (ceiling), or \code{"c"} (floor).
#' @param level Optional cumulative grouping term. Defaults to the innermost
#'   level.
#' @return A ggplot object.
#'
#' @seealso \code{\link{mrm_plot_hier}}, \code{\link{mrm_plot_hier_response}}
#' @export
mrm_plot_hier_shrinkage <- function(mrm, param = c("e", "b", "d", "c"),
                                    level = NULL) {

  if (!inherits(mrm, "mrmfit_hier")) {
    stop("mrm must be a fitted model object created by fit_response_hier()",
         call. = FALSE)
  }
  param <- match.arg(param)
  if (is.null(level)) level <- paste(mrm$group, collapse = ":")
  pal    <- mrmopt_palette()
  ptitle <- paste0(mrm$spend_col, " - ", mrm$rc_type)

  ph  <- if (!is.null(mrm$params_hier)) mrm$params_hier else hlpr_params_hier(mrm)
  lvl <- ph$levels[[level]]
  if (is.null(lvl)) stop("Level '", level, "' not found in the fit.", call. = FALSE)

  lo <- paste0(param, "_lower")
  hi <- paste0(param, "_upper")
  channel_val <- ph$channel$center[[param]]

  df <- data.frame(
    id    = lvl$id,
    value = lvl[[param]],
    lower = lvl[[lo]],
    upper = lvl[[hi]],
    stringsAsFactors = FALSE
  )

  if (!is.null(mrm$summary)) {
    s  <- mrm$summary
    nw <- stats::setNames(s$n_weeks, s$id)
    df$n_weeks <- as.numeric(nw[df$id])
  } else {
    df$n_weeks <- NA_real_
  }

  df <- df[order(df$value), ]
  df$id <- factor(df$id, levels = df$id)

  param_lab <- c(b = "Growth Rate (b)", c = "Floor (c)",
                 d = "Ceiling (d)", e = "Midpoint (e)")[[param]]
  x_scale <- if (param == "e") {
    ggplot2::scale_x_continuous(labels = scales::dollar_format())
  } else if (param == "b") {
    ggplot2::scale_x_continuous(labels = scales::label_scientific())
  } else {
    ggplot2::scale_x_continuous(labels = scales::comma)
  }

  ggplot2::ggplot(df, ggplot2::aes(x = .data$value, y = .data$id)) +
    ggplot2::geom_vline(xintercept = channel_val, linetype = "dashed",
                        color = pal[["current"]], linewidth = 0.7) +
    ggplot2::geom_errorbar(
      ggplot2::aes(xmin = .data$lower, xmax = .data$upper),
      orientation = "y", width = 0, alpha = 0.4, linewidth = 0.4,
      color = pal[["response"]]
    ) +
    ggplot2::geom_point(
      ggplot2::aes(size = .data$n_weeks),
      color = pal[["response"]], alpha = 0.85
    ) +
    ggplot2::scale_size_continuous(range = c(1.5, 5), name = "Weeks") +
    x_scale +
    ggplot2::labs(
      title    = ptitle,
      subtitle = paste0("Per-unit ", param_lab,
                        "  |  dashed = channel mean  |  size = observed weeks"),
      x = param_lab, y = NULL
    ) +
    ggplot2::theme_minimal()
}


#' Convergence diagnostics for a hierarchical fit
#'
#' Trace plots for the channel-level (population) curve parameters and the
#' partial-pooling standard deviations, plus a posterior predictive check.
#' Analogous to \code{\link{mrm_plot_diagnostics}} and equivalent to
#' \code{mrm_plot_hier(mrm, type = "diagnostics")}.
#'
#' @param mrm A fitted \code{mrmfit_hier} object.
#' @return A patchwork plot object.
#'
#' @seealso \code{\link{mrm_plot_hier}}, \code{\link{mrm_plot_diagnostics}}
#' @export
mrm_plot_hier_diagnostics <- function(mrm) {

  if (!inherits(mrm, "mrmfit_hier")) {
    stop("mrm must be a fitted model object created by fit_response_hier()",
         call. = FALSE)
  }

  group  <- mrm$group
  pool   <- intersect(mrm$pool, c("b", "c", "d", "e"))
  is_log <- mrm$rc_type %in% c("log_logistic", "weibull", "reflected_weibull")
  mid    <- if (is_log) "le" else "e"

  # --- Population (channel-level) intercepts ---
  pop_vars   <- paste0("b_", c("b", "c", "d", mid), "_Intercept")
  pop_labels <- c("b", "c", "d", mid)

  # --- Partial-pooling SDs: one per pooled parameter per nesting level ---
  terms <- vapply(seq_along(group),
                  function(i) paste(group[seq_len(i)], collapse = ":"), character(1))
  sd_vars <- character(0); sd_labels <- character(0)
  for (t in terms) {
    for (p in pool) {
      pint <- if (p == "e" && is_log) "le" else p
      sd_vars   <- c(sd_vars, paste0("sd_", t, "__", pint, "_Intercept"))
      sd_labels <- c(sd_labels, paste0("sd_", p, "_", gsub(":", "_", t)))
    }
  }

  vars   <- c(pop_vars, sd_vars)
  labels <- c(pop_labels, sd_labels)

  draws <- posterior::as_draws_array(mrm, variable = vars)
  # rename to short, syntactic labels so facet strips stay readable
  draws <- do.call(posterior::rename_variables,
                   c(list(draws), as.list(stats::setNames(vars, labels))))

  trace_plot <- bayesplot::mcmc_trace(draws, facet_args = list(ncol = 2)) +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = "Trace Plots (population + pooling SDs)")

  pp_plot <- brms::pp_check(mrm, ndraws = 200) +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = "Posterior Predictive Check")

  patchwork::wrap_plots(
    patchwork::wrap_elements(trace_plot), pp_plot,
    ncol = 1, heights = c(2, 1)
  ) +
    patchwork::plot_annotation(
      title = paste0(mrm$spend_col, " - ", mrm$rc_type, " Diagnostics"),
      theme = ggplot2::theme(
        plot.title = ggplot2::element_text(face = "bold", size = 14))
    )
}


#' Plot method for mrmfit_hier objects
#'
#' Thin dispatcher to \code{\link{mrm_plot_hier}}. Defaults to the dashboard.
#'
#' @param x An \code{mrmfit_hier} object.
#' @param type Character; \code{"dashboard"} (default) or \code{"diagnostics"}.
#' @param ... Additional arguments passed to \code{\link{mrm_plot_hier}}.
#' @return A patchwork plot object.
#' @export
plot.mrmfit_hier <- function(x, type = c("dashboard", "diagnostics"), ...) {
  type <- match.arg(type)
  mrm_plot_hier(x, type = type, ...)
}
