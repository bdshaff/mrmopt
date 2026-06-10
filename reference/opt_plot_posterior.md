# Posterior distribution of optimal spend allocation

Produces a violin + boxplot showing the distribution of optimal spend
per channel across posterior draws. Only available for results from
\`method = "posterior"\`.

## Usage

``` r
opt_plot_posterior(x, ...)
```

## Arguments

- x:

  An \`opt_mix_result\` object returned by \[opt_mix()\] with \`method =
  "posterior"\`.

- ...:

  Additional arguments (currently unused).

## Value

A ggplot object.
