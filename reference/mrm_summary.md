# Generate a channel-level summary from a fitted response model

This function produces a single-row tibble summarising the current
performance, fitted response-curve parameters, analytically important
points on the curve, and the distribution of observed weeks relative to
those points.

## Usage

``` r
mrm_summary(mrm, mr_decay = 0.7)
```

## Arguments

- mrm:

  A fitted model object returned by
  [`fit_response`](https://bdshaff.github.io/mrmopt/reference/fit_response.md).

- mr_decay:

  Fraction of peak MR used to define the upper bound of the response
  curve summary range (standard curves only). Default is 0.7.

## Value

A single-row tibble.

## Details

For standard (non-log) curves, the three summary points are:

- **range_min**: Spend at peak marginal return (MR). Below this the
  channel is under-invested.

- **range_peak**: Spend at peak absolute return (AR). This is the most
  efficient operating point.

- **range_max**: Spend where MR has declined to `mr_decay × peak MR`.
  Beyond this, diminishing returns accelerate.

For curves where MR is monotonically decreasing (no interior efficiency
peak — possible for log-form curves when \|b\| ≤ 1), the three summary
points are anchored to MR fractions around current spend:

- **range_min**: Last spend level where MR \>= 2x MR at current spend.

- **range_peak**: Current spend (operational anchor).

- **range_max**: First spend level above current where MR \<= 0.5x MR at
  current spend.
