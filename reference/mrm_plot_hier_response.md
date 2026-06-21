# Per-level response curves from a hierarchical fit

Plots one response curve per unit at a chosen level of the hierarchy,
overlaid with the channel-level mean curve (dashed). Shows how partial
pooling spreads the units around the channel mean.

## Usage

``` r
mrm_plot_hier_response(mrm, level = NULL, x_var = c("spend", "units"))
```

## Arguments

- mrm:

  A fitted `mrmfit_hier` object.

- level:

  Optional cumulative grouping term selecting which level's units to
  plot (e.g. `"subtype"` or `"subtype:station"`). Defaults to the
  innermost level.

- x_var:

  Character; `"spend"` (default) or `"units"`.

## Value

A ggplot object.

## See also

[`mrm_plot_hier`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_hier.md),
[`mrm_plot_hier_shrinkage`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_hier_shrinkage.md)
