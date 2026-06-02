# Plot cost per KPI of a fitted model

Plot cost per KPI of a fitted model

## Usage

``` r
mrm_plot_costper(
  mrm,
  xrange = NULL,
  length.out = 1000,
  scaled = TRUE,
  markup = TRUE,
  x_var = c("spend", "units")
)
```

## Arguments

- mrm:

  A fitted model object returned by
  [`fit_response`](https://bdshaff.github.io/mrmopt/reference/fit_response.md).

- xrange:

  Numeric vector of length 2 for the x range. NULL uses defaults.

- length.out:

  Number of points. Default is 1000.

- scaled:

  Logical; plot on original scale? Default is TRUE.

- markup:

  Logical; add range annotations and current-point marker? Default is
  TRUE.

- x_var:

  Character; `"spend"` (default) or `"units"`.

## Value

A ggplot object.
