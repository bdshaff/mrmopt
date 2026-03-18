# Define a response form for a nonlinear model

This function defines a response form for a nonlinear model based on the
specified type. It uses the \`brms\` package to create a formula for the
response variable.

## Usage

``` r
hlpr_define_response_form(type, x = NULL, y = NULL)
```

## Arguments

- type:

  A character string specifying the type of response form. Valid options
  are "logistic", "log_logistic", "gompertz", "reflected_gompertz",
  "weibull", and "reflected_weibull".

- x:

  A character string representing the name of the predictor variable.

- y:

  A character string representing the name of the response variable.

## Value

A \`brms\` formula object representing the response form.

## Details

The function supports the following response forms:

- logistic: \\y = c + ((d - c)/(1 + exp(b\*(x - e))))\\

- log_logistic: \\y = c + ((d - c)/(1 + exp(b\*(log(x) - log(e))))\\

- gompertz: \\y = c + (d - c) \* exp(-exp(b \* (x - e)))\\

- reflected_gompertz: \\y = c + (d - c) \* (1 - exp(-exp(b \* (-x +
  e))))\\

- weibull: \\y = c + (d - c) \* exp(-exp(b \* (log(x) - log(e))))\\

- reflected_weibull: \\y = c + (d - c) \* (1 - exp(-exp(b \* (-log(x) +
  log(e))))\\
