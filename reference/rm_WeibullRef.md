# Reflected Weibull Response Model

This function computes the reflected Weibull response model for a given
vector of x values. It takes parameters b, c, d, and e to define the
reflected Weibull function.

## Usage

``` r
rm_WeibullRef(x, b, c, d, e)
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
reflected Weibull response values.

## Details

The reflected Weibull function is defined as: \$\$y = c + (d - c) \*
(1 - exp(-exp( b \* (-log(x) + log(e)))))\$\$

## Examples

``` r
x_values <- seq(0, 10, by = 0.1)
b <- -5
c <- 0
d <- 1
e <- 5
result <- rm_WeibullRef(x_values, b, c, d, e)
plot(x_values, result, type = "l", main = "Reflected Weibull Response Model", xlab = "x", ylab = "y")
```
