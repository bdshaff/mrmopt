#' Define a hierarchical response form for a nonlinear model
#'
#' Builds a \code{brms} nonlinear formula for a hierarchical (partially pooled)
#' response curve. The curve math is identical to
#' \code{\link{hlpr_define_response_form}} (same \code{b}/\code{c}/\code{d}/\code{e}
#' parameterization); the difference is that selected parameters receive
#' group-level (random) effects so that sub-channel units borrow strength from
#' the channel-level mean.
#'
#' @param type A character string specifying the response form. Valid options
#'   are "logistic", "log_logistic", "gompertz", "reflected_gompertz",
#'   "weibull", and "reflected_weibull".
#' @param x A character string with the (sanitized) name of the predictor
#'   (spend) variable.
#' @param y A character string with the (sanitized) name of the response (KPI)
#'   variable.
#' @param group A character vector of grouping column names, ordered from the
#'   outermost (broadest) to the innermost (finest) level of the hierarchy.
#'   A single-element vector gives one level; \code{c("g1", "g2")} expands to a
#'   nested structure \code{(1 | g1) + (1 | g1:g2)}.
#' @param pool A character vector naming which of \code{b}, \code{c}, \code{d},
#'   \code{e} receive group-level effects. Parameters not listed are modeled
#'   with a population-level intercept only (\code{~ 1}). Default
#'   \code{c("b", "e", "d")} pools the shape parameters and lets the scale
#'   parameter vary; the floor \code{c} stays population-level.
#'
#' @return A \code{brmsformula} object with \code{nl = TRUE}.
#' @details
#' The nested grouping terms are built cumulatively from \code{group}: level
#' \code{i} uses the interaction of the first \code{i} grouping columns. For
#' \code{group = c("subtype", "station")} this yields
#' \code{(1 | subtype) + (1 | subtype:station)}.
#'
#' @seealso \code{\link{hlpr_define_response_form}}, \code{\link{fit_response_hier}}
#' @keywords internal

hlpr_define_response_form_hier <- function(type, x = NULL, y = NULL,
                                           group = NULL,
                                           pool = c("b", "e", "d")) {

  if (is.null(x) || is.null(y)) {
    stop("Both 'x' and 'y' must be provided and cannot be NULL.", call. = FALSE)
  }
  if (is.null(group) || length(group) < 1) {
    stop("'group' must contain at least one grouping column name.", call. = FALSE)
  }

  pool <- intersect(pool, c("b", "c", "d", "e"))

  # --- Base curve formula ---
  # For log-based forms the midpoint enters as log(e), which requires e > 0.
  # Group-level deviations on e can violate that and produce NaN during
  # sampling, so we reparameterize the midpoint on the log scale: an internal
  # parameter `le` (= log(e), unconstrained) replaces log(e) in the formula.
  # `le` is translated back to `e` at extraction time (see hlpr_params_hier),
  # so nothing downstream sees `le`. Non-log forms reuse the canonical b/c/d/e
  # definitions from hlpr_define_response_form() directly.
  log_forms <- c("log_logistic", "weibull", "reflected_weibull")
  is_log <- type %in% log_forms
  midpoint_par <- if (is_log) "le" else "e"
  valid_pars <- c("b", "c", "d", midpoint_par)
  # map an internal parameter name to its user-facing (output) name
  out_name <- function(vp) if (vp == "le") "e" else vp

  if (is_log) {
    log_forms_le <- list(
      log_logistic      = y ~ c + ((d - c) / (1 + exp(b * (log(x) - le)))),
      weibull           = y ~ c + (d - c) * exp(-exp(b * (log(x) - le))),
      reflected_weibull = y ~ c + (d - c) * (1 - exp(-exp(b * (-log(x) + le))))
    )
    main_form <- hlpr_replace_variables_in_formula(
      log_forms_le[[type]], old_vars = c("x", "y"), new_vars = c(x, y))
  } else {
    base_bf <- hlpr_define_response_form(type, x, y)
    main_form <- base_bf$formula
    if (is.null(main_form)) {
      stop("Could not extract the base response formula for type '", type, "'.",
           call. = FALSE)
    }
  }

  # --- Build nested random-effect terms from the group vector ---
  # Cumulative nesting: g1, g1:g2, g1:g2:g3, ...
  level_terms <- vapply(
    seq_along(group),
    function(i) paste(group[seq_len(i)], collapse = ":"),
    character(1)
  )
  re_string <- paste0("(1 | ", level_terms, ")", collapse = " + ")

  # --- One formula per parameter (pool membership keyed on the output name) ---
  par_formulas <- lapply(valid_pars, function(p) {
    if (out_name(p) %in% pool) {
      stats::as.formula(paste0(p, " ~ 1 + ", re_string))
    } else {
      stats::as.formula(paste0(p, " ~ 1"))
    }
  })

  # --- Assemble the hierarchical brms formula ---
  resp_form <- do.call(
    brms::bf,
    c(list(main_form), par_formulas, list(nl = TRUE))
  )

  return(resp_form)
}
