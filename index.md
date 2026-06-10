# mrmopt

**Bayesian media response modeling and optimization in R.**

`mrmopt` fits nonlinear saturation curves to media spend and KPI data
using Bayesian estimation, quantifies uncertainty across the full
response curve, and optimizes media mix allocation from the resulting
posterior distributions. It is designed to be accessible to analysts and
marketers without deep Bayesian modeling experience, while remaining
flexible enough for rigorous applied work.

## Installation

``` r

# install.packages("devtools")
devtools::install_github("bdshaff/mrmopt")
```

## Workflow

``` mermaid
flowchart TD
    A([Raw Data\nweekly spend · KPI · units]) --> B

    B[fit_response\none channel · one curve type]

    B --> C{Diagnostics\nmrm_plot_diagnostics}
    C -->|chains mixed\nRhat ≤ 1.01 · ESS > 400| D
    C -->|convergence issues| B2[adjust priors\nor iter/warmup]
    B2 --> B

    D[mrm_summary\nmrm_params\nmrm_plot]

    D --> E{Compare curve types\nmrms_plot_compare\nBayes R²}
    E -->|try all 6 types\nper channel| B
    E -->|best type selected\nper channel| F

    F[fit_response\nbest type · full iterations\nall channels in loop]

    F --> G[mrm_infer\nspend grid → posterior predictive\ncenter · lower · upper · AR · MR · CP]

    G --> H[opt_mix\nmethod = point or posterior\nbudget · constraints]

    H --> I[opt_summary\nopt_table\nopt_plot_allocation\nopt_plot_comparison]

    I --> J{Scenario Analysis}
    J --> K[period budgets\nn_weeks]
    J --> L[custom constraints\nmin/max spend · fixed channels]
    J --> M[posterior uncertainty\nopt_plot_posterior]

    K & L & M --> N([Allocation Decision])

    style A fill:#f0f4ff,stroke:#4a6fa5
    style N fill:#f0fff4,stroke:#4a6fa5
    style C fill:#fff8e1,stroke:#f0a500
    style E fill:#fff8e1,stroke:#f0a500
    style J fill:#fff8e1,stroke:#f0a500
```

## Quick Start

``` r

library(mrmopt)

# Built-in example data: 5 channels, 104 weeks each
data(mrmopt_data)

# 1. Fit a response curve for a single channel
paid_search <- mrmopt_data[mrmopt_data$channel == "Paid Search", ]

fit <- fit_response(
  data           = paid_search,
  spend          = "spend",
  kpi            = "conversions",
  date           = "week",
  type           = "gompertz",
  midpoint_range = c(0.1, 0.5),
  ceiling_max    = 3
)

# 2. Inspect and visualize
print(fit)                       # performance summary, parameters, Bayes R²
mrm_plot(fit)                    # response curve + AR/MR + cost-per dashboard
mrm_plot_diagnostics(fit)        # trace plots and posterior predictive checks

# 3. Optimize across a portfolio of fitted channels
opt <- opt_mix(
  list(
    paid_search  = fit_ps,
    paid_social  = fit_soc,
    display      = fit_dis,
    online_video = fit_ov,
    tv           = fit_tv
  ),
  budget = 500000
)

opt_summary(opt)                 # formatted allocation summary
opt_table(opt)                   # tidy tibble of current vs. optimal deltas
opt_plot_allocation(opt)         # grouped bar: current vs. optimal spend
opt_plot_curves(opt)             # response curves with optimal spend marked
```

## Features

- **6 response curve types** — Logistic, Gompertz, Reflected Gompertz,
  Log-Logistic, Weibull, and Reflected Weibull, covering concave and
  S-shaped diminishing returns
- **Full posterior uncertainty** — credible intervals on curves,
  marginal returns, average returns, and cost-per-unit at every spend
  level
- **Smart prior automation** — scale-invariant prior specification via
  `midpoint_range` and `ceiling_max`; no manual Stan required
- **Model diagnostics and comparison** — trace plots, posterior
  predictive checks, and overlay plots for comparing curve types or time
  periods via
  [`mrms_plot_compare()`](https://bdshaff.github.io/mrmopt/reference/mrms_plot_compare.md)
- **Portfolio optimization** — point-estimate (fast, ~1s) and posterior
  (distributional, ~6s for 200 draws) optimization via
  [`opt_mix()`](https://bdshaff.github.io/mrmopt/reference/opt_mix.md),
  with flexible constraint specification including absolute bounds,
  share constraints, and fixed channels
- **Explicit analysis functions** —
  [`opt_summary()`](https://bdshaff.github.io/mrmopt/reference/opt_summary.md),
  [`opt_table()`](https://bdshaff.github.io/mrmopt/reference/opt_table.md),
  [`opt_plot_allocation()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_allocation.md),
  [`opt_plot_comparison()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_comparison.md),
  [`opt_plot_curves()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_curves.md),
  [`opt_plot_returns()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_returns.md),
  and
  [`opt_plot_posterior()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_posterior.md)
  expose each output directly rather than hiding behind a single
  dispatcher
- **Period budgeting** — optimize for any planning horizon (e.g., annual
  \$10M broken into weekly allocations via `n_weeks`)

## Documentation and Tutorials

Full documentation, tutorials, and examples are available at
[bdshaff.github.io/mrmopt](https://bdshaff.github.io/mrmopt/).

| Vignette | Content |
|----|----|
| [Getting Started](https://bdshaff.github.io/mrmopt/getting_started.html) | End-to-end walkthrough using built-in data |
| [Fitting & Analysis](https://bdshaff.github.io/mrmopt/fitting_and_analysis.html) | Prior specification, curve types, model inspection |
| [Diagnostics & Comparison](https://bdshaff.github.io/mrmopt/diagnostics_and_comparison.html) | Convergence checks, curve type comparison |
| [Optimization](https://bdshaff.github.io/mrmopt/optimization.html) | Budget allocation, constraints, scenario analysis |
| [Response Curve Theory](https://bdshaff.github.io/mrmopt/response_curve_theory.html) | Mathematical background on the six curve forms |

## Roadmap

See the [Roadmap](https://bdshaff.github.io/mrmopt/roadmap.html) for
planned features, including within-channel hierarchical response curves,
rolling window parameter drift analysis, time-varying response curves,
cross-channel synergy modeling, and adstock support.
