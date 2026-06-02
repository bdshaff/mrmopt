# Generate an interpretive summary of response curve parameters

Returns a 4-row tibble describing each response curve parameter (b, c,
d, e) with its name, plain-language description, and posterior
center/lower/upper estimates in original data units.

## Usage

``` r
mrm_params_summary(mrm)
```

## Arguments

- mrm:

  A fitted model object returned by
  [`fit_response`](https://bdshaff.github.io/mrmopt/reference/fit_response.md).

## Value

A tibble with columns: `param`, `name`, `description`, `center`,
`lower`, `upper`.
