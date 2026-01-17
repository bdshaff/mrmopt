# Dispatch Response Model

This function dispatches the appropriate response model based on the
type provided.

## Usage

``` r
rm_dispatch(type)
```

## Arguments

- type:

  A string indicating the type of response model to dispatch.

## Value

A function corresponding to the specified response model.

## Details

The function takes a string input \`type\` and returns the corresponding
response model function. The available response models are: -
"logistic" - "log_logistic" - "gompertz" - "reflected_gompertz" -
"weibull" - "reflected_weibull"
