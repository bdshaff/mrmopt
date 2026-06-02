# Extract and unscale posterior draws from fitted MRM models

Pre-processes posterior draws from one or more \`mrmfit\` objects so
they can be evaluated directly with \`rm_dispatch()\` on unscaled
(original-unit) x values. This avoids the overhead of
\`brms::posterior_epred()\` in tight optimization loops.

## Usage

``` r
hlpr_extract_draws(mrms)
```

## Arguments

- mrms:

  A single \`mrmfit\` object or a list of \`mrmfit\` objects.

## Value

A list (one element per model) of lists, each containing:

- curve_fn:

  The response curve function from \`rm_dispatch()\`.

- b, c, d, e:

  Numeric vectors of unscaled posterior draws.

- n_draws:

  Number of posterior draws available.

- channel:

  Channel name (from list names, if any).
