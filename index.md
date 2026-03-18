# Media Response Modeling

Media Response Modeling (MRM) is part of a broader set of techniques and
models under the Media Mix Modeling (MMM) umbrella. MRM focuses on
modeling, quantifying, and analyzing the non-linear saturation
(diminishing returns) relationship between media spend and/or
(impressions/clicks/GRPs) and business outcomes, such as sales or
conversions. These relationships are modeled as non-linear response
curves that capture the diminishing returns of media investments.
Establishing response curves for a mix of media is critical for
optimizing the media mix for better performance, as it allows marketers
to understand the effectiveness of their media investments beyond
observed levels.

# mrmopt: Media Response Modeling in R

`mrmopt` is an R package designed to facilitate media response modeling
using Bayesian methods. It provides tools for fitting media response
models, analyzing response curves, and optimizing media mix for improved
performance. The goal of the `mrmopt` package is to make it easier for
marketers and analysts to apply media response modeling techniques to
their data, enabling them to make informed decisions about their media
investments. The focus of the package is to comprehensively model the
uncertainly around the response curves and build optimizations from a
broader set of scenarios, rather than just optimizing for a single point
estimate of the response curve. Bayesian estimation powered by `brms`
package enables simultaneously a robust and flexible framework for
modeling media response while remaining within the bounds of a set the
non-linear response models commonly used (Logistic, Weibull, Gompertz,
etc.). While flexible, the package is designed to be user-friendly and
accessible to marketers and analysts who may not have extensive
experience with Bayesian modeling, providing smart automations,
defaults, and tools to guide customization.

## Installation

You can install the `mrmopt` package from GitHub using the `devtools`
package. If you don’t have `devtools` installed, you can install it from
CRAN:

``` r
install.packages("devtools")
```

Then, you can install the `mrmopt` package from GitHub:

``` r
devtools::install_github("bdshaff/mrmopt")
```

## Features

- Fit Bayesian media response models using `brms`.
- Analyze response curves to understand media effectiveness.
- Optimize media mix for improved performance.

## Documentation and Tutorials

Visit the companion website for detailed documentation, tutorials, and
examples on how to use the `mrmopt` package for media response modeling:
<https://bdshaff.github.io/mrmopt/>
