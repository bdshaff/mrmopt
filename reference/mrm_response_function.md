# Get the response function from a fitted model

This function extracts the response function from a fitted model object.
It allows you to specify which location's parameters to use (lower,
center, or upper).

## Usage

``` r
mrm_response_function(mrm, location = "center", scaled = TRUE)
```

## Arguments

- mrm:

  A fitted model object returned by \`fit_response()\`.

- location:

  A string specifying which location's parameters to use. Must be one of
  "lower", "center", or "upper". Default is "center".

- scaled:

  A logical indicating whether the model was fitted on scaled data.
  Default is TRUE.

## Value

A function that takes a numeric vector of x values and returns the
corresponding y values based on the specified response model and
parameters.
