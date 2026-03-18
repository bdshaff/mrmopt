# Generate constraints for optimization based on MRM return rates or total spend This function generates constraints for optimization based on the return rates from the MRM models or a total spend constraint. The constraints include lower bounds, upper bounds, and initial values for each channel.

Generate constraints for optimization based on MRM return rates or total
spend This function generates constraints for optimization based on the
return rates from the MRM models or a total spend constraint. The
constraints include lower bounds, upper bounds, and initial values for
each channel.

## Usage

``` r
opt_generate_constraints(
  mrms_list,
  type = "return_rates",
  bounds_multiplier = 3,
  total_x = NULL
)
```

## Arguments

- mrms_list:

  A list of MRM models, where each model contains return rates and
  min-max values for the channels.

- type:

  The type to use for generating constraints. Options are "return_rates"
  or "total_bounded". Default is "return_rates".

- bounds_multiplier:

  A numeric value greater than 1 to multiply the return rate bounds when
  type is "return_rates". Default is 3.

- total_x:

  A numeric value representing the total spend constraint when type is
  "total_bounded". Must be greater than 0. Default is NULL.

## Value

A data frame containing the channel names, lower bounds (lb), upper
bounds (ub), initial values (x0), weekly spend, and total spend for each
channel.

## Details

When type is "return_rates", the function calculates the lower and upper
bounds for each channel based on the return rates from the MRM models,
multiplied by the bounds_multiplier. The initial value (x0) is set to
the midpoint between the lower and upper bounds. When type is
"total_bounded", the function sets the lower bound to 0 and the upper
bound to total_x for each channel, with the initial value (x0) set to
total_x divided by the number of channels.
