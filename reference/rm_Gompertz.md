# Gompertz Response Model

This function computes the Gompertz response model for a given vector of
x values. It takes parameters b, c, d, and e to define the Gompertz
function.

## Usage

``` r
rm_Gompertz(x, b, c, d, e)
```

## Arguments

- x:

  A numeric vector of x values.

- b:

  A numeric value representing the steepness of the curve.

- c:

  A numeric value representing the lower asymptote.

- d:

  A numeric value representing the upper asymptote.

- e:

  A numeric value representing the x-value of the sigmoid's midpoint.

## Value

A numeric vector of the same length as x, representing the computed
Gompertz response values.

## Details

The Gompertz function is defined as: \$\$y = c + (d - c) \* exp(-exp( b
\* (x - e)))\$\$

## Examples

``` r
x_values <- seq(0, 10, by = 0.1)
b <- -0.5
c <- 0
d <- 1
e <- 5
result <- rm_Gompertz(x_values, b, c, d, e)
plot(x_values, result, type = "l", main = "Gompertz Response Model", xlab = "x", ylab = "y")
```
