# Extract a clean channel name from a fitted model

Derives a human-readable channel name from the original spend column
name stored on the fit object.

## Usage

``` r
hlpr_channel_name(mrm)
```

## Arguments

- mrm:

  A fitted model object returned by
  [`fit_response`](https://bdshaff.github.io/mrmopt/reference/fit_response.md).

## Value

A character string with the cleaned channel name.
