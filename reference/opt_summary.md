# Print a formatted summary of an opt_mix_result object

Displays a formatted summary of the optimization result, including
budget info, optimal allocation per channel, and totals vs. current
performance.

## Usage

``` r
opt_summary(x, ...)
```

## Arguments

- x:

  An \`opt_mix_result\` object returned by \[opt_mix()\].

- ...:

  Additional arguments (ignored).

## Value

The object \`x\`, invisibly. Called for its side effect of printing
formatted output. Use \[opt_table()\] to retrieve a tidy tibble.
