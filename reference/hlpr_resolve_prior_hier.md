# Resolve an mrm_prior specification into a hierarchical brms prior object

Extends
[`hlpr_resolve_prior`](https://bdshaff.github.io/mrmopt/reference/hlpr_resolve_prior.md)
for hierarchical fits. Population (channel-level) priors on
`b`/`c`/`d`/`e` are produced by
[`hlpr_resolve_prior`](https://bdshaff.github.io/mrmopt/reference/hlpr_resolve_prior.md)
unchanged. In addition, partial-pooling standard-deviation priors
(`class = "sd"`) are appended for each pooled parameter at each level of
the hierarchy.

## Usage

``` r
hlpr_resolve_prior_hier(
  mrm_prior = NULL,
  scaled_data,
  x,
  y,
  scale_method,
  scale_values,
  type,
  group,
  pool = c("b", "e", "d"),
  group_sd_prior = NULL
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

- group:

  A character vector of grouping column names, ordered outermost to
  innermost (the same vector passed to
  [`hlpr_define_response_form_hier`](https://bdshaff.github.io/mrmopt/reference/hlpr_define_response_form_hier.md)).

- pool:

  A character vector naming which of `b`, `c`, `d`, `e` receive
  group-level effects.

- group_sd_prior:

  An optional single `brms` distribution string (e.g.
  `"exponential(1)"`) applied to every partial-pooling SD. When `NULL`
  (default), per-parameter defaults are used: a wider prior on the scale
  parameter `d` and a moderate prior on the shape parameters.

## Value

A `brmsprior` object containing both population-level and group-level SD
priors.

## Details

SD priors are specified in scaled parameter space, consistent with the
population priors. The defaults are weakly informative:

- shape parameters (`b`, `e`): `exponential(1)`

- scale parameter (`d`): `exponential(0.5)` — wider, so the ceiling can
  vary substantially across units to reflect size differences.

## See also

[`hlpr_resolve_prior`](https://bdshaff.github.io/mrmopt/reference/hlpr_resolve_prior.md),
[`fit_response_hier`](https://bdshaff.github.io/mrmopt/reference/fit_response_hier.md)
