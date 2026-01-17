# Plot Marginal and Absolute Rates of Return for Multiple Resource Models

This function generates a plot comparing the Marginal Rate of Return
(MR) and Absolute Rate of Return (AR) for multiple resource models. It
highlights key points such as the maximum MR and the intersection point
where MR equals AR.

## Usage

``` r
mrm_plot_return(mrm, xrange = c(0, 2), ncol = 2, location = "center")
```

## Arguments

- mrm:

  A list of fitted model objects (e.g., brmsfit objects).

- xrange:

  A numeric vector of length 2 specifying the range of x values to
  consider. If NULL, the range is determined from the data.

- ncol:

  An integer specifying the number of columns in the facet wrap. Default
  is 2.

- location:

  A character string specifying which location to use for MR and AR
  calculations. Options are "center", "lower", or "upper". Default is
  "center".

## Value

A ggplot object visualizing the MR and AR for each model.

## Details

The function computes the MR and AR for each model in the list and
creates a faceted plot. It highlights the maximum MR point in red and
the intersection point where MR equals AR in blue. A shaded green area
indicates the range between these two points.
