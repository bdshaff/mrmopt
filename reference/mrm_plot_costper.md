# Plot cost per KPI of a fitted model

Draws the cost-per-KPI efficiency curve with a credible-interval ribbon.
This is the third panel of the dashboard produced by \[plot.mrmfit()\];
call it directly when you need a standalone cost-per plot or want to
control parameters not exposed by \`plot()\`.

## Usage

``` r
mrm_plot_costper(
  mrm,
  xrange = NULL,
  length.out = 1000,
  scaled = TRUE,
  markup = TRUE,
  x_var = c("spend", "units"),
  interval = c("prediction", "confidence")
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

- interval:

  Type of credible interval. `"prediction"` (default) includes
  observation noise. `"confidence"` shows uncertainty about the mean
  curve only (tighter bands).

## Value

A ggplot object.

## See also

\[plot.mrmfit()\] for the combined dashboard, \[mrm_plot_response()\],
\[mrm_plot_return()\] for the other panels.
