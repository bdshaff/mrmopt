# Compare multiple fitted response models

Plots response curves, return curves, or cost-per curves from multiple
fitted models on a single axis or faceted. Useful for comparing curve
types for the same channel, or comparing channels side by side.

## Usage

``` r
mrms_plot_compare(
  models,
  plot_type = c("response", "return", "costper"),
  x_var = c("spend", "units"),
  layout = c("overlay", "facet"),
  interval = c("prediction", "confidence", "none")
)
```

## Arguments

- models:

  A named list of `mrmfit` objects.

- plot_type:

  Character; one of `"response"` (default), `"return"`, or `"costper"`.

- x_var:

  Character; `"spend"` (default) or `"units"`.

- layout:

  Character; `"overlay"` (default) plots all models on one axis using
  color, or `"facet"` uses `facet_wrap`.

- interval:

  Type of credible interval. `"prediction"` (default) includes
  observation noise. `"confidence"` shows uncertainty about the mean
  curve only (tighter bands). `"none"` draws the center curves only,
  with no interval ribbons.

## Value

A ggplot object.
