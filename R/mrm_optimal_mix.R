#' Optimal Mix Function
#' This function computes the optimal mix of channels to maximize the total response given a set of response functions and constraints.
#' @param mrm A list of response functions, where each function takes a numeric vector as input and returns a numeric value.
#' @param total A numeric value representing the total budget or constraint for the optimization.
#' @param x0 An optional numeric vector representing the initial guess for the optimization. If NULL, a default value will be used.
#' @param lb An optional numeric vector representing the lower bounds for each channel. If NULL, default values will be used.
#' @param ub An optional numeric vector representing the upper bounds for each channel. If NULL, default values will be used.
#' @param ineq_constr An optional function representing additional inequality constraints. If NULL, default constraints will be used.
#' @param xtol_rel A numeric value representing the relative tolerance for the optimization algorithm. Default is 1.0e-10.
#' @param maxeval An integer value representing the maximum number of evaluations for the optimization algorithm. Default is 1000.
#' @param location A character string indicating the location for the response functions. Default is "center".
#' @param prices An optional numeric vector representing the prices for each channel. If NULL, equal prices will be assumed.
#' @return A list containing the optimization results, including the optimal channel mix and the maximum response value.
#' @import nloptr
#' @export

mrm_optimal_mix = function(mrm, total, x0 = NULL, lb = NULL, ub = NULL, ineq_constr = NULL, xtol_rel = 1.0e-10, maxeval = 1000, location = "center", prices = NULL){

  response_funs = map(mrm, ~mrm_response_function(.x, location = location))

  object_func = set_objective_function(response_funs, prices = prices)
  C = length(response_funs)

  init_constraints = set_dafault_constraints(C, total)

  x0_ = init_constraints$x0
  lb_ = init_constraints$lb
  ub_ = init_constraints$ub

  ineq_constr_ = init_constraints$total_constr_func

  if(!is.null(x0)){
    if(length(x0) != C){
      stop(paste0("x0 must be of length ", C))
    }
    x0_ = x0
  }

  if(!is.null(lb)){
    if(length(lb) != C){
      stop(paste0("lb must be of length ", C))
    }
    lb_ = lb
  }

  if(!is.null(ub)){
    if(length(ub) != C){
      stop(paste0("ub must be of length ", C))
    }
    ub_ = ub
  }

  if(!is.null(ineq_constr)){
    ineq_constr_ = ineq_constr
  }

  #print default initial values and bounds
  cat("\n")
  cat("Number of channels: ", C)
  cat("\n")
  cat(paste0("Default x0: ", paste(round(x0_, 3), collapse = ", ")))
  cat("\n")
  cat(paste0("Default lb: ", paste(round(lb_, 3), collapse = ", ")))
  cat("\n")
  cat(paste0("Default ub: ", paste(round(ub_, 3), collapse = ", ")))
  cat("\n")

  #print default constraint
  cat("Default total constraint: sum(x) - total = 0")
  cat("\n")
  cat(paste0("Total value: ", total))
  cat("\n")

  res = nloptr(
    x0 = x0_,
    eval_f = object_func,
    lb = lb_,
    ub = ub_,
    eval_g_ineq = ineq_constr_,
    opts = list("algorithm" = "NLOPT_LN_COBYLA",
                "xtol_rel" = xtol_rel,
                "maxeval" = maxeval)
  )

  return(res)
}
