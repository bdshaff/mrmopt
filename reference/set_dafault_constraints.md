# Set default constraints for optimization

This function sets default constraints for an optimization problem,
including initial values, lower and upper bounds, and a total constraint
function.

## Usage

``` r
set_dafault_constraints(C, total)
```

## Arguments

- C:

  Number of variables

- total:

  Total sum constraint

## Value

A list containing initial values (x0), lower bounds (lb), upper bounds
(ub), and a total constraint function (total_constr_func).
