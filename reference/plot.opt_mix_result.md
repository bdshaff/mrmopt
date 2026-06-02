# Plot method for opt_mix_result objects

Produces visualizations of the optimization result.

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

  Character; one of \`"allocation"\`, \`"kpi"\`, \`"comparison"\`,
  \`"posterior"\`, \`"curves"\`, or \`"returns"\`. Defaults to
  \`"allocation"\`.

  - \`"allocation"\`: Grouped bar chart comparing current vs. optimal
    weekly spend. For posterior results, includes 95% CI error bars.

  - \`"kpi"\`: Same as allocation but for KPI values.

  - \`"comparison"\`: Dumbbell/segment chart showing current to optimal
    spend shift per channel.

  - \`"posterior"\`: Violin + boxplot of spend distributions from
    posterior draws. Only available when method = \`"posterior"\`; falls
    back to \`"allocation"\` for point results.

  - \`"curves"\`: Response curves with current and optimal spend points.

  - \`"returns"\`: Average and marginal return curves with current and
    optimal points.

- ...:

  Additional arguments (currently unused).

## Value

A ggplot object.
