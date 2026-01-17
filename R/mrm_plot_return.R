#' Plot Marginal and Absolute Rates of Return for Multiple Resource Models
#'
#' This function generates a plot comparing the Marginal Rate of Return (MR) and Absolute Rate of Return (AR) for multiple resource models. It highlights key points such as the maximum MR and the intersection point where MR equals AR.
#' @param mrm A list of fitted model objects (e.g., brmsfit objects).
#' @param xrange A numeric vector of length 2 specifying the range of x values to consider. If NULL, the range is determined from the data.
#' @param ncol An integer specifying the number of columns in the facet wrap. Default is 2.
#' @param location A character string specifying which location to use for MR and AR calculations. Options are "center", "lower", or "upper". Default is "center".
#' @return A ggplot object visualizing the MR and AR for each model.
#' @details The function computes the MR and AR for each model in the list and creates a faceted plot. It highlights the maximum MR point in red and the intersection point where MR equals AR in blue. A shaded green area indicates the range between these two points.
#'
#' @export


mrm_plot_return = function(mrm, xrange = c(0.0, 2), ncol = 2, location = "center") {


  if(!is.list(mrm)){
    mrm = list(mrm)
  }

  response_df = purrr::map_dfr(mrm, ~mrm_infer(.x, xrange = xrange), .id = "channel")

  x = names(response_df)[2]

  if(location == "center"){
    response_df$ar = response_df$ar
    response_df$mr = response_df$mr
  } else if(location == "lower"){
    response_df$ar = response_df$ar_lower
    response_df$mr = response_df$mr_lower
  } else if(location == "upper"){
    response_df$ar = response_df$ar_upper
    response_df$mr = response_df$mr_upper
  } else {
    stop("location must be one of 'center', 'lower', or 'upper'")
  }

  maxmr_df =
    response_df |>
    dplyr::group_by(channel) |>
    dplyr::filter(mr == max(mr, na.rm = TRUE)) |>
    select(channel, !!sym(x), mr)

  maxar_df =
    response_df |>
    dplyr::group_by(channel) |>
    dplyr::filter(ar == max(ar, na.rm = TRUE)) |>
    select(channel, !!sym(x), ar)

  x_range_df =
    maxmr_df |>
    select(channel, !!sym(x)) |>
    left_join(
      maxar_df |> select(channel, !!sym(x)), by = "channel", suffix = c("_min", "_max")
    )

  p = response_df |>
    dplyr::select(channel, !!sym(x), ar, mr) |>
    tidyr::pivot_longer(cols = c(ar, mr), names_to = "type", values_to = "value") |>
    ggplot2::ggplot(aes(x = !!sym(x), y = value, color = type)) +
    ggplot2::geom_line() +
    ggplot2::theme_minimal() +
    #theme(legend.position = "none") +
    ggplot2::facet_wrap(~channel, ncol = ncol) +
    ggplot2::geom_point(data = maxar_df, aes(x = !!sym(x), y = ar), color = "blue", size = 2) +
    ggplot2::geom_vline(data = maxar_df, aes(xintercept = !!sym(x)), color = "blue", linetype = "dashed") +
    ggplot2::geom_point(data = maxmr_df, aes(x = !!sym(x), y = mr), color = "red", size = 2) +
    ggplot2::geom_vline(data = maxmr_df, aes(xintercept = !!sym(x)), color = "red", linetype = "dashed") +
    #ensure separate annotations for each facet
    ggplot2::geom_rect(
      data = x_range_df,
      ggplot2::aes(xmin = !!sym(paste0(x,"_min")), xmax = !!sym(paste0(x,"_max")), ymin = -Inf, ymax = Inf),
      fill = "green", alpha = 0.2, inherit.aes = FALSE
    ) +
    #add x and y labels to the point
    ggplot2::geom_text(
      data = maxar_df,
      ggplot2::aes(x = !!sym(x), y = ar, label = paste0("(", round(!!sym(x), 2), ", ", round(ar, 2), ")")),
      vjust = -1, color = "blue", size = 3
    ) +
    ggplot2::geom_text(
      data = maxmr_df,
      ggplot2::aes(x = !!sym(x), y = mr, label = paste0("(", round(!!sym(x), 2), ", ", round(mr, 2), ")")),
      vjust = 2, color = "red", size = 3
    ) +
    ggplot2::labs(x = x, y = "Rate", title = "Absolute and Marginal Rates of Return")

  return(p)
}
