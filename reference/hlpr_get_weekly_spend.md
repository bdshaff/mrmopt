# Get Weekly Spend helper function

This function calculates the weekly spend based on the scaling method
and values provided in the MRM object.

## Usage

``` r
hlpr_get_weekly_spend(mrm)
```

## Arguments

- mrm:

  An MRM object containing the scaling method, scaling values, and data.

## Value

A numeric value representing the weekly spend.

## Details

The function checks the scaling method used in the MRM object and
calculates the weekly spend accordingly. If the scaling method is
"min_max", it uses the mean of the data and the min-max scaling values
to calculate the weekly spend. If the scaling method is "std", it uses
the mean of the data and the standard deviation scaling values to
calculate the weekly spend. If an invalid scaling method is provided, an
error is raised.
