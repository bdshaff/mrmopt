# Fit a response curve model using brms

This function fits a response curve model using the brms package.

## Usage

``` r
fit_response(
  data,
  spend = NULL,
  kpi = NULL,
  date = NULL,
  units = NULL,
  auto = TRUE,
  type = "gompertz",
  scale_data = TRUE,
  scale_method = "min_max",
  midpoint_range = NULL,
  ceiling_max = NULL,
  floor_min = NULL,
  prior = NULL,
  chains = 4,
  iter = 4000,
  warmup = 1000,
  control = list(adapt_delta = 0.95),
  infer_xrange = NULL,
  infer_length = 1000,
  anchor_strength = NULL,
  anchor_zero = NULL,
  refresh = 500,
  ...
)
```

## Arguments

- data:

  A data frame containing the data to be fitted.

- spend:

  The name of the spend (independent) variable. This is always the
  x-axis predictor.

- kpi:

  The name of the KPI (dependent/response) variable.

- date:

  The name of the date column in the data.

- units:

  Optional name of a units column (e.g., impressions, GRPs). When
  supplied, cost per unit (CPU) is computed as `sum(spend) / sum(units)`
  and a `units` column is added to the inference output from
  [`mrm_infer`](https://bdshaff.github.io/mrmopt/reference/mrm_infer.md).

- auto:

  Logical indicating whether to automatically scale the data and set
  priors. Default is TRUE.

- type:

  The type of response curve model to fit. Options are "gompertz",
  "logistic", "log_logistic", "reflected_gompertz", "weibull", or
  "reflected_weibull".

- scale_data:

  Logical indicating whether to scale the data before fitting. Default
  is TRUE.

- scale_method:

  The method used for scaling. Either "min_max" or "std".

- midpoint_range:

  A two-element numeric vector specifying the midpoint bounds as
  fractions of the x-axis range (e.g., `c(0.1, 0.9)`). See
  [`mrmopt_prior`](https://bdshaff.github.io/mrmopt/reference/mrmopt_prior.md)
  for details.

- ceiling_max:

  A multiplier on the observed max of y for the ceiling upper bound
  (e.g., `3` means ceiling can be up to 3x observed max). See
  [`mrmopt_prior`](https://bdshaff.github.io/mrmopt/reference/mrmopt_prior.md)
  for details.

- floor_min:

  A scalar lower bound for the floor in original data units. Default
  is 0. See
  [`mrmopt_prior`](https://bdshaff.github.io/mrmopt/reference/mrmopt_prior.md)
  for details.

- prior:

  An optional `brmsprior` object for full manual control over priors. If
  provided, `midpoint_range`, `ceiling_max`, and `floor_min` are
  ignored. When `auto = FALSE` and `scale_data = FALSE`, this is
  required.

- chains:

  Number of Markov chains. Default is 4.

- iter:

  Total number of iterations per chain. Default is 4000.

- warmup:

  Number of warmup iterations per chain. Default is 1000.

- control:

  A list of control parameters for the sampler. Default is
  `list(adapt_delta = 0.95)`.

- infer_xrange:

  Optional range of x values for inference. If NULL, uses the range of x
  in the data.

- infer_length:

  The number of points to generate for inference. Default is 1000.

- anchor_strength:

  A single positive numeric value controlling how tightly the floor
  parameter (\`c\`) is constrained around \`floor_min\`. See
  [`mrmopt_prior`](https://bdshaff.github.io/mrmopt/reference/mrmopt_prior.md)
  for details. If supplied, overrides the \`anchor_strength\` in
  \`mrmopt_prior()\`. Default is \`NULL\` (use \`mrmopt_prior\` default
  of \`0.05\`).

- anchor_zero:

  \\Deprecated\\ Previously controlled injection of a synthetic (0, 0)
  data point. Floor anchoring is now handled via \`anchor_strength\` in
  [`mrmopt_prior`](https://bdshaff.github.io/mrmopt/reference/mrmopt_prior.md).
  If set, a deprecation warning is emitted and the argument is ignored.

- refresh:

  How often Stan reports sampling progress (in iterations). Default
  is 500. Set to 0 for silent sampling.

- ...:

  Additional arguments to be passed to the
  [`brm`](https://paulbuerkner.com/brms/reference/brm.html) function.

## Value

A fitted model object.

## Details

The function fits a response curve model using the specified type and
returns the fitted model object. Prior specification can be done in
three ways:

1.  **Automatic** (`auto = TRUE`): Data is scaled and default priors are
    set automatically. You can still customize via `midpoint_range`,
    `ceiling_max`, and `floor_min`.

2.  **Simplified** (`auto = FALSE`): Use `midpoint_range`,
    `ceiling_max`, and/or `floor_min` to set intuitive, scale-invariant
    priors.

3.  **Manual**: Pass a raw
    [`prior`](https://paulbuerkner.com/brms/reference/set_prior.html)
    object for full control.
