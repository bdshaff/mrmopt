# Plot Absolute and Marginal Rates of Return

Plot Absolute and Marginal Rates of Return

## Usage

``` r
mrm_plot_return(
  mrm,
  location = "center",
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

- location:

  Which parameter estimate to use: `"center"` (default), `"lower"`, or
  `"upper"`.

- xrange:

  Numeric vector of length 2 for the x range. NULL uses defaults.

- length.out:

  Number of points. Default is 1000.

- scaled:

  Logical; plot on original scale? Default is TRUE.

- markup:

  Logical; add range annotations and current-point markers? Default is
  TRUE.

- x_var:

  Character; `"spend"` (default) or `"units"`.

## Value

A ggplot object.
