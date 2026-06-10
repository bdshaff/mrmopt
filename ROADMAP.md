# Roadmap

This page tracks planned features and longer-term research directions
for `mrmopt`. Items are organized by horizon and reflect both near-term
engineering work and more exploratory modeling directions.

Feedback and contributions are welcome — open an issue on
[GitHub](https://github.com/bdshaff/mrmopt/issues) to discuss any of
these.

------------------------------------------------------------------------

## Near-Term

### Within-Channel Hierarchical Response Curves

**New function:** `fit_response_hier()`

Media channels are rarely homogeneous. TV spend spans broadcast, cable,
and streaming — each with different audience reach and response
dynamics. Social covers multiple partners, tactics, and creatives.
Standard response curve modeling treats the channel as a single unit,
which either overfits sparse sub-channel data or discards granularity
altogether.

`fit_response_hier()` will fit a single hierarchical model for one
channel where curve parameters are partially pooled across sub-channel
groupings:

``` r

fit_tv <- fit_response_hier(
  data      = tv_data,
  spend     = "spend",
  kpi       = "conversions",
  date      = "week",
  group     = c("subtype", "station"),   # nested hierarchy
  type      = "gompertz"
)
```

The fixed effects represent the channel-level mean curve. Random effects
at each level (subtype → station) are drawn from the level above, so
sparse units (e.g., a small cable station with 8 weeks of data) borrow
strength from better-identified peers. The degree of shrinkage is
automatic and data-driven — units with more observations get pulled less
toward the group mean.

**Key properties:**

- Channel-level, sub-type-level, and unit-level curves from a single
  model
- Posterior uncertainty correctly reflects data sparsity at each level
- Compatible with
  [`opt_mix()`](https://bdshaff.github.io/mrmopt/reference/opt_mix.md)
  for optimization at any level of the hierarchy
- Pooling operates on curve shape parameters (`b`, `e`); scale (`d`) is
  allowed to vary more freely to reflect size differences across units

------------------------------------------------------------------------

## Medium-Term

### Cross-Channel Synergy Model

**New function:** `fit_response_synergy()`

Standard media response modeling assumes channels contribute
independently and additively to KPI. This is a simplifying assumption
that most MMM tools carry forward without question. In practice,
simultaneous investment across channels may produce efficiency gains (or
losses) that a purely additive model misses.

`fit_response_synergy()` fits a joint model across all channels where
pairwise interaction terms — one per channel pair — capture residual
co-efficiency signals beyond what the individual response curves
predict:

``` r

fit_syn <- fit_response_synergy(
  models = list(tv = fit_tv, social = fit_social, search = fit_search, ...),
  data   = joint_data
)
```

With 9 channels, there are 36 possible pairwise interaction terms. To
prevent overfitting and handle the near-certain multicollinearity
between channels, all interaction terms are regularized with a
**horseshoe prior** — a sparsity-inducing prior that shrinks most
interactions toward zero while allowing a small number of
well-identified interactions to remain.

**Important framing:** Interaction terms estimated on attributed KPI
volumes should be interpreted as *predictive efficiency corrections*,
not causal synergies. The upstream attribution model that produced the
attributed volumes already assumed channel independence. These terms
capture residual signal in the data useful for optimization, not a
structural causal claim.

**Key properties:**

- Per-channel nonlinear response curves (Hill / Log-Logistic
  parameterization)
- Horseshoe-regularized pairwise interaction terms
- Collinearity diagnostics per channel pair — warns when an interaction
  is likely unidentifiable due to correlated spend patterns
- Interaction terms are opt-in; default behavior remains independent
  channels

------------------------------------------------------------------------

### Adstock Support

Estimated geometric adstock decay integrated into
[`fit_response()`](https://bdshaff.github.io/mrmopt/reference/fit_response.md)
via an optional `adstock = TRUE` argument. The decay parameter will be
estimated jointly with the saturation curve parameters and carry full
posterior uncertainty, consistent with Meridian’s approach.

``` r

fit <- fit_response(
  data    = my_data,
  spend   = "tv_spend",
  kpi     = "conversions",
  date    = "week",
  type    = "gompertz",
  adstock = TRUE   # estimate decay parameter jointly
)
```

Default prior: `Uniform(0, 1)` on the decay parameter — uninformative,
consistent with Meridian’s defaults. Users can tighten this with domain
knowledge about carryover windows for specific channels.

------------------------------------------------------------------------

## Longer-Term / Exploratory

### Ground-Up Joint MMM (`fit_mmm()`)

`mrmopt` currently operates as a **response curve layer** — it fits
saturation curves to attributed KPI volumes produced by an upstream MMM.
This is a valid and practical workflow, but it means the saturation
parameters are estimated on data that already has an implicit
independence and linearity assumption baked in by the attribution model.

A ground-up joint MMM would estimate adstock decay, saturation curve
parameters, and channel contribution coefficients *simultaneously* from
raw spend and total KPI data — the approach taken by [Google
Meridian](https://github.com/google/meridian) and
[PyMC-Marketing](https://www.pymc-marketing.io/).

This would be implemented via a hand-written Stan model using
[`CmdStanR`](https://mc-stan.org/cmdstanr/) as the backend, giving full
control over the model structure without the constraints of the `brms`
formula interface. Priors would be aligned with Meridian’s published
defaults (`ec ~ TruncatedNormal(0.8, 0.8, 0.1, 10)` on normalized spend,
`decay ~ Uniform(0, 1)`, `beta ~ HalfNormal(5)`).

**Key design:** A new `fit_mmm()` function returning a `mrmfit_joint` S3
class that feeds into the existing
[`opt_mix()`](https://bdshaff.github.io/mrmopt/reference/opt_mix.md)
optimization infrastructure via the same draw-matrix interface used by
the posterior optimization path.

This is a substantial modeling and engineering undertaking and will be
developed incrementally. Single-market models without geo-level
hierarchy are the initial target scope.
