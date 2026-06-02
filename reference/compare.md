# Compare two opt_mix_result objects side by side

Creates a tidy tibble showing how two optimization results differ per
channel. Useful for comparing point vs. posterior methods, different
budgets, or different constraint scenarios.

## Usage

``` r
compare(a, b, labels = NULL)

# S3 method for class 'opt_mix_result'
compare(a, b, labels = NULL)
```

## Arguments

- a:

  An \`opt_mix_result\` object (labeled as the first result).

- b:

  An \`opt_mix_result\` object (labeled as the second result).

- labels:

  Character vector of length 2 giving labels for each result. Defaults
  to \`c("a", "b")\` or the method names if both are \`opt_mix_result\`
  objects with different methods.

## Value

A tibble with one row per channel, showing spend/KPI/CP from each result
and the deltas between them.
