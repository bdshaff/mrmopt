# Plot the response of a fitted model

This function plots the response of a fitted model.

## Usage

``` r
mrm_plot_response(
  mrm,
  xrange = NULL,
  length.out = 1000,
  scaled = TRUE,
  points = TRUE,
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

- points:

  A logical value indicating whether to plot the data points. Default is
  TRUE.

- markup:

  A logical value indicating whether to add markup lines to the plot.
  Default is FALSE.

## Value

A ggplot object.

## Details

The function plots the response of a fitted model object. It uses
ggplot2 to create the plot and includes a title and subtitle with
information about the model.
