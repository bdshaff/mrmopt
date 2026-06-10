# Plot brms diagnostics for a fitted response model

Produces trace plots for the four nonlinear parameters (b, c, d, e) and
a posterior predictive check, arranged vertically as a patchwork.

## Usage

``` r
mrm_plot_diagnostics(mrm)
```

## Arguments

- mrm:

  A fitted model object of class `mrmfit`, returned by
  \[fit_response()\].

## Value

A patchwork plot object.

## Details

Use this to assess MCMC convergence and model fit after calling
\[fit_response()\]. This is equivalent to \`mrm_plot(mrm, type =
"diagnostics")\`.

## See also

\[mrm_plot()\] for the curve dashboard; \[fit_response()\] for model
fitting.
