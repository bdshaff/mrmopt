# Infer per-unit, per-level, and channel response curves from a hierarchical fit

The hierarchical counterpart to
[`mrm_infer`](https://bdshaff.github.io/mrmopt/reference/mrm_infer.md).
Produces a long response data frame with one response curve per unit at
*every* level of the hierarchy (e.g. each subtype mean and each
subtype:station unit) plus the channel-level (population mean) curve.
Each curve has the same column schema as the single-fit `response_df`
(center, prediction-interval bounds `lower`/`upper`, mean-function
bounds `lower_mu`/`upper_mu`, and the derived `ar`/`mr`/`cp` metrics),
with two extra key columns: `id` (unit id, or `"(channel)"` for the mean
curve) and `level` (the cumulative grouping term, or `"channel"`).

## Usage

``` r
mrm_infer_hier(
  mrm,
  xrange = NULL,
  length.out = 1000,
  scaled = TRUE,
  include_channel = TRUE
)
```

## Arguments

- mrm:

  A fitted `mrmfit_hier` object from
  [`fit_response_hier`](https://bdshaff.github.io/mrmopt/reference/fit_response_hier.md).

- xrange:

  Optional length-2 numeric range of x in scaled model space (as
  produced by `hlpr_scale_data`). When `NULL`, derived from the observed
  (scaled) spend range. The returned x column is always unscaled to
  original spend units.

- length.out:

  Number of points per curve. Default 1000.

- scaled:

  Logical; whether the model was fitted on scaled data.

- include_channel:

  Logical; include the channel-level mean curve. Default `TRUE`.

## Value

A long `data.frame` (one block of `length.out` rows per unit at each
level and, optionally, the channel mean).

## Details

Each level's bands are produced with an `re_formula` that includes only
the grouping terms up to and including that level, so the uncertainty
correctly reflects the data available at that level.
