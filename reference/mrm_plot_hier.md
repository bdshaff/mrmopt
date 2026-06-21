# Plot a hierarchical response curve fit

Produces either a multi-panel dashboard or brms convergence diagnostics
for a model fitted with
[`fit_response_hier`](https://bdshaff.github.io/mrmopt/reference/fit_response_hier.md),
analogous to
[`mrm_plot`](https://bdshaff.github.io/mrmopt/reference/mrm_plot.md).

## Usage

``` r
mrm_plot_hier(
  mrm,
  type = c("dashboard", "diagnostics"),
  x_var = c("spend", "units"),
  ...
)
```

## Arguments

- mrm:

  A fitted `mrmfit_hier` object from
  [`fit_response_hier`](https://bdshaff.github.io/mrmopt/reference/fit_response_hier.md).

- type:

  Character; `"dashboard"` (default) or `"diagnostics"`.

- x_var:

  Character; `"spend"` (default) or `"units"` for the x-axis of the
  response panels.

- ...:

  Additional arguments (currently unused).

## Value

A `patchwork` plot object.

## Details

The **dashboard** (default) composes:

- one response-curve panel per level of the hierarchy
  ([`mrm_plot_hier_response`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_hier_response.md),
  one for each entry of `names(mrm$params_hier$levels)`);

- one shrinkage panel for each of the shape/scale parameters `e`, `b`,
  `d`
  ([`mrm_plot_hier_shrinkage`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_hier_shrinkage.md)).

The **diagnostics** view (`type = "diagnostics"`) shows trace plots for
the channel-level parameters and the partial-pooling SDs, plus a
posterior predictive check
([`mrm_plot_hier_diagnostics`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_hier_diagnostics.md)).

Use the standalone `mrm_plot_hier_*()` functions when you want a single
panel or finer control.

## See also

[`mrm_plot_hier_response`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_hier_response.md),
[`mrm_plot_hier_shrinkage`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_hier_shrinkage.md),
[`mrm_plot_hier_diagnostics`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_hier_diagnostics.md),
[`fit_response_hier`](https://bdshaff.github.io/mrmopt/reference/fit_response_hier.md)
