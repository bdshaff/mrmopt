# Print method for mrmfit_hier objects

Displays a compact summary of a fitted hierarchical response curve
model: the channel and KPI, the hierarchy structure with per-level unit
counts, the channel-level (population mean) curve parameters in original
data units, a per-unit table of ceiling/midpoint and current
performance, and the Bayes R2.

## Usage

``` r
# S3 method for class 'mrmfit_hier'
print(x, ...)
```

## Arguments

- x:

  An `mrmfit_hier` object returned by
  [`fit_response_hier`](https://bdshaff.github.io/mrmopt/reference/fit_response_hier.md).

- ...:

  Additional arguments (ignored).

## Value

The object `x`, invisibly.
