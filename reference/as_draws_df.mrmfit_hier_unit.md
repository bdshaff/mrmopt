# Posterior draws accessor for hierarchical unit views

Returns the precomputed, composed scaled draws for a single hierarchical
unit so that
[`hlpr_extract_draws`](https://bdshaff.github.io/mrmopt/reference/hlpr_extract_draws.md)
(and hence `opt_mix`'s posterior path) can operate on it like any
`mrmfit`.

## Usage

``` r
# S3 method for class 'mrmfit_hier_unit'
as_draws_df(x, ...)
```

## Arguments

- x:

  A `mrmfit_hier_unit` object.

- ...:

  Ignored.

## Value

A `draws_df`.
