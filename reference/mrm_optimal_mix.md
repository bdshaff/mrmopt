# Optimal Mix Function This function computes the optimal mix of channels to maximize the total response given a set of response functions and constraints.

Optimal Mix Function This function computes the optimal mix of channels
to maximize the total response given a set of response functions and
constraints.

## Usage

``` r
mrm_optimal_mix(
  mrm,
  total,
  x0 = NULL,
  lb = NULL,
  ub = NULL,
  ineq_constr = NULL,
  xtol_rel = 1e-10,
  maxeval = 1000,
  location = "center",
  prices = NULL
)
```

## Arguments

- mrm:

  A list of response functions, where each function takes a numeric
  vector as input and returns a numeric value.

- total:

  A numeric value representing the total budget or constraint for the
  optimization.

- x0:

  An optional numeric vector representing the initial guess for the
  optimization. If NULL, a default value will be used.

- lb:

  An optional numeric vector representing the lower bounds for each
  channel. If NULL, default values will be used.

- ub:

  An optional numeric vector representing the upper bounds for each
  channel. If NULL, default values will be used.

- ineq_constr:

  An optional function representing additional inequality constraints.
  If NULL, default constraints will be used.

- xtol_rel:

  A numeric value representing the relative tolerance for the
  optimization algorithm. Default is 1.0e-10.

- maxeval:

  An integer value representing the maximum number of evaluations for
  the optimization algorithm. Default is 1000.

- location:

  A character string indicating the location for the response functions.
  Default is "center".

- prices:

  An optional numeric vector representing the prices for each channel.
  If NULL, equal prices will be assumed.

## Value

A list containing the optimization results, including the optimal
channel mix and the maximum response value.
