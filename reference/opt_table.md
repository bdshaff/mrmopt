# Tidy comparison table for opt_mix_result objects

Returns a tidy tibble comparing current vs. optimal allocation per
channel with absolute and percentage deltas for spend, KPI, cost-per,
and shares.

## Usage

``` r
opt_table(x, ...)
```

## Arguments

- x:

  An \`opt_mix_result\` object returned by \[opt_mix()\].

- ...:

  Additional arguments (ignored).

## Value

A tibble with one row per channel (plus a TOTAL row) comparing current
and optimal performance, including spend/KPI/units deltas (absolute and
percent), cost-per change, and share shifts.
