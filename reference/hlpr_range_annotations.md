# Generate consistent range and current-point annotations for mrmopt plots

Returns a list of ggplot2 layers that annotate the current operating
point and the three range points from
[`mrm_summary()`](https://bdshaff.github.io/mrmopt/reference/mrm_summary.md).

## Usage

``` r
hlpr_range_annotations(
  mrm,
  x_var = "spend",
  show_current = TRUE,
  show_range = TRUE
)
```

## Arguments

- mrm:

  A fitted model object returned by
  [`fit_response`](https://bdshaff.github.io/mrmopt/reference/fit_response.md).

- x_var:

  Character; `"spend"` or `"units"`.

- show_current:

  Logical; whether to mark the current operating point.

- show_range:

  Logical; whether to shade the range region and mark range_min /
  range_max with vertical lines.

## Value

A list of ggplot2 layers.
