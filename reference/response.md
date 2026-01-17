# Response Curve Function

This function computes the response curve based on the specified model
type. It supports the Gompertz model and the Richards model.

## Usage

``` r
response(x, params, type = "gompertz")
```

## Arguments

- x:

  A numeric vector representing the input values.

- params:

  A list containing the parameters for the model. It should include:

  - b: The slope parameter (numeric).

  - c: The lower asymptote (numeric).

  - d: The upper asymptote (numeric).

  - e: The half-saturation (numeric).

- type:

  A character string specifying the model type. It can be either
  "gompertz" or "richards".

## Value

A numeric vector representing the response values computed by the model.
