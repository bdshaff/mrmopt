# Partial-pooling shrinkage plot from a hierarchical fit

Dot plot of a single curve parameter across the units at a chosen level,
sorted by value, with unit-level credible intervals, point size scaled
by the number of observed weeks, and a dashed line at the channel-level
value. Reveals which units are pulled toward the mean and how strongly.

## Usage

``` r
mrm_plot_hier_shrinkage(mrm, param = c("e", "b", "d", "c"), level = NULL)
```

## Arguments

- mrm:

  A fitted `mrmfit_hier` object.

- param:

  Which parameter to display: `"e"` (midpoint, default), `"b"` (growth
  rate), `"d"` (ceiling), or `"c"` (floor).

- level:

  Optional cumulative grouping term. Defaults to the innermost level.

## Value

A ggplot object.

## See also

[`mrm_plot_hier`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_hier.md),
[`mrm_plot_hier_response`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_hier_response.md)
