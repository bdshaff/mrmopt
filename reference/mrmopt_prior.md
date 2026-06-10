# Create a prior specification for response curve fitting

Provides a simplified, user-friendly interface for setting priors on
response curve parameters. Users specify constraints in intuitive,
scale-invariant terms rather than working with internal parameter names
and raw brms prior objects.

## Usage

``` r
mrmopt_prior(
  midpoint_range = c(0.1, 0.9),
  ceiling_max = 5,
  floor_min = 0,
  anchor_strength = 0.05
)
```

## Arguments

- midpoint_range:

  A two-element numeric vector specifying the lower and upper bounds for
  the midpoint (inflection point) as fractions of the x-axis range.
  Values should be between 0 and 1. For example, \`c(0.1, 0.9)\` means
  the midpoint is expected to fall between the 10th and 90th percentile
  of the x range. Default is \`c(0.1, 0.9)\`.

- ceiling_max:

  A multiplier on the observed maximum of the response variable,
  defining the upper bound for the upper asymptote (ceiling). For
  example, \`ceiling_max = 3\` means the ceiling can be at most 3 times
  the observed max of y. Must be \>= 1. Default is \`5\`.

- floor_min:

  A scalar specifying the lower bound for the lower asymptote (floor),
  in original data units. Default is \`0\`, meaning the response cannot
  go below zero.

- anchor_strength:

  A single positive numeric value controlling how tightly the floor
  parameter (\`c\`) is constrained around \`floor_min\`. Expressed as a
  fraction of the observed y range: \`0.05\` means the prior SD on \`c\`
  equals 5% of the observed y range in scaled space. Smaller values
  produce narrower credible intervals at low spend. Set to \`NULL\` for
  loose behavior (broad prior, minimal constraint on the floor). Default
  is \`0.05\`.

## Value

An object of class \`mrm_prior\` containing the prior specification.

## Details

The response curve model has four parameters:

- floor (c):

  Lower asymptote — the minimum response value.

- ceiling (d):

  Upper asymptote — the maximum response value.

- steepness (b):

  Growth rate controlling how sharply the curve rises.

- midpoint (e):

  Inflection point — where the curve reaches half its range.

This function allows you to set constraints on the midpoint and ceiling,
which are the parameters users typically have the most intuition about.
Steepness is managed internally with broad, scale-aware defaults. The
floor defaults to zero but can be overridden for models with non-zero
baselines.

For full control, you can bypass this interface and pass a raw
[`prior`](https://paulbuerkner.com/brms/reference/set_prior.html) object
directly to
[`fit_response`](https://bdshaff.github.io/mrmopt/reference/fit_response.md).

## Examples

``` r
# Default priors
mrmopt_prior()
#> mrm_prior specification:
#>   midpoint range : [0.1, 0.9] (x-axis fraction)
#>   ceiling max    : 5 x observed max of y
#>   floor min      : 0 (original data units)
#>   anchor strength: 0.05 (fraction of y range)

# Expect midpoint in the first half of the x range, ceiling up to 2x observed max
mrmopt_prior(midpoint_range = c(0.05, 0.5), ceiling_max = 2)
#> mrm_prior specification:
#>   midpoint range : [0.05, 0.5] (x-axis fraction)
#>   ceiling max    : 2 x observed max of y
#>   floor min      : 0 (original data units)
#>   anchor strength: 0.05 (fraction of y range)

# Allow a non-zero floor
mrmopt_prior(floor_min = 100)
#> mrm_prior specification:
#>   midpoint range : [0.1, 0.9] (x-axis fraction)
#>   ceiling max    : 5 x observed max of y
#>   floor min      : 100 (original data units)
#>   anchor strength: 0.05 (fraction of y range)
```
