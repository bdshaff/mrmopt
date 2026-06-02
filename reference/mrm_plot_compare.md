# Compare multiple fitted response models

Plots response curves, return curves, or cost-per curves from multiple
fitted models on a single axis or faceted. Useful for comparing curve
types for the same channel, or comparing channels side by side.

## Usage

``` r
mrm_plot_compare(
  models,
  plot_type = c("response", "return", "costper"),
  x_var = c("spend", "units"),
  layout = c("overlay", "facet")
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

## Value

A ggplot object.
