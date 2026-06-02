# Unscale observed data points for plotting

Unscale observed data points for plotting

## Usage

``` r
hlpr_unscale_data_points(mrm, x_var = "spend")
```

## Arguments

- mrm:

  A fitted model object.

- x_var:

  Character; `"spend"` or `"units"`.

## Value

A data frame with columns `x_plot_val` and `y_plot_val`.
