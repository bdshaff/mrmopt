# Plot Optimal Mix

This function plots the response curves along with the optimal points
determined by the optimization results.

## Usage

``` r
plot_optimal_mix(optimal_mix)
```

## Arguments

- optimal_mix:

  The result object returned by
  [`opt_mix()`](https://bdshaff.github.io/mrmopt/reference/opt_mix.md),
  containing response functions and the optimal solution.

## Value

A ggplot object showing the response curves and optimal points.
