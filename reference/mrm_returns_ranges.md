# Get Ranges of Maximum Marginal Returns and Average Returns This function computes the ranges of x values corresponding to the maximum marginal returns (MR) and average returns (AR) for a list of marginal response models (MRMs).

Get Ranges of Maximum Marginal Returns and Average Returns This function
computes the ranges of x values corresponding to the maximum marginal
returns (MR) and average returns (AR) for a list of marginal response
models (MRMs).

## Usage

``` r
mrm_returns_ranges(mrm, xrange = NULL)
```

## Arguments

- mrm:

  A list of fitted model objects (e.g., brmsfit objects).

- xrange:

  A numeric vector of length 2 specifying the range of x values to
  consider. If NULL, the range is determined from the data.

## Value

A data frame containing the channels and their corresponding x ranges
for maximum MR and AR.

## Details

The function computes the MR and AR for each model in the list and
identifies the x values where MR and AR are maximized. It returns a data
frame with the channel names and their respective x ranges.
