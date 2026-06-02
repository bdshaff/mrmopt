# Summary method for opt_mix_result objects

Returns a tidy comparison tibble showing current vs. optimal allocation
per channel with absolute and percentage deltas.

## Usage

``` r
# S3 method for class 'opt_mix_result'
summary(object, ...)
```

## Arguments

- object:

  An \`opt_mix_result\` object returned by \[opt_mix()\].

- ...:

  Additional arguments (ignored).

## Value

A tibble with one row per channel comparing current and optimal
performance, including spend/KPI/units deltas (absolute and percent),
cost-per change, and share shifts.
