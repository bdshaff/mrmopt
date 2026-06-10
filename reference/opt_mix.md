# Optimize media mix allocation across channels

Given a set of fitted response curve models, find the optimal spend
allocation. Supports point-estimate optimization (fast, single solution)
and posterior-sampling optimization (slower, returns a distribution of
solutions reflecting Bayesian uncertainty).

## Usage

``` r
opt_mix(
  mrms,
  method = c("point", "posterior"),
  objective = "max_kpi",
  budget = NULL,
  n_weeks = 1,
  constraints = NULL,
  bounds_multiplier = 3,
  n_draws = 200,
  seed = NULL,
  parallel = FALSE,
  xtol_rel = 1e-08,
  maxeval = 1000,
  verbose = TRUE
)
```

## Arguments

- mrms:

  A named list of \`mrmfit\` objects (one per channel).

- method:

  One of \`"point"\` (default) or \`"posterior"\`. Point uses posterior
  median parameters; posterior optimizes over multiple MCMC draws.

- objective:

  One of \`"max_kpi"\` (default): maximize total KPI given a budget
  constraint.

- budget:

  Total budget for the period. If \`NULL\` (default), inferred from
  total current weekly spend across channels.

- n_weeks:

  Number of weeks the budget covers. Used to convert a period budget to
  weekly optimization. Default \`1\` (budget is already weekly).
  Convenience values: use \`52\` for annual, \`13\` for quarterly, \`4\`
  for monthly.

- constraints:

  A data frame with per-channel bounds. Must contain columns
  \`channel\`, \`min_spend\`, \`max_spend\`. If \`NULL\` (default),
  constraints are auto-generated from model return rate ranges.

- bounds_multiplier:

  When \`constraints\` is \`NULL\`, multiplier applied to auto-detected
  spend ranges. Default \`3\`.

- n_draws:

  Number of posterior draws to optimize over when \`method =
  "posterior"\`. Default \`200\`.

- seed:

  Random seed for draw sampling. Default \`NULL\`.

- parallel:

  Logical; use \`future.apply\` for parallel posterior optimization.
  Default \`FALSE\`. Requires a \`future::plan()\` to be set.

- xtol_rel:

  Relative tolerance for nloptr. Default \`1e-8\`.

- maxeval:

  Maximum nloptr evaluations per solve. Default \`1000\`.

- verbose:

  Print progress information. Default \`TRUE\`.

## Value

An \`opt_mix_result\` S3 object. Both methods return the same top-level
structure:

- \`\$solution\` — tibble with one row per channel containing current
  and optimal spend, KPI, units, cost-per, response rate, and share
  columns. Posterior results include \`\_lower\`/\`\_upper\` CI columns.

- \`\$constraints\` — tibble: channel, lb, ub, x0.

- \`\$budget_info\` — list: total_budget, weekly_budget, n_weeks,
  current_weekly.

- \`\$method\` — \`"point"\` or \`"posterior"\`.

- \`\$mrms\` — the named list of \`mrmfit\` models.

Point-only fields: \`\$nloptr_result\`, \`\$response_funs\`.  
Posterior-only fields: \`\$draws_matrix\`, \`\$kpi_matrix\`,
\`\$solution_draws\`, \`\$n_draws\`, \`\$draw_ids\`.

Use \[print()\] or \[summary()\] for a formatted console summary,
\[opt_table()\] for a tidy comparison tibble, and \[plot()\] or the
standalone \`opt_plot\_\*\` functions for visualizations.
