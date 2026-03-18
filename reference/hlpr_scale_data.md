# Helper function to scale the data for model prep

This function scales the data using min-max scaling and also calculates
the inferred x-range for the model. It returns a list containing the
scaled data, the inferred x-range, and the min-max values used for
scaling.

## Usage

``` r
hlpr_scale_data(data, x, y, scale_method)
```

## Arguments

- data:

  The input data frame containing the x and y variables to be scaled.

## Value

A list containing the scaled data, the inferred x-range, and the min-max
values used for scaling.
