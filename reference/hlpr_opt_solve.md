# Run a single constrained optimization via nloptr

Thin wrapper around \`nloptr::nloptr()\` using COBYLA. Shared by both
point-estimate and posterior-sampling optimization paths.

## Usage

``` r
hlpr_opt_solve(
  eval_f,
  x0,
  lb,
  ub,
  eval_g_eq = NULL,
  eval_g_ineq = NULL,
  xtol_rel = 1e-08,
  maxeval = 1000
)
```

## Arguments

- eval_f:

  Objective function: takes numeric vector \`x\`, returns scalar to
  \*\*minimize\*\*.

- x0:

  Numeric vector of starting values.

- lb:

  Numeric vector of lower bounds.

- ub:

  Numeric vector of upper bounds.

- eval_g_eq:

  Optional equality constraint function (returns 0 when satisfied).
  Typically the budget constraint: \`sum(x) - budget\`.

- eval_g_ineq:

  Optional inequality constraint function (returns \<= 0 when
  satisfied).

- xtol_rel:

  Relative tolerance. Default 1e-8.

- maxeval:

  Maximum evaluations. Default 1000.

## Value

The raw \`nloptr\` result object.
