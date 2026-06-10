# Resolve an mrm_prior specification into a brms prior object

Converts user-friendly prior specifications from
[`mrmopt_prior`](https://bdshaff.github.io/mrmopt/reference/mrmopt_prior.md)
into
[`brms::prior`](https://paulbuerkner.com/brms/reference/set_prior.html)
objects appropriate for the given scaling method, scale values, and
response form type. Also performs form-aware validation to prevent
mathematically invalid prior configurations.

## Usage

``` r
hlpr_resolve_prior(
  mrm_prior = NULL,
  scaled_data,
  x,
  y,
  scale_method,
  scale_values,
  type
)
```

## Arguments

- mrm_prior:

  An object of class `mrmopt_prior`, or `NULL` for package defaults.

- scaled_data:

  The scaled data frame.

- x:

  Name of the x column.

- y:

  Name of the y column.

- scale_method:

  Either `"min_max"` or `"std"`.

- scale_values:

  List of scaling parameters (min/max or mean/sd values).

- type:

  The response form type (e.g., `"gompertz"`, `"log_logistic"`).

## Value

A `brmsprior` object.
