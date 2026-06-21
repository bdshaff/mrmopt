# Build slow vignettes separately for pkgdown website
# Run this once before building the pkgdown site:
#   source("data-raw/build_slow_vignettes.R")
#   pkgdown::build_site()

library(knitr)
library(rmarkdown)

vignette_dir <- "vignettes"
output_dir <- "docs/articles"

dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# List of slow vignettes to build
slow_vignettes <- c(
  "fitting_and_analysis.Rmd",
  "diagnostics_and_comparison.Rmd",
  "hierarchical_curves.Rmd",
  "optimization.Rmd"
)

for (vig in slow_vignettes) {
  input <- file.path(vignette_dir, vig)
  output_file <- sub("\\.Rmd$", ".html", vig)
  
  cat("\n=================================================================\n")
  cat("Building:", vig, "\n")
  cat("=================================================================\n")
  
  tryCatch({
    rmarkdown::render(
      input,
      output_file = output_file,
      output_dir = output_dir,
      quiet = FALSE
    )
    cat("✓ Successfully built", vig, "\n")
  }, error = function(e) {
    cat("✗ Error building", vig, ":\n")
    print(e)
  })
}

cat("\n✓ Slow vignettes built to docs/articles/\n")
