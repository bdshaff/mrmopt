# Fit a within-channel hierarchical response curve model using brms

Fits a single hierarchical response curve model for one channel where
the curve parameters are partially pooled across sub-channel groupings.
The channel-level (population) effects describe the mean curve;
group-level (random) effects let sparse sub-channel units borrow
strength from the channel mean. Shape parameters (`b`, `e`) are pooled
by default, while the scale parameter (`d`) is allowed to vary more
freely to reflect size differences across units.

## Usage

``` r
fit_response_hier(
  data,
  spend = NULL,
  kpi = NULL,
  date = NULL,
  units = NULL,
  group = NULL,
  auto = TRUE,
  type = "log_logistic",
  pool = c("b", "e", "d"),
  scale_data = TRUE,
  scale_method = "min_max",
  midpoint_range = NULL,
  ceiling_max = NULL,
  floor_min = NULL,
  group_sd_prior = NULL,
  min_obs = 5,
  prior = NULL,
  chains = 4,
  iter = 4000,
  warmup = 1000,
  control = list(adapt_delta = 0.95, max_treedepth = 12),
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

- group:

  A character vector of one or more grouping column names, ordered from
  the outermost (broadest) to the innermost (finest) level of the
  hierarchy. For example `c("subtype", "station")` fits a nested
  structure `(1 | subtype) + (1 | subtype:station)` where stations are
  pooled within subtypes, which are in turn pooled toward the channel
  mean.

- auto:

  Logical indicating whether to automatically scale the data and set
  priors. Default is TRUE.

- type:

  The response curve type: `"gompertz"`, `"logistic"`,
  `"reflected_gompertz"`, `"log_logistic"`, `"weibull"`, or
  `"reflected_weibull"`. For the log-based forms the midpoint is
  reparameterized internally on the log scale for sampling stability
  (see Details); results are still reported in the usual `b`/`c`/`d`/
  `e` units. Default `"gompertz"`.

- pool:

  A character vector naming which of `b`, `c`, `d`, `e` receive
  group-level effects. Default `c("b", "e", "d")`.

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

- group_sd_prior:

  An optional single `brms` distribution string (e.g.
  `"exponential(1)"`) applied to every partial-pooling SD. When `NULL`
  (default), weakly-informative per-parameter defaults are used.

- min_obs:

  Minimum number of observations a unit (innermost group level) must
  have to be retained. Units with fewer observations are dropped with a
  warning, since they cannot identify even a pooled curve. Default `5`.

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

  A list of sampler control parameters. Default
  `list(adapt_delta = 0.95, max_treedepth = 12)`.

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

A fitted model object of class `mrmfit_hier` (extending `brmsfit`).

## Details

This is the hierarchical counterpart to
[`fit_response`](https://bdshaff.github.io/mrmopt/reference/fit_response.md)
and follows the same conventions: global data scaling, the `b`/`c`/
`d`/`e` parameterization, and the same prior-specification tiers.

Prior specification follows the same three tiers as
[`fit_response`](https://bdshaff.github.io/mrmopt/reference/fit_response.md)
(automatic, simplified via `midpoint_range`/`ceiling_max`/ `floor_min`,
or a manual raw `brmsprior`). The population priors are identical to the
single-fit case; partial-pooling SD priors are added automatically (see
[`hlpr_resolve_prior_hier`](https://bdshaff.github.io/mrmopt/reference/hlpr_resolve_prior_hier.md)).

For the log-based forms (`"log_logistic"`, `"weibull"`,
`"reflected_weibull"`) the midpoint enters as `log(e)`, which requires
`e > 0`. Group-level deviations on `e` can violate that and produce
`NaN` during sampling, so the midpoint is reparameterized internally on
the log scale (an unconstrained parameter `le = log(e)` replaces
`log(e)` in the model). This is transparent: `le` is translated back to
`e` during extraction, and all outputs (`params_hier`, `response_df`,
summaries, plots) report `e` in original spend units.

## See also

[`fit_response`](https://bdshaff.github.io/mrmopt/reference/fit_response.md),
[`hlpr_define_response_form_hier`](https://bdshaff.github.io/mrmopt/reference/hlpr_define_response_form_hier.md)
