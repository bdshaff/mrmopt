# Design: `fit_response_hier()` — Within-Channel Hierarchical Response Curves

Status: **planning** · Roadmap item: *Near-Term — Within-Channel Hierarchical Response Curves*

This document plans the implementation of `fit_response_hier()`, following the
conventions of the existing `fit_response()` stack. It is derived from the
`linear_tv_hier_prototype.R` exploration and the `ROADMAP.md` entry.

---

## 1. Core insight — the prototype is a `log_logistic` with `c = 0`

The prototype's Hill form

```
aa_opps ~ d * spend_norm^slope / (spend_norm^slope + ec^slope)
```

is algebraically identical to the package `log_logistic` form
(`hlpr_define_response_form.R`) with `c = 0`, `b = -slope`, `e = ec`:

```
c + (d - c)/(1 + exp(b*(log(x) - log(e))))   with c=0, b=-slope, e=ec
  = d / (1 + (x/ec)^(-slope))
  = d * x^slope / (x^slope + ec^slope)
```

Consequence: the whole downstream stack (`response()`, `rm_dispatch()`,
`hlpr_params()`, `mrm_infer()`, `mrm_summary()`, `hlpr_extract_draws()`) is built
around `b/c/d/e`. **We keep `b/c/d/e`** and treat the prototype's `lec`/`lsl`
log-scale parameterization as a numerical-stability device confined to log-based
forms (see §4), not a convention change.

## 2. Decisions (confirmed)

1. **Scaling: global + free `d`.** Reuse `hlpr_scale_data()` unchanged; one global
   `scale_values` on the fit. The ceiling `d` carries per-group effects to absorb
   unit size differences. Matches the roadmap ("pool shape `b`,`e`; `d` varies
   freely") and keeps every unscaling routine reusable with identical math. The
   prototype's per-partner spend normalization is a prototype shortcut and is
   **not** adopted.
2. **Phase-1 form: `gompertz`.** Non-log form — `e` enters as `(x - e)`, no
   positivity constraint, so group random effects work directly with bounded
   population priors. Matches the roadmap example. Log forms follow in Phase 4.
3. **Ceiling `d`: partial-pool with a wide SD prior** (`d ~ 1 + (1|group)`),
   not fully free `0 + unit`. Sparse units still borrow some scale.

## 3. Pooling structure (default)

Single level `g`; nested `group = c("g1","g2")` expands to
`1 + (1|g1) + (1|g1:g2)`.

| Param | Role     | Default formula      | Rationale                              |
|-------|----------|----------------------|----------------------------------------|
| `b`   | shape    | `1 + (1\|g)`         | partial pool — sparse units borrow shape |
| `e`   | shape    | `1 + (1\|g)`         | partial pool — sparse units borrow shape |
| `d`   | scale    | `1 + (1\|g)`, wide sd | varies freely, still shrinks sparse units |
| `c`   | baseline | `1` (pop only, anchored) | floors ≈ 0, not identifiable per unit |

## 4. Numerical stability for log-based forms (Phase 4)

Random effects on `e` can push `log(e)` to `NaN` for `log_logistic`/`weibull`/
`reflected_weibull`. Confine the prototype's log-scale trick to one helper:
internally reparameterize the positivity-constrained parameter on the log scale
inside the brms formula, then **translate back to `b/c/d/e` at extraction time**
so nothing downstream ever sees `lec`/`lsl`. Non-log forms (Phase 1) need none of
this.

## 5. New S3 class — `mrmfit_hier` (extends `brmsfit`)

```
mrmfit_hier
├─ scale_values, scale_method, rc_type, spend_col, kpi_col,
│   date_col, units_col, cost_per_unit, date_range   # identical to mrmfit
├─ group         # e.g. c("subtype","station") — hierarchy spec (outer→inner)
├─ levels        # named list: unit ids per level + "channel" (the grand mean)
├─ params_hier   # list keyed by level → per-unit b/c/d/e tibbles (unscaled)
├─ response_df   # keyed by unit: per-unit + per-level + channel-mean curves
├─ summary       # per-unit mrm_summary rows bound into one tibble
└─ R2
```

## 6. Files

**New**

| File | Purpose |
|------|---------|
| `R/fit_response_hier.R` | Entry point (signature §7) |
| `R/hlpr_define_response_form_hier.R` | Build `bf(form, b~…, c~…, d~…, e~…, nl=TRUE)`; expand `group` vector → nested `(1\|g1)+(1\|g1:g2)` |
| `R/hlpr_resolve_prior_hier.R` | Reuse `hlpr_resolve_prior()` for population priors; add `class="sd"` priors per nl-par per level |
| `R/hlpr_params_hier.R` | `fixef + ranef`, unscale via global `scale_values`, per-unit `b/c/d/e` |
| `R/mrm_infer_hier.R` | Per-unit + channel-mean curves (`re_formula = NA` for the mean) |
| `R/print.mrmfit_hier.R` | Formatted console summary |
| `R/mrm_plot_hier.R` | Channel/level/unit overlay curves + shrinkage dot-plot (prototype Plot 4) |
| `R/as_mrmfit_list.R` | `mrmfit_hier` + `level` → named list consumable by `opt_mix()` |

**Modified (extend, not rewrite)**

- `R/hlpr_extract_draws.R` — add a path reconstructing per-unit draws
  (`b_<par>_Intercept + r_<group>__<par>[level]`) before the existing unscaling
  block, so `opt_mix(method="posterior")` works at any level.
- `NAMESPACE` / roxygen exports; `ROADMAP.md` (mark in progress); `AGENTS.md`.

## 7. Signature (mirrors `fit_response`)

```r
fit_response_hier(
  data, spend = NULL, kpi = NULL, date = NULL, units = NULL,
  group,                              # NEW: char vector, nested outer→inner
  type = "gompertz",
  pool = c("b","e","d"),              # NEW: which params get group effects
  auto = TRUE, scale_data = TRUE, scale_method = "min_max",
  midpoint_range = NULL, ceiling_max = NULL, floor_min = NULL,
  group_sd_prior = NULL,              # NEW: prior on the partial-pooling SDs
  prior = NULL,
  chains = 4, iter = 4000, warmup = 1000,
  control = list(adapt_delta = 0.95, max_treedepth = 12),
  infer_xrange = NULL, infer_length = 1000,
  anchor_strength = NULL, refresh = 500, ...
)
```

Same validation/guard order as `fit_response` (warmup<iter; column checks;
units→CPU; negative-y guard; `anchor_zero` deprecation), **plus**: validate
`group` columns exist; check clean nesting (each inner level maps to one outer —
prototype's `count(partner) |> filter(n>1)`); warn on units below a
min-observations threshold (prototype's `MIN_WEEKS`).

## 8. opt_mix integration ("optimize at any level")

`opt_mix()` consumes a named list of models via `hlpr_extract_draws()`, which
returns `{curve_fn, b, c, d, e vectors, n_draws, channel}` per model.
`as_mrmfit_list(fit_hier, level = "subtype:station")` produces per-unit draw
structures in that exact shape (global-scale unscaling reused verbatim), so
`opt_mix(as_mrmfit_list(fit_tv, "subtype"), budget = …)` works with **no change
to `opt_mix` core** — only the extractor.

## 9. Phasing

1. **Core fit + non-log forms** — `fit_response_hier`, hier formula/prior helpers,
   single level, global scaling, `mrmfit_hier` + print. Validate on `gompertz`.
   _Status: DONE._
2. **Post-processing** — `hlpr_params_hier`, `mrm_infer_hier`, `mrm_summary_hier`.
   Shared internals extracted so the single-fit path is reused, not duplicated:
   `hlpr_unscale_params` (affine unscaling, now used by **both** `hlpr_params`
   and the hier path), `hlpr_response_metrics` (the `ar`/`mr`/`cp` block,
   mirrors `mrm_infer`), and `hlpr_summary_core` (the range logic, now shared by
   `mrm_summary`). `fit_response_hier` attaches `$params_hier`, `$response_df`
   (long, keyed by `id`/`level`), and `$summary`. Plotting mirrors `mrm_plot`:
   `mrm_plot_hier()` builds a dashboard (`type = c("dashboard","diagnostics")`)
   — a response panel per level plus a shrinkage panel for each of `e`/`b`/`d`;
   `type = "diagnostics"` traces the population params and partial-pooling SDs
   with a PPC. The panels are also exported standalone:
   `mrm_plot_hier_response()`, `mrm_plot_hier_shrinkage()` (the prototype's
   Plot 4), and `mrm_plot_hier_diagnostics()`. `plot.mrmfit_hier` dispatches to
   the dashboard. (`mrms_plot_compare()` also gained `interval = "none"`.)
   _Status: DONE._
3. **Nested multi-level** — `group` length > 1. The model spec was already
   nestable (Phase 1 formula/prior helpers); the work was in post-processing.
   `hlpr_params_hier` now composes effects down the chain (population + Σ
   ancestor deviations; brms joins interaction-level ids with `_` and ranef
   terms with `:` — confirmed empirically), and returns a `$nesting` map.
   `mrm_infer_hier` emits a curve for every level using a level-appropriate
   `re_formula` and a representative child combo per parent; `mrm_summary_hier`
   summarises every level; `fit_response_hier` drops the guard and keys
   sparse-unit removal on the full innermost combination. Note: brms adds an
   interaction column (`subtype:station`) to `fit$data`, so the spend-column
   lookup excludes any `:`-containing column. Plots gained a `level` argument
   (default innermost). Verified end-to-end: a 2-level fit recovered all four
   station ceilings via composition. _Status: DONE._
4. **Log-form support** — `log_logistic`/`weibull`/`reflected_weibull`. The
   midpoint is reparameterized internally as `le = log(e)` (unconstrained),
   substituted for `log(e)` in the formula, so group-level deviations can't
   drive `log(e)` to `NaN`. The reparam is confined to three helpers:
   `hlpr_define_response_form_hier` (builds the `le` formula + pools `le` when
   `e` is in `pool`), `hlpr_resolve_prior_hier` (transforms the `e` prior to a
   log-scale `le` prior with matching truncation; SD priors target `le`), and
   `hlpr_params_hier` (`internal()`/`expe()` read `le`, compose in log space,
   then `exp()` to `e` before unscaling). Everything downstream still sees
   `b/c/d/e` in original units. `mrm_infer_hier`/summaries/plots needed no
   changes. `fit_response_hier`'s log guard is removed. Verified end-to-end on a
   hierarchical `log_logistic` fit: half-saturation `e` recovered per unit (no
   `NaN`), ceilings and slope recovered. _Status: DONE._
5. **opt_mix** — `as_mrmfit_list(mrm, level=)` expands a hierarchical fit into a
   named list of per-unit single-curve views (class `mrmfit_hier_unit`, also
   `mrmfit`) at any level, consumable directly by `opt_mix` with **no change to
   `opt_mix` core**. Each view carries the unit's composed scaled draws
   (population + Σ ancestor `r_<term>__<par>[id,Intercept]`; midpoint `exp()`'d
   from `le` for log forms), per-unit `summary`/`response_df`/params, and the
   global scale metadata. Two small hooks make both `opt_mix` methods work
   untouched: an exported `as_draws_df.mrmfit_hier_unit` S3 method (posterior
   path via `hlpr_extract_draws`) and a one-line short-circuit in `hlpr_params`
   for the precomputed `params_hier_unit` (point path via
   `mrm_response_function`). Verified: point + posterior optimization at both
   the station and subtype levels on the nested gompertz fit (budgets balance,
   KPIs match fitted ceilings) and on the `log_logistic` fit (no `NaN`).

   **Unit-view contract (defensive).** A `mrmfit_hier_unit` supports everything
   derivable from its cached fields — `mrm_params`, `mrm_response_function`,
   `mrm_plot_response`/`return`/`costper`, `mrm_plot` dashboard, `mrm_infer` and
   `mrm_summary` (served from the cached `response_df`), `mrms_plot_compare`,
   `opt_mix`, plus dedicated `print`/`plot` methods. Operations needing the live
   Stan sampler fail fast with a message pointing to the parent fit:
   `mrm_plot_diagnostics()` / `mrm_plot(type="diagnostics")` and `mrm_infer()`
   with a custom `xrange`/`length.out`.
   _Status: DONE._
6. **Tests + vignette + docs** — extend `helper-mock.R` for hier mocks;
   mark roadmap item done.
