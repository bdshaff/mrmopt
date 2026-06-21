#' Expose a hierarchical fit as a list of single-curve models for optimization
#'
#' Converts a \code{mrmfit_hier} object into a named list of lightweight,
#' single-curve model views — one per unit at a chosen level of the hierarchy —
#' that can be passed directly to \code{\link{opt_mix}}. This is how
#' optimization is performed "at any level" of the hierarchy: pass the subtype
#' level to optimize across sub-types, the innermost level to optimize across
#' individual units, and so on.
#'
#' Each element is a list of class \code{mrmfit_hier_unit} (which also inherits
#' \code{"mrmfit"}) carrying that unit's composed posterior draws, response
#' curve, summary, and parameters in original data units, plus the shared global
#' scaling metadata. Both \code{opt_mix} methods work: the point path reads the
#' unit's parameters; the posterior path reads its draws.
#'
#' @param mrm A fitted \code{mrmfit_hier} object from
#'   \code{\link{fit_response_hier}}.
#' @param level Optional cumulative grouping term naming the level to expand
#'   (e.g. \code{"subtype"} or \code{"subtype:station"}). Defaults to the
#'   innermost level.
#' @return A named list of \code{mrmfit_hier_unit} objects (names are unit ids),
#'   suitable as the \code{mrms} argument to \code{\link{opt_mix}}.
#'
#' @seealso \code{\link{opt_mix}}, \code{\link{fit_response_hier}}
#' @importFrom posterior as_draws_df
#' @export

as_mrmfit_list <- function(mrm, level = NULL) {

  if (!inherits(mrm, "mrmfit_hier")) {
    stop("mrm must be a fitted model object created by fit_response_hier()",
         call. = FALSE)
  }

  group_cols <- mrm$group
  L <- length(group_cols)
  term_name <- function(i) paste(group_cols[seq_len(i)], collapse = ":")
  terms <- vapply(seq_len(L), term_name, character(1))

  if (is.null(level)) level <- terms[L]
  i <- match(level, terms)
  if (is.na(i)) {
    stop("`level` must be one of: ", paste(terms, collapse = ", "), call. = FALSE)
  }

  ph       <- if (is.null(mrm$params_hier)) hlpr_params_hier(mrm) else mrm$params_hier
  unit_tbl <- ph$levels[[level]]
  nesting  <- ph$nesting

  summ    <- if (is.null(mrm$summary)) mrm_summary_hier(mrm) else mrm$summary
  rdf_all <- if (is.null(mrm$response_df)) mrm_infer_hier(mrm) else mrm$response_df

  rc_type      <- mrm$rc_type
  is_log       <- rc_type %in% c("log_logistic", "weibull", "reflected_weibull")
  mid_internal <- if (is_log) "le" else "e"

  # --- Full posterior draws + data columns ---
  draws <- posterior::as_draws_df(mrm)
  y <- mrm$formula$resp
  x <- setdiff(names(mrm$data),
               c(y, group_cols, grep(":", names(mrm$data), value = TRUE)))[1]

  data_label <- if (i == 1) {
    as.character(mrm$data[[group_cols[1]]])
  } else {
    apply(mrm$data[, group_cols[seq_len(i)], drop = FALSE], 1,
          function(r) paste(as.character(r), collapse = "_"))
  }

  sigma_col <- if ("sigma" %in% names(draws)) draws$sigma else rep(NA_real_, nrow(draws))

  # Compose a parameter's scaled draws down the nesting chain for one unit
  compose <- function(anc, par_internal) {
    v <- draws[[paste0("b_", par_internal, "_Intercept")]]
    for (j in seq_along(anc)) {
      col <- sprintf("r_%s__%s[%s,Intercept]", term_name(j), par_internal, anc[j])
      if (col %in% names(draws)) v <- v + draws[[col]]
    }
    v
  }

  out <- lapply(seq_len(nrow(unit_tbl)), function(k) {
    id  <- unit_tbl$id[k]
    nr  <- match(id, nesting[[paste0(".lab", i)]])
    anc <- vapply(seq_len(i), function(j) nesting[[paste0(".lab", j)]][nr], character(1))

    # Composed scaled draws (midpoint exp()'d back to e for log forms)
    mid_d <- compose(anc, mid_internal)
    ud <- data.frame(
      b_b_Intercept = compose(anc, "b"),
      b_c_Intercept = compose(anc, "c"),
      b_d_Intercept = compose(anc, "d"),
      b_e_Intercept = if (is_log) exp(mid_d) else mid_d,
      sigma         = sigma_col,
      .chain        = draws$.chain,
      .iteration    = draws$.iteration,
      .draw         = draws$.draw
    )
    class(ud) <- c("draws_df", "draws", "tbl_df", "tbl", "data.frame")

    # Per-unit observed data (response first, spend second — matches brms layout
    # so hlpr_get_weekly_spend()'s data[[2]] is the spend column)
    sel <- data_label == id
    udata <- data.frame(mrm$data[[y]][sel], mrm$data[[x]][sel])
    names(udata) <- c(y, x)

    # Per-unit summary as a single-row mrm_summary
    srow <- summ[summ$id == id & summ$level == level, , drop = FALSE]
    srow <- srow[, setdiff(names(srow), c("id", "level")), drop = FALSE]
    class(srow) <- c("mrm_summary", class(tibble::tibble()))

    params <- list(
      center = list(b = unit_tbl$b[k], c = unit_tbl$c[k],
                    d = unit_tbl$d[k], e = unit_tbl$e[k]),
      lower  = list(b = unit_tbl$b_lower[k], c = unit_tbl$c_lower[k],
                    d = unit_tbl$d_lower[k], e = unit_tbl$e_lower[k]),
      upper  = list(b = unit_tbl$b_upper[k], c = unit_tbl$c_upper[k],
                    d = unit_tbl$d_upper[k], e = unit_tbl$e_upper[k])
    )

    obj <- list(
      rc_type       = rc_type,
      unit_id       = id,
      level         = level,
      scale_values  = mrm$scale_values,
      scale_method  = mrm$scale_method,
      cost_per_unit = mrm$cost_per_unit,
      units_col     = mrm$units_col,
      spend_col     = mrm$spend_col,
      kpi_col       = mrm$kpi_col,
      date_col      = mrm$date_col,
      date_range    = mrm$date_range,
      data          = udata,
      formula       = mrm$formula,
      summary       = srow,
      response_df   = rdf_all[rdf_all$id == id & rdf_all$level == level, , drop = FALSE],
      params_hier_unit = params,
      R2            = mrm$R2,
      .unit_draws   = ud
    )
    class(obj) <- c("mrmfit_hier_unit", "mrmfit")
    obj
  })

  names(out) <- unit_tbl$id
  out
}


# Internal: warn (once per top-level call) when a function written for a single
# `mrmfit` is applied to a per-unit `mrmfit_hier_unit` view. A depth counter in
# options() suppresses cascades — e.g. mrm_plot() -> panel functions, or
# mrm_summary() -> mrm_infer() — and intended internal use (opt_mix), so the
# user sees exactly one warning for the function they actually called.
hlpr_unit_view_warn <- function(fn, env = parent.frame()) {
  d <- getOption("mrmopt.unit_view_depth", 0L)
  if (d == 0L) {
    warning(
      fn, "() is designed for a single `mrmfit`. You passed a per-unit view ",
      "from `as_mrmfit_list()`; the result is derived from the unit's cached ",
      "values, not a refit. Use the parent `mrmfit_hier` for full-model behavior.",
      call. = FALSE
    )
  }
  options(mrmopt.unit_view_depth = d + 1L)
  do.call(base::on.exit,
          list(bquote(options(mrmopt.unit_view_depth = .(d))), add = TRUE),
          envir = env)
  invisible()
}


#' Posterior draws accessor for hierarchical unit views
#'
#' Returns the precomputed, composed scaled draws for a single hierarchical
#' unit so that \code{\link{hlpr_extract_draws}} (and hence \code{opt_mix}'s
#' posterior path) can operate on it like any \code{mrmfit}.
#'
#' @param x A \code{mrmfit_hier_unit} object.
#' @param ... Ignored.
#' @return A \code{draws_df}.
#' @exportS3Method posterior::as_draws_df
as_draws_df.mrmfit_hier_unit <- function(x, ...) {
  x$.unit_draws
}


#' Print method for hierarchical unit views
#'
#' @param x A \code{mrmfit_hier_unit} object from \code{\link{as_mrmfit_list}}.
#' @param ... Ignored.
#' @return \code{x}, invisibly.
#' @export
print.mrmfit_hier_unit <- function(x, ...) {
  cat(cli_rule("Hierarchical unit view"), "\n")
  cat("Unit: ", x$unit_id, "  |  Level: ", x$level, "\n", sep = "")
  cat("Channel: ", x$spend_col, "  |  KPI: ", x$kpi_col,
      "  |  Type: ", x$rc_type, "\n", sep = "")

  p <- x$params_hier_unit$center
  if (!is.null(p)) {
    cat(sprintf("Params: b=%.3g  c=%.3g  d=%.3g  e=%.3g\n",
                p$b, p$c, p$d, p$e))
  }

  cat("\nPer-unit view from as_mrmfit_list(). Curve/return/cost plots,\n",
      "mrm_params(), mrm_response_function(), mrm_summary(), and opt_mix()\n",
      "work on it. MCMC diagnostics require the parent mrmfit_hier\n",
      "(e.g. mrm_plot_hier(<fit>, type = \"diagnostics\")).\n", sep = "")
  invisible(x)
}


#' Plot method for hierarchical unit views
#'
#' Draws the per-unit curve dashboard (\code{\link{mrm_plot}}). MCMC diagnostic
#' plots are not available for a unit view; use the parent \code{mrmfit_hier}.
#'
#' @param x A \code{mrmfit_hier_unit} object from \code{\link{as_mrmfit_list}}.
#' @param ... Passed to \code{\link{mrm_plot}}.
#' @return A patchwork plot object.
#' @export
plot.mrmfit_hier_unit <- function(x, ...) {
  mrm_plot(x, ...)
}
