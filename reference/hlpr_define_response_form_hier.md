# Define a hierarchical response form for a nonlinear model

Builds a `brms` nonlinear formula for a hierarchical (partially pooled)
response curve. The curve math is identical to
[`hlpr_define_response_form`](https://bdshaff.github.io/mrmopt/reference/hlpr_define_response_form.md)
(same `b`/`c`/`d`/`e` parameterization); the difference is that selected
parameters receive group-level (random) effects so that sub-channel
units borrow strength from the channel-level mean.

## Usage

``` r
hlpr_define_response_form_hier(
  type,
  x = NULL,
  y = NULL,
  group = NULL,
  pool = c("b", "e", "d")
)
```

## Arguments

- type:

  A character string specifying the response form. Valid options are
  "logistic", "log_logistic", "gompertz", "reflected_gompertz",
  "weibull", and "reflected_weibull".

- x:

  A character string with the (sanitized) name of the predictor (spend)
  variable.

- y:

  A character string with the (sanitized) name of the response (KPI)
  variable.

- group:

  A character vector of grouping column names, ordered from the
  outermost (broadest) to the innermost (finest) level of the hierarchy.
  A single-element vector gives one level; `c("g1", "g2")` expands to a
  nested structure `(1 | g1) + (1 | g1:g2)`.

- pool:

  A character vector naming which of `b`, `c`, `d`, `e` receive
  group-level effects. Parameters not listed are modeled with a
  population-level intercept only (`~ 1`). Default `c("b", "e", "d")`
  pools the shape parameters and lets the scale parameter vary; the
  floor `c` stays population-level.

## Value

A `brmsformula` object with `nl = TRUE`.

## Details

The nested grouping terms are built cumulatively from `group`: level `i`
uses the interaction of the first `i` grouping columns. For
`group = c("subtype", "station")` this yields
`(1 | subtype) + (1 | subtype:station)`.

## See also

[`hlpr_define_response_form`](https://bdshaff.github.io/mrmopt/reference/hlpr_define_response_form.md),
[`fit_response_hier`](https://bdshaff.github.io/mrmopt/reference/fit_response_hier.md)
