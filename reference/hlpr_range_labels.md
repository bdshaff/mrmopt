# Generate range labels appropriate for the curve form

Returns a named list with labels for range_min, range_peak, and
range_max that differ for log-form vs standard curves.

## Usage

``` r
hlpr_range_labels(mrm)
```

## Arguments

- mrm:

  A fitted model object.

## Value

A named list with elements `min`, `peak`, `max`.
