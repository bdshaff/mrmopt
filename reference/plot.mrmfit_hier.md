# Plot method for mrmfit_hier objects

Thin dispatcher to
[`mrm_plot_hier`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_hier.md).
Defaults to the dashboard.

## Usage

``` r
# S3 method for class 'mrmfit_hier'
plot(x, type = c("dashboard", "diagnostics"), ...)
```

## Arguments

- x:

  An `mrmfit_hier` object.

- type:

  Character; `"dashboard"` (default) or `"diagnostics"`.

- ...:

  Additional arguments passed to
  [`mrm_plot_hier`](https://bdshaff.github.io/mrmopt/reference/mrm_plot_hier.md).

## Value

A patchwork plot object.
