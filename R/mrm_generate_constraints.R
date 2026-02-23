#' Generate constraints for optimization based on MRM return rates or total spend
#' This function generates constraints for optimization based on the return rates from the MRM models or a total spend constraint. The constraints include lower bounds, upper bounds, and initial values for each channel.
#' @param mrms_list A list of MRM models, where each model contains return rates and min-max values for the channels.
#' @param method The method to use for generating constraints. Options are "return_rates" or "total_bounded". Default is "return_rates".
#' @param bounds_multiplier A numeric value greater than 1 to multiply the return rate bounds when method is "return_rates". Default is 3.
#' @param total_x A numeric value representing the total spend constraint when method is "total_bounded". Must be greater than 0. Default is NULL.
#' @return A data frame containing the channel names, lower bounds (lb), upper bounds (ub), initial values (x0), weekly spend, and total spend for each channel.
#' @details When method is "return_rates", the function calculates the lower and upper bounds for each channel based on the return rates from the MRM models, multiplied by the bounds_multiplier. The initial value (x0) is set to the midpoint between the lower and upper bounds. When method is "total_bounded", the function sets the lower bound to 0 and the upper bound to total_x for each channel, with the initial value (x0) set to total_x divided by the number of channels.
#' @export

mrm_generate_constraints <- function(mrms_list, method = "return_rates", bounds_multiplier = 3, total_x = NULL) {

  if(method == "return_rates") {

    #make sure bounds_multiplier is numeric and greater than 1
    if(!is.numeric(bounds_multiplier) || bounds_multiplier <= 1) {
      stop("bounds_multiplier must be a numeric value greater than or equal to 1")
    }

    constraints_df <-
      map(mrms_list, ~ as.data.frame(.x$returnes_ranges), .id = "channel") %>%
      map(~ set_names(.x, c("channel", "min", "mr", "max", "ar"))) %>%
      bind_rows(.id = "channel") %>%
      select(-mr, -ar) %>%
      mutate(
        lb = min / bounds_multiplier,
        ub = max * bounds_multiplier,
        x0 = (min + max) / 2
      ) %>%
      select(-min, -max) %>%
      mutate(
        weekly_spend = map_dbl(mrms_list, ~mean(.x$data[[2]]) * (.x$min_max_values$x_max - .x$min_max_values$x_min) + .x$min_max_values$x_min)
      ) %>%
      mutate(total_x = sum(weekly_spend)) %>%
      #esnure lb is greater than 0 and ub is greater than x0 and x0 is between lb and ub
      mutate(
        lb = pmax(lb, 0),
        ub = pmax(ub, x0),
        x0 = pmin(pmax(x0, lb), ub)
      ) %>%
      tibble()
  }else if(method == "total_bounded"){

    #check that total_x is provided in the function arguments
    if(is.null(total_x) || !is.numeric(total_x) || total_x <= 0) {
      stop("total_x must be a numeric value greater than 0 when method is set to 'total_bounded'")
    }

    constraints_df <-
      data.frame(
        channel = names(mrms_list),
        lb = rep(0, length(mrms_list)),
        ub = rep(total_x, length(mrms_list)),
        x0 = rep(total_x/length(mrms_list), length(mrms_list))
      ) %>%
      mutate(
        weekly_spend = map_dbl(mrms_list, ~mean(.x$data[[2]]) * (.x$min_max_values$x_max - .x$min_max_values$x_min) + .x$min_max_values$x_min)
      ) %>%
      mutate(total_x = total_x) %>%
      mutate(
        lb = pmax(lb, 0),
        ub = pmax(ub, x0),
        x0 = pmin(pmax(x0, lb), ub)
      ) %>%
      tibble()

  }

  return(constraints_df)
}
