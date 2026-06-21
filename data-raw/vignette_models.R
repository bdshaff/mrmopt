# Generate pre-fitted models for vignettes to speed up builds.
# Run this once with: source("data-raw/vignette_models.R")
# Then commit the .rds files to the package.

library(mrmopt)

# Create output directory
dir.create("inst/extdata/vignette_models", showWarnings = FALSE, recursive = TRUE)

# =========================================================================
# diagnostics_and_comparison.Rmd
# =========================================================================

data(mrmopt_data)
paid_search <- mrmopt_data |> dplyr::filter(channel == "Paid Search")

cat("Fitting fit_gompertz for diagnostics_and_comparison...\n")
fit_gompertz <- fit_response(
  data   = paid_search,
  spend  = "spend",
  kpi    = "conversions",
  date   = "week",
  type   = "gompertz",
  chains = 2,
  iter   = 1000,
  warmup = 500,
  seed   = 8214
)
saveRDS(fit_gompertz, "inst/extdata/vignette_models/fit_gompertz.rds")

cat("Fitting fit_logistic for diagnostics_and_comparison...\n")
fit_logistic <- fit_response(
  data   = paid_search,
  spend  = "spend",
  kpi    = "conversions",
  date   = "week",
  type   = "logistic",
  chains = 2,
  iter   = 1000,
  warmup = 500,
  seed   = 8214
)
saveRDS(fit_logistic, "inst/extdata/vignette_models/fit_logistic.rds")

# =========================================================================
# fitting_and_analysis.Rmd (uses fit above + a few more)
# =========================================================================

cat("Fitting fit_units for fitting_and_analysis...\n")
fit_units <- fit_response(
  data   = paid_search |> dplyr::mutate(impressions = pmax(100000, spend * 2)),
  spend  = "spend",
  kpi    = "conversions",
  date   = "week",
  units  = "impressions",
  type   = "gompertz",
  chains = 2,
  iter   = 1000,
  warmup = 500,
  seed   = 8214
)
saveRDS(fit_units, "inst/extdata/vignette_models/fit_units.rds")

cat("Fitting fit_auto for fitting_and_analysis...\n")
fit_auto <- fit_response(
  data   = paid_search,
  spend  = "spend",
  kpi    = "conversions",
  date   = "week",
  type   = "gompertz",
  auto   = TRUE,
  chains = 2,
  iter   = 1000,
  warmup = 500
)
saveRDS(fit_auto, "inst/extdata/vignette_models/fit_auto.rds")

# =========================================================================
# hierarchical_curves.Rmd
# =========================================================================

# Simulate TV data with hierarchy
set.seed(2026)
subtypes <- c("broadcast", "cable", "streaming")
stations <- list(
  broadcast = c("network_a", "network_b"),
  cable = c("cable_a", "cable_b"),
  streaming = c("streaming_a", "streaming_b", "streaming_c")
)

tv <- expand.grid(
  week = 1:52,
  station = unlist(stations),
  stringsAsFactors = FALSE
) |>
  dplyr::mutate(
    subtype = case_when(
      station %in% stations$broadcast ~ "broadcast",
      station %in% stations$cable ~ "cable",
      station %in% stations$streaming ~ "streaming"
    ),
    # Station-level scale variation
    d_station = case_when(
      station == "network_a" ~ 8000,
      station == "network_b" ~ 7500,
      station == "cable_a" ~ 6000,
      station == "cable_b" ~ 3000,  # sparse station
      station == "streaming_a" ~ 9000,
      station == "streaming_b" ~ 8500,
      station == "streaming_c" ~ 7000
    ),
    # Generate spend with some variation
    spend = pmax(5000, 50000 + rnorm(dplyr::n(), 0, 10000)),
    # Response: gompertz curve + noise
    aa_opps = pmax(100, d_station / (1 + 3 * exp(-0.005 * (spend - 60000))) + rnorm(dplyr::n(), 0, 200))
  ) |>
  dplyr::select(week, subtype, station, spend, aa_opps)

cat("Fitting fit_tv (hierarchical gompertz) for hierarchical_curves...\n")
fit_tv <- fit_response_hier(
  data   = tv,
  spend  = "spend",
  kpi    = "aa_opps",
  date   = "week",
  group  = c("subtype", "station"),
  type   = "gompertz",
  chains = 2,
  iter   = 1500,
  warmup = 750,
  seed   = 2026
)
saveRDS(fit_tv, "inst/extdata/vignette_models/fit_tv.rds")

cat("Fitting fit_tv_ll (hierarchical log_logistic) for hierarchical_curves...\n")
fit_tv_ll <- fit_response_hier(
  data   = tv,
  spend  = "spend",
  kpi    = "aa_opps",
  date   = "week",
  group  = c("subtype", "station"),
  type   = "log_logistic",
  chains = 2,
  iter   = 1500,
  warmup = 750,
  seed   = 2026
)
saveRDS(fit_tv_ll, "inst/extdata/vignette_models/fit_tv_ll.rds")

cat("Saving simulated TV data for hierarchical_curves...\n")
saveRDS(tv, "inst/extdata/vignette_models/tv_data.rds")

# =========================================================================
# optimization.Rmd (uses multiple channels)
# =========================================================================

cat("Fitting multi-channel models for optimization...\n")
digital <- mrmopt_data |> dplyr::filter(channel %in% c("Paid Search", "Display"))

opt_models <- list()
for (ch in c("Paid Search", "Display")) {
  cat("  Fitting", ch, "...\n")
  opt_models[[ch]] <- fit_response(
    data   = digital |> dplyr::filter(channel == ch),
    spend  = "spend",
    kpi    = "conversions",
    date   = "week",
    type   = "gompertz",
    chains = 2,
    iter   = 1000,
    warmup = 500,
    seed   = 8214
  )
}
saveRDS(opt_models, "inst/extdata/vignette_models/opt_models.rds")

cat("\n✓ All vignette models saved to inst/extdata/vignette_models/\n")
cat("\nFiles created:\n")
fs <- list.files("inst/extdata/vignette_models", full.names = TRUE)
for (f in fs) {
  size_mb <- file.size(f) / 1024^2
  cat(sprintf("  %s (%.1f MB)\n", basename(f), size_mb))
}
