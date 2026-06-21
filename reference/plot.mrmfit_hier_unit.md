# Plot method for hierarchical unit views

Draws the per-unit curve dashboard
([`mrm_plot`](https://bdshaff.github.io/mrmopt/reference/mrm_plot.md)).
MCMC diagnostic plots are not available for a unit view; use the parent
`mrmfit_hier`.

## Usage

``` r
# S3 method for class 'mrmfit_hier_unit'
plot(x, ...)
```

## Arguments

- x:

  A `mrmfit_hier_unit` object from
  [`as_mrmfit_list`](https://bdshaff.github.io/mrmopt/reference/as_mrmfit_list.md).

- ...:

  Passed to
  [`mrm_plot`](https://bdshaff.github.io/mrmopt/reference/mrm_plot.md).

## Value

A patchwork plot object.
