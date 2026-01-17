#' Compare Response Curve Models
#'
#' This function generates a comparison plot of various response curve models using specified parameters.
#' @param x A numeric vector representing the input values for the response curves. Default is seq(0, 1, by = 0.01).
#' @param b A numeric value representing the 'b' parameter for the response curves. Default is -8.
#' @param c A numeric value representing the 'c' parameter for the response curves. Default is 0.
#' @param d A numeric value representing the 'd' parameter for the response curves. Default is 10.
#' @param e A numeric value representing the 'e' parameter for the response curves. Default is 0.5.
#' @export

response_models_comparison <- function(x = seq(0, 1, by = 0.01), b = -8, c = 0, d = 10, e = 0.5) {

  x_values <- x

  b <- -8
  c <- 0
  d <- 10
  e <- 0.5

  response_models <- list(
    logistic_curve = rm_Logistic,
    gompertz_curve = rm_Gompertz,
    reflected_gompertz = rm_GompertzRef,
    weibull_curve = rm_Weibull,
    log_logistic_curve = rm_LogLogistic,
    reflected_weibull = rm_WeibullRef
  )

  response_curves <- dplyr::bind_cols(
    x = x_values,
    purrr::map_dfc(response_models, ~ .x(x_values, b, c, d, e))
  )


  plotly::ggplotly(
    response_curves |>
      tidyr::pivot_longer(-x, names_to = "model", values_to = "y") |>
      ggplot2::ggplot(ggplot2::aes(x, y, color = model)) +
      ggplot2::geom_line() +
      ggplot2::labs(
        title = paste0("
      Response Curve Model Comparison
      ", "b: ", b, ", c: ", c, ", d: ", d, ", e: ", e),
      ) +
      ggplot2::theme_minimal()
  )

}
