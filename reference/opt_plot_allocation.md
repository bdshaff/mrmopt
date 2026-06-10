# Plot current vs. optimal spend or KPI allocation

Produces a grouped bar chart comparing current and optimal weekly spend
(or KPI) per channel. For posterior method results, 95 are added to the
optimal bars.

## Usage

``` r
opt_plot_allocation(x, metric = c("spend", "kpi"), ...)
```

## Arguments

- x:

  An \`opt_mix_result\` object returned by \[opt_mix()\].

- metric:

  Character; \`"spend"\` (default) or \`"kpi"\`.

- ...:

  Additional arguments (currently unused).

## Value

A ggplot object.
