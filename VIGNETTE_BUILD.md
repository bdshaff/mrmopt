# Building Vignettes

## Fast builds (for `R CMD build`, `devtools::check()`)

The following vignettes are excluded from standard package builds to
speed up CI/CD: - `fitting_and_analysis.Rmd` -
`diagnostics_and_comparison.Rmd` - `hierarchical_curves.Rmd` -
`optimization.Rmd`

These are long-running because they fit Bayesian models with Stan
sampling. They are available on the website at
<https://bdshaff.github.io/mrmopt/articles/>

## Building the website with all vignettes

To build the full pkgdown site with all vignettes:

``` r

# First, build the slow vignettes
source("data-raw/build_slow_vignettes.R")

# Then build the site
pkgdown::build_site()
```

Alternatively, if you have the cached pre-fitted models, you can edit
the vignettes to load them:

``` r

# In vignette setup chunk
fit_tv <- readRDS("../inst/extdata/vignette_models/fit_tv.rds")
```

## Development workflow

- `devtools::load_all()` — loads package code (no vignette building)
- `devtools::check()` — runs checks and tests quickly (skips slow
  vignettes)
- `devtools::check(vignettes = TRUE)` — forces building all vignettes
  (slow)
- [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
  — builds website (after running `data-raw/build_slow_vignettes.R`)
