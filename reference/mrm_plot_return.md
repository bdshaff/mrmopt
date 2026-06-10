# Plot Absolute and Marginal Rates of Return

Draws absolute return (AR) and marginal return (MR) curves on a dual
y-axis. This is the second panel of the dashboard produced by
\[plot.mrmfit()\]; call it directly when you need a standalone
return-curve plot or want to control parameters not exposed by
\`plot()\`.

## Usage

``` r
mrm_plot_return(
  mrm,
  location = "center",
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

- interval:

  Type of credible interval. `"prediction"` (default) includes
  observation noise. `"confidence"` shows uncertainty about the mean
  curve only (tighter bands).

## Value

A ggplot object.

## See also

\[plot.mrmfit()\] for the combined dashboard, \[mrm_plot_response()\],
\[mrm_plot_costper()\] for the other panels.
