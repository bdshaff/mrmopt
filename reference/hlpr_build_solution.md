# Build the unified solution tibble for opt_mix

Assembles current-state metrics, optimal allocations, units (assuming
static cost-per-unit), response rates, period totals, and shares into a
single tibble. Used by both point and posterior paths so they return
identically-structured output.

## Usage

``` r
hlpr_build_solution(
  channels,
  mrms,
  weekly_spend,
  weekly_kpi,
  weekly_spend_lower = NULL,
  weekly_spend_upper = NULL,
  weekly_kpi_lower = NULL,
  weekly_kpi_upper = NULL,
  n_weeks = 1
)
```

## Arguments

- channels:

  Character vector of channel names.

- mrms:

  Named list of \`mrmfit\` objects (same order as \`channels\`).

- weekly_spend:

  Numeric vector of optimal weekly spend per channel.

- weekly_kpi:

  Numeric vector of optimal weekly KPI per channel.

- weekly_spend_lower:

  Numeric vector of 2.5% quantile (or `NULL` for point estimate).

- weekly_spend_upper:

  Numeric vector of 97.5% quantile (or `NULL`).

- weekly_kpi_lower:

  Numeric vector of 2.5% quantile (or `NULL`).

- weekly_kpi_upper:

  Numeric vector of 97.5% quantile (or `NULL`).

- n_weeks:

  Number of weeks the budget covers.

## Value

A tibble with current-state, optimal, period, and share columns.
