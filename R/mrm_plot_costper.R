#' Plot the cost per KPI of a fitted model
#'
#' This function plots the cost per KPI of a fitted model.
#' @param mrm A fitted model object. It can be a brmsfit object or a list of brmsfit objects.
#' @param xrange A vector of length 2 specifying the range of x values to plot. If NULL, the range of x values in the data is used.
#' @param length.out An integer specifying the number of points to generate for the x-axis. Default is 1000.
#' @param scaled A logical value indicating whether to plot the scaled response. Default is TRUE.
#' @param cost_per_unit A numeric value specifying the cost per unit of the independent variable. Default is 1.0.
#' @param response_rate A numeric value specifying the response rate to be used in return calculations. Default is 1.0.
#' @param markup A logical value indicating whether to add markup lines to the plot. Default is FALSE.
#' @return A ggplot object.
#'
#' @details The function plots the cost per KPI of a fitted model object. It uses ggplot2 to create the plot and includes a title with information about the model. If markup is TRUE, it adds vertical lines and segments to indicate the optimal point and the range of returns.
#' @export

mrm_plot_costper = function(mrm, xrange = NULL, length.out = 1000, scaled = TRUE, cost_per_unit = 1.0, response_rate = 1.0, markup = FALSE){

  if(!is.brmsfit(mrm)){
    stop("mrm must be a fitted model object created by mrm_fit()")
  }

  cost_per_unit = mrm$cost_per_unit
  response_rate = mrm$response_rate

  if(!is.null(xrange) | length.out != 1000 | scaled != TRUE | cost_per_unit != 1.0 | response_rate != 1.0){
    response_df = mrm_infer(mrm, xrange = xrange, length.out = length.out, scaled = scaled, cost_per_unit = cost_per_unit, response_rate = response_rate)
    x_range_df = mrm_returns_ranges(mrm, xrange = xrange, length.out = length.out, scaled = scaled, cost_per_unit = cost_per_unit, response_rate = response_rate)
  } else {
    response_df = mrm$response_df
    x_range_df = mrm$returnes_ranges
  }

  x = names(response_df)[1]
  y_cp = "cp"
  y_cp_lower = "cp_lower"
  y_cp_upper = "cp_upper"

  ptitle = paste0("Cost per KPI across ", x," levels for ", mrm$rc_type)

  p =
    ggplot2::ggplot(data = response_df[!is.infinite(response_df[[y_cp]]), ], aes(x = !!sym(x), y = !!sym(y_cp))) +
    ggplot2::geom_line(color = "blue") +
    ggplot2::geom_ribbon(data = response_df[!is.infinite(response_df[[y_cp]]), ], aes(x = !!sym(x), ymin = !!sym(y_cp_lower), ymax = !!sym(y_cp_upper)), alpha = 0.5, fill = "lightblue") +
    ggplot2::labs(title = ptitle, x = x, y = "Cost Per KPI") +
    ggplot2::scale_y_continuous(labels = scales::dollar_format(), limits = c(0, NA)) +
    ggplot2::scale_x_continuous(labels = scales::dollar_format()) +
    ggplot2::theme_minimal()

  if(markup == TRUE){

    params_ = unlist(mrm_params(mrm, scaled, cost_per_unit, response_rate)$center)
    x_ = mean(response_df[[1]], na.rm = TRUE) * 0.1
    x_ranges = mrm$returnes_ranges

    p =
      p + geom_vline(xintercept = params_["e"], linetype = "dashed", color = "purple") +
      geom_rect(
        data = x_ranges,
        ggplot2::aes(xmin = !!sym(paste0(x,"_min")), xmax = !!sym(paste0(x,"_max")), ymin = -Inf, ymax = Inf),
        fill = "green", alpha = 0.2, inherit.aes = FALSE
      )
  }

  return(p)
}

