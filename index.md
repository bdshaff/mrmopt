# mrc: Media Response Modeling in R

The goal of the `mrc` package is to provide tools for media response
modeling in R. It includes functions for fitting Bayesian response
models, response curve analysis, and media mix optimization.

## Installation

You can install the `mrc` package from GitHub using the `devtools`
package. If you don’t have `devtools` installed, you can install it from
CRAN:

``` r
install.packages("devtools")
```

Then, you can install the `mrc` package from GitHub:

``` r
devtools::install_github("bdshaff/mrc")
```

## What is a Media Response Model?

A media response model is a statistical model that quantifies the
relationship between media units(impressions/clicks/GRPs) and/or spend
and business outcomes, such as sales or conversions. These models help
marketers understand the effectiveness of their media investments beyond
observed levels. Response models are the key component required to
optimize the media mix for better performance.

## Features

- Fit Bayesian media response models using `brms`.
- Analyze response curves to understand media effectiveness.
- Optimize media mix for improved performance.
