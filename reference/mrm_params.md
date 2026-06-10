# Extract response curve parameters from a fitted model

Returns a 4-row tibble describing each response curve parameter (b, c,
d, e) with its name, plain-language description, and posterior
center/lower/upper estimates in original data units.

## Usage

``` r
mrm_params(mrm)
```

## Arguments

- mrm:

  A fitted model object returned by \[fit_response()\].

## Value

A tibble with columns: `param`, `name`, `description`, `center`,
`lower`, `upper`.

## See also

\[mrm_summary()\] for a full channel-level summary, \[fit_response()\]
for model fitting.
