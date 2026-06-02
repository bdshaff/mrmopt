#' Run a single constrained optimization via nloptr
#'
#' Thin wrapper around `nloptr::nloptr()` using COBYLA. Shared by both
#' point-estimate and posterior-sampling optimization paths.
#'
#' @param eval_f Objective function: takes numeric vector `x`, returns scalar
#'   to **minimize**.
#' @param x0 Numeric vector of starting values.
#' @param lb Numeric vector of lower bounds.
#' @param ub Numeric vector of upper bounds.
#' @param eval_g_eq Optional equality constraint function (returns 0 when
#'   satisfied). Typically the budget constraint: `sum(x) - budget`.
#' @param eval_g_ineq Optional inequality constraint function (returns <= 0
#'   when satisfied).
#' @param xtol_rel Relative tolerance. Default 1e-8.
#' @param maxeval Maximum evaluations. Default 1000.
#' @return The raw `nloptr` result object.
#' @keywords internal
#' @import nloptr

hlpr_opt_solve <- function(
    eval_f,
    x0,
    lb,
    ub,
    eval_g_eq = NULL,
    eval_g_ineq = NULL,
    xtol_rel = 1e-8,
    maxeval = 1000
) {

  opts <- list(
    algorithm = "NLOPT_LN_COBYLA",
    xtol_rel = xtol_rel,
    maxeval = maxeval
  )

  nloptr::nloptr(
    x0 = x0,
    eval_f = eval_f,
    lb = lb,
    ub = ub,
    eval_g_eq = eval_g_eq,
    eval_g_ineq = eval_g_ineq,
    opts = opts
  )
}
