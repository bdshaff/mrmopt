# Plot the cost per KPI of a fitted model

This function plots the cost per KPI of a fitted model.

## Usage

``` r
mrm_plot_costper(
  mrm,
  xrange = NULL,
  length.out = 1000,
  scaled = TRUE,
  cost_per_unit = 1,
  response_rate = 1,
  markup = FALSE
)
```

## Arguments

- mrm:

  A fitted model object. It can be a brmsfit object or a list of brmsfit
  objects.

- xrange:

  A vector of length 2 specifying the range of x values to plot. If
  NULL, the range of x values in the data is used.

- length.out:

  An integer specifying the number of points to generate for the x-axis.
  Default is 1000.

- scaled:

  A logical value indicating whether to plot the scaled response.
  Default is TRUE.

- cost_per_unit:

  A numeric value specifying the cost per unit of the independent
  variable. Default is 1.0.

- response_rate:

  A numeric value specifying the response rate to be used in return
  calculations. Default is 1.0.

- markup:

  A logical value indicating whether to add markup lines to the plot.
  Default is FALSE.

## Value

A ggplot object.

## Details

The function plots the cost per KPI of a fitted model object. It uses
ggplot2 to create the plot and includes a title with information about
the model. If markup is TRUE, it adds vertical lines and segments to
indicate the optimal point and the range of returns.
