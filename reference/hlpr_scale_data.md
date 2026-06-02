# Helper function to scale the data for model prep

This function scales the data and calculates the inferred x-range for
the model. For log-based response forms, x is ratio-scaled (divided by
max) to preserve positivity, since log(x) requires x \> 0. If the data
contains zero x values, a small data-adaptive offset is added before
scaling.

## Usage

``` r
hlpr_scale_data(data, x, y, scale_method, type = "gompertz")
```

## Arguments

- data:

  The input data frame containing the x and y variables to be scaled.

- x:

  Name of the x column.

- y:

  Name of the y column.

- scale_method:

  Either `"min_max"` or `"std"`.

- type:

  The response form type. Log-based forms (`"log_logistic"`,
  `"weibull"`, `"reflected_weibull"`) trigger ratio x-scaling and a
  positive offset if zeros are present. Default is `"gompertz"`.

## Value

A list containing the scaled data, the inferred x-range, and the scaling
values used for rescaling.
