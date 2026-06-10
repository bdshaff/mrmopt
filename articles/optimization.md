# Media Mix Optimization

``` r

library(mrmopt)
library(ggplot2)
library(dplyr)
```

## Overview

Once you have fitted response curves for each media channel,
[`opt_mix()`](https://bdshaff.github.io/mrmopt/reference/opt_mix.md)
finds the budget allocation that maximises total KPI. It supports two
optimization methods:

- **Point estimate** (`method = "point"`): uses the posterior median
  parameters from each model. Fast — typically under one second.
- **Posterior sampling** (`method = "posterior"`): optimises over many
  posterior draws, producing a **distribution** of optimal allocations
  that reflects Bayesian uncertainty. Takes a few seconds.

This vignette walks through the full optimization workflow using the
`mrmopt_data` example dataset.

------------------------------------------------------------------------

## 1. Fitting the Models

We start by fitting a response curve for each channel. In practice you
would compare multiple curve types per channel and select the best fit
(see the *Model Comparison & Diagnostics* vignette). Here we use
Gompertz curves for simplicity.

``` r

data(mrmopt_data)

channels <- c("Paid Search", "Paid Social", "Display",
              "Online Video", "TV")

models <- list()
for (ch in channels) {
  d <- mrmopt_data |> filter(channel == ch)
  
  # Use log_logistic for TV (log-scale channel), gompertz for the rest
  curve_type <- if (ch == "TV") "log_logistic" else "gompertz"
  
  models[[ch]] <- fit_response(
    data = d, spend = "spend", kpi = "conversions", date = "week",
    type = curve_type
  )
}
```

The result is a named list of `mrmfit` objects — the required input for
[`opt_mix()`](https://bdshaff.github.io/mrmopt/reference/opt_mix.md).

------------------------------------------------------------------------

## 2. Point Estimate Optimization

The simplest call uses the default budget (total current weekly spend
across all channels) and point-estimate parameters:

``` r

opt_point <- opt_mix(models, method = "point")
#> No budget supplied; using total current weekly spend: 204,641 
#> 
#> Optimization setup:
#>   Channels:       5 
#>   Method:         point 
#>   Weekly budget:  204,641 
#> 
#> Optimization converged (status: 4 )
#> Total weekly KPI: 3,013
```

### Inspecting the Result

[`print()`](https://rdrr.io/r/base/print.html) and
[`opt_summary()`](https://bdshaff.github.io/mrmopt/reference/opt_summary.md)
both display a formatted console summary — they produce the same output:

``` r

print(opt_point)
#> -- Optimization Result (point) ----------------------------------------------- 
#> Budget: $204,641/week  |  Channels: 5
#> -- Optimal Allocation -------------------------------------------------------- 
#>   Channel           Weekly Spend    Weekly KPI          CP    Share 
#>   Paid Search            $52,132           844         $62   25.5%
#>   Online Video           $40,980           660         $62   20.0%
#>   Display                $20,022           299         $67    9.8%
#>   TV                     $83,186         1,127         $74   40.6%
#>   Paid Social             $8,321            83        $101    4.1%
#> -- Totals -------------------------------------------------------------------- 
#>   Optimal:  Spend $204,641  |  KPI 3,013  |  Avg CP $68
#>   Current:  Spend $204,641  |  KPI 2,757  |  Avg CP $74
#>   Change:   KPI +9.3%  |  CP $6
```

To retrieve a **tidy tibble** of current vs. optimal deltas for further
analysis or export, use
[`opt_table()`](https://bdshaff.github.io/mrmopt/reference/opt_table.md):

``` r

opt_table(opt_point) |>
  select(channel, spend_delta_pct, kpi_delta_pct, cp_delta)
#> # A tibble: 6 × 4
#>   channel      spend_delta_pct kpi_delta_pct cp_delta
#>   <chr>                  <dbl>         <dbl>    <dbl>
#> 1 Paid Search         1.48e- 1        0.395    -14.9 
#> 2 Online Video        2.11e- 1        0.423    -14.2 
#> 3 Display             1.39e- 1        0.360    -14.1 
#> 4 TV                  3.01e- 2        0.0459    -7.06
#> 5 Paid Social        -6.93e- 1       -0.788     26.7 
#> 6 TOTAL              -1.11e-16        0.0930    -6.32
```

### Visualising the Allocation

[`opt_plot_allocation()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_allocation.md)
shows current vs. optimal spend as grouped bars:

``` r

opt_plot_allocation(opt_point)
```

![Current vs. optimal spend
allocation.](optimization_files/figure-html/plot-allocation-1.png)

Current vs. optimal spend allocation.

[`opt_plot_comparison()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_comparison.md)
produces a dumbbell chart showing the direction and magnitude of spend
reallocation:

``` r

opt_plot_comparison(opt_point)
```

![Spend reallocation from current to
optimal.](optimization_files/figure-html/plot-comparison-1.png)

Spend reallocation from current to optimal.

------------------------------------------------------------------------

## 3. Response Curves and Returns

To understand *why* the optimizer reallocates spend, overlay the current
and optimal positions on each channel’s response curve:

``` r

opt_plot_curves(opt_point)
```

![Response curves with current (red) and optimal (blue) spend
positions.](optimization_files/figure-html/plot-curves-1.png)

Response curves with current (red) and optimal (blue) spend positions.

[`opt_plot_returns()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_returns.md)
shows where the current and optimal points sit on each channel’s average
return (AR) and marginal return (MR) curves — this is where you can see
the efficiency trade-offs driving the allocation:

``` r

opt_plot_returns(opt_point)
```

![AR and MR curves at current and optimal
spend.](optimization_files/figure-html/plot-returns-1.png)

AR and MR curves at current and optimal spend.

------------------------------------------------------------------------

## 4. Posterior Optimization

Point estimates ignore parameter uncertainty. Posterior optimization
runs the solver across multiple MCMC draws, producing a distribution of
solutions:

``` r

opt_post <- opt_mix(
  models,
  method  = "posterior",
  n_draws = 200,
  seed    = 5291
)
#> No budget supplied; using total current weekly spend: 204,641 
#> 
#> Optimization setup:
#>   Channels:       5 
#>   Method:         posterior 
#>   Weekly budget:  204,641 
#> 
#> Optimizing across 200 posterior draws...
#>   |                                                                              |                                                                      |   0%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |==                                                                    |   4%  |                                                                              |===                                                                   |   4%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |=========                                                             |  14%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  16%  |                                                                              |============                                                          |  17%  |                                                                              |============                                                          |  18%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |================                                                      |  24%  |                                                                              |=================                                                     |  24%  |                                                                              |==================                                                    |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |=======================                                               |  34%  |                                                                              |========================                                              |  34%  |                                                                              |========================                                              |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |==========================                                            |  38%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  40%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |==============================                                        |  44%  |                                                                              |===============================                                       |  44%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |=================================                                     |  48%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |=====================================                                 |  54%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  56%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |============================================                          |  64%  |                                                                              |=============================================                         |  64%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |===============================================                       |  68%  |                                                                              |================================================                      |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |===================================================                   |  74%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  76%  |                                                                              |======================================================                |  77%  |                                                                              |======================================================                |  78%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  80%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |==========================================================            |  84%  |                                                                              |===========================================================           |  84%  |                                                                              |============================================================          |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |=============================================================         |  88%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |=================================================================     |  94%  |                                                                              |==================================================================    |  94%  |                                                                              |==================================================================    |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================| 100%
#> 
#> Posterior optimization complete.
#> Median total weekly KPI: 2,993
```

``` r

print(opt_post)
#> -- Optimization Result (posterior, 200 draws) -------------------------------- 
#> Budget: $204,641/week  |  Channels: 5
#> -- Optimal Allocation -------------------------------------------------------- 
#>   Channel           Weekly Spend                  [95% CI]          CP    Share 
#>   Paid Social            $31,212      [$8,321 – $33,266]         $59  +15.1%
#>   Paid Search            $51,329     [$50,644 – $52,842]         $62  +24.8%
#>   Online Video           $39,528     [$10,272 – $41,489]         $63  +19.1%
#>   Display                $19,571      [$5,363 – $20,524]         $68   +9.5%
#>   TV                     $65,282     [$62,073 – $87,706]         $91  +31.5%
#> -- Totals -------------------------------------------------------------------- 
#>   Optimal:  Spend $206,922  |  KPI 2,993  |  Avg CP $69
#>   Current:  Spend $204,641  |  KPI 2,757  |  Avg CP $74
#>   Change:   KPI +8.6%  |  CP $5
```

[`opt_plot_posterior()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_posterior.md)
shows the distribution of optimal spend per channel as violin plots:

``` r

opt_plot_posterior(opt_post)
```

![Posterior distribution of optimal allocations across 200
draws.](optimization_files/figure-html/plot-posterior-1.png)

Posterior distribution of optimal allocations across 200 draws.

[`opt_plot_allocation()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_allocation.md)
adds 95% credible interval error bars when used with a posterior result:

``` r

opt_plot_allocation(opt_post)
```

![Optimal allocation with 95% CIs from posterior
optimization.](optimization_files/figure-html/plot-alloc-post-1.png)

Optimal allocation with 95% CIs from posterior optimization.

------------------------------------------------------------------------

## 5. Comparing Methods

[`opt_table()`](https://bdshaff.github.io/mrmopt/reference/opt_table.md)
returns a plain tibble, so comparing two results is a standard join:

``` r

comp <- inner_join(
  opt_table(opt_point) |>
    select(channel, spend_point = optimal_spend, kpi_point = optimal_kpi),
  opt_table(opt_post) |>
    select(channel, spend_posterior = optimal_spend, kpi_posterior = optimal_kpi),
  by = "channel"
) |>
  mutate(
    spend_diff_pct = (spend_posterior / spend_point) - 1,
    kpi_diff_pct   = (kpi_posterior   / kpi_point)   - 1
  )

comp
#> # A tibble: 6 × 7
#>   channel     spend_point kpi_point spend_posterior kpi_posterior spend_diff_pct
#>   <chr>             <dbl>     <dbl>           <dbl>         <dbl>          <dbl>
#> 1 Paid Search      52132.     844.           51329.          827.        -0.0154
#> 2 Online Vid…      40980.     660.           39528.          629.        -0.0354
#> 3 Display          20022.     299.           19571.          290.        -0.0225
#> 4 TV               83186.    1127.           65282.          720.        -0.215 
#> 5 Paid Social       8321.      82.7          31212.          528.         2.75  
#> 6 TOTAL           204641.    3013.          206922.         2993.         0.0111
#> # ℹ 1 more variable: kpi_diff_pct <dbl>
```

A dumbbell chart requires only a few lines of ggplot2:

``` r

comp |>
  filter(channel != "TOTAL") |>
  mutate(channel = forcats::fct_reorder(channel, spend_point)) |>
  ggplot(aes(y = channel)) +
  geom_segment(aes(x = spend_point, xend = spend_posterior, yend = channel),
               linewidth = 0.8, color = "grey50") +
  geom_point(aes(x = spend_point),     color = "firebrick", size = 3) +
  geom_point(aes(x = spend_posterior), color = "steelblue", size = 3) +
  scale_x_continuous(labels = scales::dollar_format()) +
  labs(x = "Weekly Spend ($)", y = NULL,
       title = "Spend: Point vs. Posterior",
       subtitle = "Red = point  |  Blue = posterior") +
  theme_minimal()
```

![Point vs. posterior optimal spend per
channel.](optimization_files/figure-html/plot-compare-1.png)

Point vs. posterior optimal spend per channel.

------------------------------------------------------------------------

## 6. Period Budgets

Response curves model **weekly** spend-to-KPI relationships, but
planning often involves period budgets (quarterly, annual). The `budget`
and `n_weeks` arguments translate a total period budget into weekly
optimization:

``` r

opt_annual <- opt_mix(
  models,
  method  = "point",
  budget  = 10000000,
  n_weeks = 52
)
#> 
#> Optimization setup:
#>   Channels:       5 
#>   Method:         point 
#>   Weekly budget:  192,308 
#>   Period budget:  1e+07  ( 52  weeks)
#> 
#> Optimization converged (status: 4 )
#> Total weekly KPI: 2,722 
#> Total period KPI: 141,539
print(opt_annual)
#> -- Optimization Result (point) ----------------------------------------------- 
#> Budget: $192,308/week  |  $10,000,000 over 52 weeks  |  Channels: 5
#> -- Optimal Allocation -------------------------------------------------------- 
#>   Channel           Weekly Spend    Weekly KPI          CP    Share 
#>   Paid Social            $39,879           631         $63   20.7%
#>   Paid Search            $60,369           928         $65   31.4%
#>   Online Video           $54,151           796         $68   28.2%
#>   Display                $23,485           335         $70   12.2%
#>   TV                     $14,425            32        $448    7.5%
#> -- Totals -------------------------------------------------------------------- 
#>   Optimal:  Spend $192,308  |  KPI 2,722  |  Avg CP $71
#>   Current:  Spend $204,641  |  KPI 2,757  |  Avg CP $74
#>   Change:   KPI -1.3%  |  CP $4
#> 
#>   Period (52 weeks): $10,000,000 spend  |  141,539 KPI
```

The solution reports both weekly and period-level totals. The underlying
assumption is that the response curve is stationary across the period —
if spend-response relationships vary seasonally, this is an
approximation.

------------------------------------------------------------------------

## 7. Constraints

### Auto-Generated Constraints

By default,
[`opt_mix()`](https://bdshaff.github.io/mrmopt/reference/opt_mix.md)
derives bounds from each model’s return rate range and a
`bounds_multiplier` (default 3). This prevents the optimizer from
extrapolating far beyond observed spend levels.

### User-Supplied Constraints

For more control, pass a data frame with per-channel bounds:

``` r

my_constraints <- tibble(
  channel   = names(models),
  min_spend = c(10000, 5000, 3000, 8000, 20000),
  max_spend = c(80000, 50000, 30000, 60000, 150000)
)

opt_constrained <- opt_mix(
  models,
  method      = "point",
  budget      = 250000,
  constraints = my_constraints
)
#> 
#> Optimization setup:
#>   Channels:       5 
#>   Method:         point 
#>   Weekly budget:  250,000 
#> 
#> Optimization converged (status: 4 )
#> Total weekly KPI: 3,847
print(opt_constrained)
#> -- Optimization Result (point) ----------------------------------------------- 
#> Budget: $250,000/week  |  Channels: 5
#> -- Optimal Allocation -------------------------------------------------------- 
#>   Channel           Weekly Spend    Weekly KPI          CP    Share 
#>   Paid Social            $34,062           583         $58   13.6%
#>   Paid Search            $53,962           875         $62   21.6%
#>   Online Video           $44,079           712         $62   17.6%
#>   Display                $20,797           312         $67    8.3%
#>   TV                     $97,099         1,364         $71   38.8%
#> -- Totals -------------------------------------------------------------------- 
#>   Optimal:  Spend $250,000  |  KPI 3,847  |  Avg CP $65
#>   Current:  Spend $204,641  |  KPI 2,757  |  Avg CP $74
#>   Change:   KPI +39.6%  |  CP $9
```

### Share-Based Constraints

You can also set constraints as a fraction of total budget. For example,
ensuring TV gets at least 20% but no more than 40% of the budget:

``` r

share_constraints <- tibble(
  channel   = names(models),
  min_spend = rep(0, 5),
  max_spend = rep(200000, 5),
  min_share = c(NA, NA, NA, NA, 0.20),
  max_share = c(NA, NA, NA, NA, 0.40)
)

opt_share <- opt_mix(
  models,
  method      = "point",
  budget      = 250000,
  constraints = share_constraints
)
#> 
#> Optimization setup:
#>   Channels:       5 
#>   Method:         point 
#>   Weekly budget:  250,000 
#> 
#> Optimization converged (status: 4 )
#> Total weekly KPI: 3,419
print(opt_share)
#> -- Optimization Result (point) ----------------------------------------------- 
#> Budget: $250,000/week  |  Channels: 5
#> -- Optimal Allocation -------------------------------------------------------- 
#>   Channel           Weekly Spend    Weekly KPI          CP    Share 
#>   Online Video                $0            78          $0    0.0%
#>   TV                    $100,000         1,404         $71   40.0%
#>   Paid Search            $71,744           946         $76   28.7%
#>   Paid Social            $50,026           648         $77   20.0%
#>   Display                $28,230           342         $82   11.3%
#> -- Totals -------------------------------------------------------------------- 
#>   Optimal:  Spend $250,000  |  KPI 3,419  |  Avg CP $73
#>   Current:  Spend $204,641  |  KPI 2,757  |  Avg CP $74
#>   Change:   KPI +24%  |  CP $1
```

When both absolute and share-based bounds are present, the **tighter
constraint wins**.

### Fixed Channels

To lock a channel at a specific spend level (e.g., a contractual
commitment), set `fixed = TRUE`:

``` r

fixed_constraints <- tibble(
  channel   = names(models),
  min_spend = c(0, 0, 0, 0, 50000),
  max_spend = c(200000, 200000, 200000, 200000, 200000),
  fixed     = c(FALSE, FALSE, FALSE, FALSE, TRUE)
)

opt_fixed <- opt_mix(
  models,
  method      = "point",
  budget      = 250000,
  constraints = fixed_constraints
)
#> 
#> Optimization setup:
#>   Channels:       5 
#>   Method:         point 
#>   Weekly budget:  250,000 
#> 
#> Optimization converged (status: 4 )
#> Total weekly KPI: 3,111
```

TV is locked at \$50,000/week; the remaining \$200,000 is optimized
across the other four channels.

``` r

inner_join(
  opt_table(opt_point) |> select(channel, spend_unconstrained = optimal_spend),
  opt_table(opt_fixed) |> select(channel, spend_fixed = optimal_spend),
  by = "channel"
) |>
  filter(channel != "TOTAL") |>
  mutate(channel = forcats::fct_reorder(channel, spend_unconstrained)) |>
  ggplot(aes(y = channel)) +
  geom_segment(aes(x = spend_unconstrained, xend = spend_fixed, yend = channel),
               linewidth = 0.8, color = "grey50") +
  geom_point(aes(x = spend_unconstrained), color = "firebrick", size = 3) +
  geom_point(aes(x = spend_fixed),         color = "steelblue", size = 3) +
  scale_x_continuous(labels = scales::dollar_format()) +
  labs(x = "Weekly Spend ($)", y = NULL,
       title = "Spend: Unconstrained vs. Fixed TV",
       subtitle = "Red = unconstrained  |  Blue = fixed TV") +
  theme_minimal()
```

![Unconstrained vs. fixed-TV
optimization.](optimization_files/figure-html/compare-constrained-1.png)

Unconstrained vs. fixed-TV optimization.

------------------------------------------------------------------------

## Summary

| Function / Method | Purpose |
|----|----|
| `opt_mix(method = "point")` | Fast single-solution optimization |
| `opt_mix(method = "posterior")` | Bayesian optimization with uncertainty |
| [`print()`](https://rdrr.io/r/base/print.html) / [`opt_summary()`](https://bdshaff.github.io/mrmopt/reference/opt_summary.md) | Formatted console summary (identical output) |
| [`opt_table()`](https://bdshaff.github.io/mrmopt/reference/opt_table.md) | Tidy comparison tibble with per-channel deltas |
| [`opt_plot_allocation()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_allocation.md) | Grouped bar: current vs. optimal spend or KPI |
| [`opt_plot_comparison()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_comparison.md) | Dumbbell: current → optimal spend |
| [`opt_plot_curves()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_curves.md) | Response curves with current + optimal points |
| [`opt_plot_returns()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_returns.md) | AR/MR curves at current + optimal |
| [`opt_plot_posterior()`](https://bdshaff.github.io/mrmopt/reference/opt_plot_posterior.md) | Violin of posterior allocations (posterior only) |
| `inner_join(opt_table(a), opt_table(b))` | Side-by-side diff of two results |
