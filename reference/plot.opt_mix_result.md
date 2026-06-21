# Plot method for opt_mix_result objects

Dispatches to various visualization functions for optimization results.
Supports response curves, allocation comparisons, posterior
distributions, and more.

## Usage

``` r
# S3 method for class 'opt_mix_result'
plot(
  x,
  type = c("allocation", "kpi", "comparison", "posterior", "curves", "returns"),
  ...
)
```

## Arguments

- x:

  An \`opt_mix_result\` object returned by \[opt_mix()\].

- type:

  Type of plot. One of: - \`"allocation"\` (default): Current vs optimal
  spend per channel - \`"kpi"\`: Current vs optimal KPI per channel -
  \`"comparison"\`: Dumbbell chart (current → optimal) -
  \`"posterior"\`: Posterior distribution of optimal spend (posterior
  method only) - \`"curves"\`: Response curves with current and optimal
  points - \`"returns"\`: Average and marginal return curves with
  current and optimal points

- ...:

  Additional arguments passed to the plot function.

## Value

A ggplot object (or composite plot for some types).
