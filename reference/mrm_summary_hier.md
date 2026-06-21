# Per-unit, per-level, and channel summary from a hierarchical fit

The hierarchical counterpart to
[`mrm_summary`](https://bdshaff.github.io/mrmopt/reference/mrm_summary.md).
Produces a tibble with one row per unit at every level of the hierarchy
plus a channel-level row, each summarising current performance, fitted
curve parameters, and the recommended spend range. Rows are built with
the same computational core as
[`mrm_summary`](https://bdshaff.github.io/mrmopt/reference/mrm_summary.md)
(`hlpr_summary_core`), so the columns match the single-fit summary, with
two extra leading columns: `id` and `level`.

## Usage

``` r
mrm_summary_hier(mrm, mr_decay = 0.7)
```

## Arguments

- mrm:

  A fitted `mrmfit_hier` object from
  [`fit_response_hier`](https://bdshaff.github.io/mrmopt/reference/fit_response_hier.md).

- mr_decay:

  Fraction of peak MR used to define the upper bound of the response
  range (standard curves). Default 0.7.

## Value

A tibble of class `mrm_summary_hier`.

## See also

[`mrm_summary`](https://bdshaff.github.io/mrmopt/reference/mrm_summary.md),
[`mrm_infer_hier`](https://bdshaff.github.io/mrmopt/reference/mrm_infer_hier.md)
