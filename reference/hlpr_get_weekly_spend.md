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

The function checks the scaling values stored in the MRM object and
calculates the weekly spend accordingly. Dispatches on the keys present
in scale_values rather than scale_method, to support log-based forms
that use ratio scaling for x regardless of the user's scale_method
choice.
