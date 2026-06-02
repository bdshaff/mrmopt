# Plot method for opt_mix_compare objects

Produces a dumbbell chart comparing two optimization results side by
side.

## Usage

``` r
# S3 method for class 'opt_mix_compare'
plot(x, type = c("spend", "kpi"), ...)
```

## Arguments

- x:

  An \`opt_mix_compare\` tibble returned by \[compare()\].

- type:

  Character; \`"spend"\` (default) or \`"kpi"\`.

- ...:

  Additional arguments (currently unused).

## Value

A ggplot object.
