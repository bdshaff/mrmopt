# Helper function to set default priors for scaled data

This function sets default priors for the parameters of the
four-parameter logistic model when the data has been scaled. The priors
are based on the expected range of the parameters after scaling.

## Usage

``` r
hlpr_default_prior_for_scaled_data(scaled_data, x, y, scale_method)
```

## Arguments

- scale_method:

  The method used for scaling the data. Currently, only "min_max" is
  supported.

## Value

A list of priors for the parameters of the four-parameter logistic
model.
