# Compare Response Curve Models

This function generates a comparison plot of various response curve
models using specified parameters.

## Usage

``` r
response_models_comparison(
  x = seq(0, 1, by = 0.01),
  b = -8,
  c = 0,
  d = 10,
  e = 0.5
)
```

## Arguments

- x:

  A numeric vector representing the input values for the response
  curves. Default is seq(0, 1, by = 0.01).

- b:

  A numeric value representing the 'b' parameter for the response
  curves. Default is -8.

- c:

  A numeric value representing the 'c' parameter for the response
  curves. Default is 0.

- d:

  A numeric value representing the 'd' parameter for the response
  curves. Default is 10.

- e:

  A numeric value representing the 'e' parameter for the response
  curves. Default is 0.5.
