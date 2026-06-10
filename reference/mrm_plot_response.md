# Plot the response curve of a fitted model

Draws the response curve with a credible-interval ribbon and optional
data points, range annotations, and marginal-return overlay. This is the
first panel of the dashboard produced by \[plot.mrmfit()\]; call it
directly when you need a standalone response-curve plot or want to
control parameters (e.g., \`xrange\`, \`length.out\`) not exposed by
\`plot()\`.

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
  x_var = c("spend", "units"),
  interval = c("prediction", "confidence")
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

- interval:

  Type of credible interval. `"prediction"` (default) includes
  observation noise. `"confidence"` shows uncertainty about the mean
  curve only (tighter bands).

## Value

A ggplot object.

## See also

\[plot.mrmfit()\] for the combined dashboard, \[mrm_plot_return()\],
\[mrm_plot_costper()\] for the other panels.
