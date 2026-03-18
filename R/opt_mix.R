#' Optimal Mix Function
#' This function computes the optimal mix of channels to maximize the total response given a set of response functions and constraints.
#' @param mrms A list of response functions, where each function takes a numeric vector as input and returns a numeric value.
#' @param objective A character string indicating the objective of the optimization. Default is "maximize_y".
#' @param constraints_type A character string indicating the type of constraints to apply. Default is "return_rates".
#' @param total_x A numeric value representing the total budget or constraint for the optimization.
#' @param x0 An optional numeric vector representing the initial guess for the optimization. If NULL, a default value will be used.
#' @param lb An optional numeric vector representing the lower bounds for each channel. If NULL, default values will be used.
#' @param ub An optional numeric vector representing the upper bounds for each channel. If NULL, default values will be used.
#' @param ineq_constr An optional function representing additional inequality constraints. If NULL, default constraints will be used.
#' @param xtol_rel A numeric value representing the relative tolerance for the optimization algorithm. Default is 1.0e-10.
#' @param maxeval An integer value representing the maximum number of evaluations for the optimization algorithm. Default is 1000.
#' @param location A character string indicating the location for the response functions. Default is "center".
#' @return A list containing the optimization results, including the optimal channel mix and the maximum response value.
#' @import nloptr
#' @export

opt_mix = function(
    mrms,
    objective = "maximize_y",
    constraints_type = "return_rates",
    total_x = NULL,
    x0 = NULL, lb = NULL, ub = NULL,
    ineq_constr = NULL,
    xtol_rel = 1.0e-10,
    maxeval = 1000){

  response_funs = map(mrms, ~mrm_response_function(.x))

  ## set objective function
  object_func = hlpr_set_objective_function(response_funs)
  C = length(response_funs)

  #set starting point and limits
  constraints_df = opt_generate_constraints(
    mrms,
    type = constraints_type,
    total_x = total_x
  )

  x0_ = constraints_df$x0
  lb_ = constraints_df$lb
  ub_ = constraints_df$ub
  total_x = mean(constraints_df$total_x)

  #set inequality constraints
  ineq_constr_ = hlpr_set_total_constraint(total_x)

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
  cat(paste0("Total value: ", total_x))
  cat("\n")


  response_funs = map(mrms, ~mrm_response_function(.x))
  object_func = hlpr_set_objective_function(response_funs)
  C = length(response_funs)

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

  # apply the res$solution to response_funs to get the expected returns
  expected_returns = map2_dbl(response_funs, res$solution, ~{
    x = .y
    f = .x
    f(x)
  })

  # collect results into a data frame with calculations and summary
  res_df =
    tibble(
      channel = names(mrms),
      weekly_spend = res$solution,
      weekly_conversions = expected_returns
    ) |>
    mutate(
      cp = weekly_spend/weekly_conversions,
      spend_share = weekly_spend/sum(weekly_spend),
      conversions_share = weekly_conversions/sum(weekly_conversions)
    ) |>
    arrange(-cp)

  return(
    list(
      res = res,
      res_df = res_df,
      constraints_df = constraints_df,
      response_funs = response_funs
      )
    )
}
