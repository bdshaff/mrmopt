# Plot Marginal and Absolute Rates of Return for Multiple Resource Models

This function generates a plot comparing the Marginal Rate of Return
(MR) and Absolute Rate of Return (AR) for multiple resource models. It
highlights key points such as the maximum MR and the intersection point
where MR equals AR.

## Usage

``` r
mrm_plot_return(
  mrm,
  location = "center",
  xrange = NULL,
  length.out = 1000,
  scaled = TRUE
)
```

## Arguments

- mrm:

  A list of fitted model objects (e.g., brmsfit objects).

- location:

  A character string specifying which location to use for MR and AR
  calculations. Options are "center", "lower", or "upper". Default is
  "center".

- xrange:

  A numeric vector of length 2 specifying the range of x values to
  consider. If NULL, the range is determined from the data.

- length.out:

  An integer specifying the number of points to generate for the x-axis.
  Default is NULL.

- scaled:

  A logical value indicating whether to use scaled values for the
  calculations. Default is TRUE.

## Value

A ggplot object visualizing the MR and AR for each model.

## Details

The function computes the MR and AR for each model in the list and
creates a faceted plot. It highlights the maximum MR point in red and
the intersection point where MR equals AR in blue. A shaded green area
indicates the range between these two points.
