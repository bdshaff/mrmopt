# Parse user-supplied constraints data frame

Supports absolute bounds (\`min_spend\`, \`max_spend\`), share-based
bounds (\`min_share\`, \`max_share\` as fractions of budget), and fixed
channels (\`fixed = TRUE\` locks spend at \`min_spend\`). When both
absolute and share-based bounds are present, the tighter constraint
wins.

## Usage

``` r
hlpr_parse_constraints(constraints, channels, weekly_budget)
```
