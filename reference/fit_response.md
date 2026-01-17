# Fit a response curve model using brms

This function fits a response curve model using the brms package.

## Usage

``` r
fit_response(data, x = NULL, y = NULL, auto = TRUE, type = "gompertz", ...)
```

## Arguments

- data:

  A data frame containing the data to be fitted.

- x:

  The name of the independent variable (predictor).

- y:

  The name of the dependent variable (response).

- auto:

  Logical indicating whether to automatically scale the data and set
  priors. Default is TRUE.

- type:

  The type of response curve model to fit. Options are "gompertz",
  "logistic", "weibull", or "exponential".

- ...:

  Additional arguments to be passed to the brms::brm function.

## Value

A fitted model object.

## Details

The function fits a response curve model using the specified type and
returns the fitted model object.
