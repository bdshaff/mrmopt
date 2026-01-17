# Extract parameters from a fitted model

This function extracts the parameters from a fitted model object.

## Usage

``` r
mrm_params(rc_fit, scaled = TRUE)
```

## Arguments

- rc_fit:

  A fitted model object.

- scaled:

  A logical indicating whether the model was fitted on scaled data.
  Default is TRUE.

## Value

A list containing the center, lower, and upper bounds of the parameters.

## Details

The function extracts the parameters from the fitted model object and
returns them in a list.
