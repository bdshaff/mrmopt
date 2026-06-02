# Interpolate response metrics at an arbitrary spend level

Uses linear interpolation on the pre-computed \`response_df\` to obtain
KPI, AR, MR, and CP at a given spend value. Avoids re-fitting or
re-predicting from the brms model.

## Usage

``` r
hlpr_opt_metrics(mrm, spend)
```

## Arguments

- mrm:

  An \`mrmfit\` object with a \`\$response_df\`.

- spend:

  Numeric; the spend value to evaluate at (original units).

## Value

A named list with elements \`kpi\`, \`ar\`, \`mr\`, \`cp\`.
