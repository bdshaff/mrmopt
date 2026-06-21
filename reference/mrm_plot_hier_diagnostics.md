# Convergence diagnostics for a hierarchical fit

Trace plots for the channel-level (population) curve parameters and the
partial-pooling standard deviations, plus a posterior predictive check.
Analogous to
[`mrm_plot_diagnostics`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_diagnostics.md)
and equivalent to `mrm_plot_hier(mrm, type = "diagnostics")`.

## Usage

``` r
mrm_plot_hier_diagnostics(mrm)
```

## Arguments

- mrm:

  A fitted `mrmfit_hier` object.

## Value

A patchwork plot object.

## See also

[`mrm_plot_hier`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_hier.md),
[`mrm_plot_diagnostics`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_diagnostics.md)
