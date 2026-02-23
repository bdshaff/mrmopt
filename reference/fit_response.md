# Fit a response curve model using brms

This function fits a response curve model using the brms package.

## Usage

``` r
fit_response(
  data,
  x = NULL,
  y = NULL,
  auto = TRUE,
  type = "gompertz",
  scale_data = TRUE,
  prior = NULL,
  chains = 4,
  iter = 4000,
  warmup = 1000,
  control = list(adapt_delta = 0.95),
  infer_xrange = NULL,
  infer_length = 1000,
  cost_per_unit = 1,
  response_rate = 1,
  ...
)
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

- infer_xrange:

  Optional range of x values for inference. If NULL, uses the range of x
  in the data.

- infer_length:

  The number of points to generate for inference. Default is 1000.

- cost_per_unit:

  The cost per unit of the independent variable. Default is 1.0.

- response_rate:

  The response rate to be used in return calculations. Default is 1.0.

- ...:

  Additional arguments to be passed to the brms::brm function.

- infer_scaled:

  Logical indicating whether to return scaled inference results. Default
  is TRUE.

## Value

A fitted model object.

## Details

The function fits a response curve model using the specified type and
returns the fitted model object.
