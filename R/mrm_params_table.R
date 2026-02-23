#' Create a formatted table of model parameters
#'
#' @param mrm A model object.
#' @param scaled Logical indicating whether to return scaled parameters. Default is TRUE.
#' @return A gt table of model parameters.
#' @export

mrm_params_table = function(mrm, scaled = TRUE) {
  cost_per_unit = mrm$cost_per_unit
  response_rate = mrm$response_rate
  params = mrm_params(mrm, scaled = scaled, cost_per_unit = cost_per_unit, response_rate = response_rate)
  params_df = as.data.frame(do.call(cbind, params))
  params_df %>%
    tibble::rownames_to_column(var = "Parameter") %>%
    dplyr::mutate(
      Parameter = dplyr::case_when(
        Parameter == "c" ~ "c (lower asymptote)",
        Parameter == "d" ~ "d (upper asymptote)",
        Parameter == "b" ~ "b (growth rate)",
        Parameter == "e" ~ "e (inflection point)",
        TRUE ~ Parameter
      )
    ) %>%
    gt::gt() %>%
    gt::fmt_number(
      columns = dplyr::everything(),
      decimals = 4
    ) %>%
    gt::tab_header(
      title = paste("Response Model Parameters")
    )
}
