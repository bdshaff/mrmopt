# Plot the response curve of a fitted model

Plot the response curve of a fitted model

## Usage

``` r
mrm_plot_response(
  mrm,
  xrange = NULL,
  length.out = 1000,
  scaled = TRUE,
  points = TRUE,
  markup = TRUE,
  show_mr = FALSE,
  x_var = c("spend", "units")
)
```

## Arguments

- mrm:

  A fitted model object returned by
  [`fit_response`](https://bdshaff.github.io/mrmopt/reference/fit_response.md).

- xrange:

  A vector of length 2 specifying the x range. If NULL, uses the default
  from inference.

- length.out:

  Number of points to generate. Default is 1000.

- scaled:

  Logical; plot on the original (unscaled) data scale? Default is TRUE.

- points:

  Logical; overlay observed data points? Default is TRUE.

- markup:

  Logical; add range annotations and current-point marker? Default is
  TRUE.

- show_mr:

  Logical; overlay the marginal return curve on a secondary y-axis?
  Default is FALSE.

- x_var:

  Character; `"spend"` (default) or `"units"` for the x-axis variable.

## Value

A ggplot object.
