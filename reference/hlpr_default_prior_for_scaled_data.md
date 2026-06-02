# Helper function to set default priors for scaled data

\`r lifecycle::badge("deprecated")\`

This function is deprecated in favor of \[mrm_prior()\] and the internal
\[hlpr_resolve_prior()\]. It is retained for backward compatibility and
now delegates to the new prior resolution system.

## Usage

``` r
hlpr_default_prior_for_scaled_data(
  scaled_data,
  x,
  y,
  scale_method,
  type = "gompertz",
  scale_values = NULL
)
```

## Arguments

- scaled_data:

  The scaled data frame.

- x:

  Name of the x column.

- y:

  Name of the y column.

- scale_method:

  The method used for scaling the data.

- type:

  The response form type. Default is `"gompertz"`.

- scale_values:

  List of scaling parameters. Required for the new prior system. If
  NULL, a minimal set is constructed from the data, which may not be
  fully accurate.

## Value

A list of priors for the four-parameter model.
