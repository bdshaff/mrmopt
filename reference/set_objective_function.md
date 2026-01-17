# Create an objective function for optimization

This function generates an objective function that can be used in
optimization routines. The objective function computes the negative sum
of the outputs from a list of response functions when evaluated at a
given set of input parameters.

## Usage

``` r
set_objective_function(response_funs, prices = NULL)
```

## Arguments

- response_funs:

  A list of functions. Each function should take a single numeric input
  and return a numeric output.

- prices:

  An optional numeric vector of prices corresponding to each response
  function. If provided,

## Value

A function that takes a numeric vector as input and returns the negative
sum of the outputs from the response functions.
