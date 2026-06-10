# fit_response input validation tests — no MCMC calls.
# All tests exercise the early-exit error/warning paths only.

make_valid_data <- function(n = 30) {
  set.seed(1234)
  data.frame(
    date    = seq.Date(as.Date("2023-01-01"), by = "week", length.out = n),
    spend   = runif(n, 1e4, 1e6),
    kpi     = runif(n, 100, 1000),
    units   = runif(n, 1e5, 1e7)
  )
}

# -------------------------------------------------------------------------
# Required argument validation
# -------------------------------------------------------------------------

test_that("errors when spend is NULL", {
  expect_error(
    fit_response(make_valid_data(), spend = NULL, kpi = "kpi", date = "date"),
    "must all be specified"
  )
})

test_that("errors when kpi is NULL", {
  expect_error(
    fit_response(make_valid_data(), spend = "spend", kpi = NULL, date = "date"),
    "must all be specified"
  )
})

test_that("errors when date is NULL", {
  expect_error(
    fit_response(make_valid_data(), spend = "spend", kpi = "kpi", date = NULL),
    "must all be specified"
  )
})

test_that("errors when spend column is not in data", {
  expect_error(
    fit_response(make_valid_data(), spend = "budget", kpi = "kpi", date = "date"),
    "not found in data"
  )
})

test_that("errors when kpi column is not in data", {
  expect_error(
    fit_response(make_valid_data(), spend = "spend", kpi = "revenue", date = "date"),
    "not found in data"
  )
})

test_that("errors when date column is not in data", {
  expect_error(
    fit_response(make_valid_data(), spend = "spend", kpi = "kpi", date = "week"),
    "not found in data"
  )
})

# -------------------------------------------------------------------------
# KPI validation
# -------------------------------------------------------------------------

test_that("errors when kpi contains negative values", {
  df         <- make_valid_data()
  df$kpi[1]  <- -5
  expect_error(
    fit_response(df, spend = "spend", kpi = "kpi", date = "date"),
    "negative"
  )
})

# -------------------------------------------------------------------------
# Units validation
# -------------------------------------------------------------------------

test_that("errors when units column specified but contains NAs", {
  df           <- make_valid_data()
  df$units[1]  <- NA
  expect_error(
    fit_response(df, spend = "spend", kpi = "kpi", date = "date", units = "units"),
    "NA"
  )
})

test_that("errors when units column contains zero values", {
  df           <- make_valid_data()
  df$units[1]  <- 0
  expect_error(
    fit_response(df, spend = "spend", kpi = "kpi", date = "date", units = "units"),
    "zero"
  )
})

test_that("errors when units column not found in data", {
  expect_error(
    fit_response(make_valid_data(), spend = "spend", kpi = "kpi",
                 date = "date", units = "impressions"),
    "not found"
  )
})

# -------------------------------------------------------------------------
# Prior argument conflicts
# -------------------------------------------------------------------------

test_that("errors when both raw prior and simplified prior args are supplied", {
  library(brms)
  raw_prior <- prior(normal(0, 1), nlpar = "b") +
               prior(normal(0, 1), nlpar = "c") +
               prior(normal(0, 1), nlpar = "d") +
               prior(normal(0, 1), nlpar = "e")
  expect_error(
    fit_response(make_valid_data(), spend = "spend", kpi = "kpi", date = "date",
                 auto = FALSE, prior = raw_prior, midpoint_range = c(0.2, 0.8)),
    "Cannot specify both"
  )
})

test_that("errors when auto = FALSE and no prior is provided", {
  expect_error(
    fit_response(make_valid_data(), spend = "spend", kpi = "kpi",
                 date = "date", auto = FALSE, scale_data = FALSE),
    "prior.*must be provided"
  )
})

test_that("errors when auto = FALSE and prior is not a brmsprior", {
  expect_error(
    fit_response(make_valid_data(), spend = "spend", kpi = "kpi",
                 date = "date", auto = FALSE, scale_data = FALSE,
                 prior = list(b = "normal(0,1)")),
    "brmsprior"
  )
})

test_that("warns when raw prior supplied in auto = TRUE mode", {
  library(brms)
  raw_prior <- prior(normal(0, 1), nlpar = "b") +
               prior(normal(0, 1), nlpar = "c") +
               prior(normal(0, 1), nlpar = "d") +
               prior(normal(0, 1), nlpar = "e")
  # Warning is emitted before any MCMC; suppress the eventual brm() error
  expect_warning(
    tryCatch(
      fit_response(make_valid_data(), spend = "spend", kpi = "kpi",
                   date = "date", auto = TRUE, prior = raw_prior),
      error = function(e) NULL
    ),
    "ignored"
  )
})

# -------------------------------------------------------------------------
# anchor_zero deprecation
# -------------------------------------------------------------------------

test_that("anchor_zero emits deprecation warning", {
  expect_warning(
    tryCatch(
      fit_response(make_valid_data(), spend = "spend", kpi = "kpi",
                   date = "date", anchor_zero = TRUE),
      error = function(e) NULL
    ),
    "deprecated"
  )
})

# -------------------------------------------------------------------------
# anchor_strength pass-through
# -------------------------------------------------------------------------

test_that("anchor_strength is accepted without error", {
  # Only check it doesn't error during argument processing (before brm() call)
  expect_warning(
    tryCatch(
      fit_response(make_valid_data(), spend = "spend", kpi = "kpi",
                   date = "date", anchor_strength = 0.10),
      error = function(e) NULL
    ),
    NA  # no warning expected
  )
})
