# Replace Variables in a Formula

This function replaces variables in a given formula with new variable
names.

## Usage

``` r
replace_variables_in_formula(formula, old_vars, new_vars)
```

## Arguments

- formula:

  A formula object where variables need to be replaced.

- old_vars:

  A character vector of variable names to be replaced.

- new_vars:

  A character vector of new variable names to replace the old ones.

## Value

A formula object with the specified variables replaced.

## Details

The function uses regular expressions to match the variable names in the
formula.
