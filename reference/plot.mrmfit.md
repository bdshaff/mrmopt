# Plot method for mrmfit objects

Produces either a three-panel curve dashboard (response, AR/MR, cost per
KPI) or brms model diagnostics (trace plots and posterior predictive
check).

## Usage

``` r
# S3 method for class 'mrmfit'
plot(
  x,
  type = c("dashboard", "diagnostics"),
  x_var = c("spend", "units"),
  show_mr = FALSE,
  markup = TRUE,
  ...
)
```

## Arguments

- x:

  A fitted model object of class `mrmfit`.

- type:

  Character; `"dashboard"` (default) for the three-panel curve display,
  or `"diagnostics"` for brms convergence plots.

- x_var:

  Character; `"spend"` (default) or `"units"`.

- show_mr:

  Logical; overlay MR on the response panel? Default is FALSE.

- markup:

  Logical; show range/current annotations? Default is TRUE.

- ...:

  Additional arguments (currently unused).

## Value

A patchwork plot object (invisibly for diagnostics).
