# Plot a fitted response model

Produces either a three-panel curve dashboard or brms model diagnostics.

## Usage

``` r
mrm_plot(
  mrm,
  type = c("dashboard", "diagnostics"),
  x_var = c("spend", "units"),
  show_mr = FALSE,
  markup = TRUE,
  interval = c("prediction", "confidence"),
  ...
)
```

## Arguments

- mrm:

  A fitted model object of class `mrmfit`, returned by
  \[fit_response()\].

- type:

  Character; `"dashboard"` (default) for the three-panel curve display,
  or `"diagnostics"` for brms convergence plots (trace plots + posterior
  predictive check). For diagnostics, prefer calling
  \[mrm_plot_diagnostics()\] directly.

- x_var:

  Character; `"spend"` (default) or `"units"` for the x-axis variable.

- show_mr:

  Logical; overlay the marginal return curve on the response panel?
  Default is `FALSE`.

- markup:

  Logical; show range/current annotations? Default is `TRUE`.

- interval:

  Type of credible interval. `"prediction"` (default) includes
  observation noise. `"confidence"` shows uncertainty about the mean
  curve only (tighter bands).

- ...:

  Additional arguments (currently unused).

## Value

A patchwork plot object.

## Details

The \*\*dashboard\*\* (default) composes three individual panel
functions into a single patchwork layout:

1.  \[mrm_plot_response()\] — response curve with credible interval

2.  \[mrm_plot_return()\] — absolute and marginal return curves

3.  \[mrm_plot_costper()\] — cost per KPI curve

Use \`mrm_plot()\` for a quick overview. Use the individual
\`mrm_plot\_\*()\` functions when you need a single panel, want to
control parameters not exposed here (e.g., \`xrange\`, \`length.out\`),
or need to compose your own multi-panel layout. For convergence
diagnostics, use \[mrm_plot_diagnostics()\].

## See also

\[mrm_plot_response()\], \[mrm_plot_return()\], \[mrm_plot_costper()\]
for individual panels; \[mrm_plot_diagnostics()\] for convergence plots;
\[mrms_plot_compare()\] for comparing multiple fitted models.
