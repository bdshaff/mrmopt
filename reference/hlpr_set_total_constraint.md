# Set a total constraint function

This function creates a constraint function that ensures the sum of the
elements in a vector equals a specified total.

## Usage

``` r
hlpr_set_total_constraint(total)
```

## Arguments

- total:

  A numeric value representing the desired total sum of the elements in
  the vector.

## Value

A function that takes a numeric vector as input and returns a numeric
vector of constraints.
