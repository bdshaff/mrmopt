# Infer response from a fitted model

This function infers the response from a fitted model object.

## Usage

``` r
mrm_infer(mrm, xrange = NULL, length.out = 1000, scaled = TRUE)
```

## Arguments

- mrm:

  A fitted model object.

- xrange:

  A numeric vector of length 2 specifying the range of x values for
  prediction. Default is NULL, which uses the range of x in the data.

- length.out:

  An integer specifying the number of points to predict. Default is
  1000.

- scaled:

  A logical indicating whether the model was fitted on scaled data.
  Default is TRUE.

## Value

A data frame containing the predicted response values and the model
response.

## Details

The function infers the response from the fitted model object and
returns a data frame with the predicted response values and the model
response.
