#' Plot the response of a fitted model
#'
#' This function plots the response of a fitted model.
#' @param mrm A fitted model object. It can be a brmsfit object or a list of brmsfit objects.
#' @param xrange A vector of length 2 specifying the range of x values to plot. If NULL, the range of x values in the data is used.
#' @param length.out An integer specifying the number of points to generate for the x-axis. Default is 1000.
#' @param points A logical value indicating whether to plot the data points. Default is TRUE.
#' @param scaled A logical value indicating whether to plot the scaled response. Default is TRUE.
#' @param markup A logical value indicating whether to add markup lines to the plot. Default is FALSE.
#' @return A ggplot object.
#' @details The function plots the response of a fitted model object. It uses ggplot2 to create the plot and includes a title and subtitle with information about the model.
#' @export

mrm_plot_response = function(mrm, xrange = NULL, length.out = 1000, scaled = TRUE, points = TRUE, markup = FALSE){

  #check that mrm is a brmsfit object
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

  rc_data = mrm$data
  rc_type = mrm$rc_type
  y = mrm$formula$resp
  x = names(rc_data)[names(rc_data) != y]

  r_names = colnames(response_df)

  params = mrm_params(mrm, scaled = scaled, cost_per_unit, response_rate)$center

  ptitle = paste0(rc_type, " response model:")
  psubtitle = paste0(paste0(names(params),"=", round(unlist(params),2), collapse = ", "))

  p =
    ggplot2::ggplot(data = response_df, aes(!!sym(r_names[1]), !!sym(r_names[6]))) +
    ggplot2::geom_line(color = "blue") +
    ggplot2::geom_ribbon(data = response_df, aes(x = !!sym(r_names[1]), ymin = !!sym(r_names[7]), ymax = !!sym(r_names[8])), alpha = 0.5, fill = "lightblue") +
    ggplot2::labs(title = ptitle, subtitle = psubtitle, y = y) +
    ggplot2::theme(legend.position = "top") +
    ggplot2::scale_x_continuous(labels = scales::dollar_format()) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::theme_minimal()


  if(points == TRUE){

    #re-scale rc_data if necessary before adding point to the plot
    if(scaled & !is.null(mrm$scale_values)){
      if(mrm$scale_method == "min_max"){
        x_min = mrm$scale_values$x_min
        x_max = mrm$scale_values$x_max
        y_min = mrm$scale_values$y_min
        y_max = mrm$scale_values$y_max

        rc_data[[x]] = cost_per_unit * (rc_data[[x]] * (x_max - x_min) + x_min)
        rc_data[[y]] = response_rate * (rc_data[[y]] * (y_max - y_min) + y_min)
      }else if(mrm$scale_method == "std"){
        x_mean = mrm$scale_values$x_mean
        x_sd = mrm$scale_values$x_sd
        y_mean = mrm$scale_values$y_mean
        y_sd = mrm$scale_values$y_sd

        rc_data[[x]] = cost_per_unit * (rc_data[[x]] * x_sd + x_mean)
        rc_data[[y]] = response_rate * (rc_data[[y]] * y_sd + y_mean)
      }else{
        stop(paste0("Scaling method ", mrm$scale_method, " not supported for plotting."))
      }
    }

    p = p + ggplot2::geom_point(data = rc_data, aes(!!sym(x), !!sym(y)), color = "red", alpha = 0.5)
  }

  if(markup == TRUE){

    params_ = unlist(params)
    x_ = mean(response_df[[1]], na.rm = TRUE) * 0.1
    x_ranges = mrm$returnes_ranges

    p = p +
      geom_hline(yintercept = params_["c"], linetype = "dashed", color = "darkgreen") +
      geom_hline(yintercept = params_["d"], linetype = "dashed", color = "darkgreen") +
      geom_vline(xintercept = params_["e"], linetype = "dashed", color = "purple") +
      geom_segment(aes(
        x = params_["e"] - x_, xend = params_["e"] + x_,
        y = rm_dispatch(mrm$rc_type)(b = params_["b"], c = params_["c"], d = params_["d"], e = params_["e"], x = params_["e"] - x_),
        yend = rm_dispatch(mrm$rc_type)(b = params_["b"], c = params_["c"], d = params_["d"], e = params_["e"], x = params_["e"] + x_)
      ),
      color = "purple", size = 1, arrow = arrow(length = unit(0.1, "inches")),
      data = t(data.frame(params_))
      ) +
      geom_rect(
        data = x_ranges,
        ggplot2::aes(xmin = !!sym(paste0(x,"_min")), xmax = !!sym(paste0(x,"_max")), ymin = -Inf, ymax = Inf),
        fill = "green", alpha = 0.2, inherit.aes = FALSE
      )


  }

  return(p)
}
