# make_mock_response_df() is provided by helper-mock.R

test_that("returns a single-row mrm_summary with expected fields", {
  rdf   <- make_mock_response_df("gompertz")
  x_col <- "spendchannel"
  obs   <- rdf[[x_col]][seq(1, nrow(rdf), length.out = 20)]
  params <- list(b = -5, c = 0, d = 1000, e = 5e5)
  r2 <- tibble::tibble(Estimate = 0.9, Est.Error = 0.02, Q2.5 = 0.85, Q97.5 = 0.95)

  s <- hlpr_summary_core(
    rdf = rdf, x_col = x_col, rc_type = "gompertz",
    weekly_spend = mean(obs), obs_spend = obs,
    has_units = FALSE, cpu = NA_real_,
    params = params, r2 = r2,
    log_curve_no_peak = FALSE, channel = "ch1"
  )

  expect_s3_class(s, "mrm_summary")
  expect_equal(nrow(s), 1)
  expect_equal(s$channel, "ch1")
  expect_equal(s$rc_type, "gompertz")
  expect_equal(s$b, -5)
  expect_equal(s$n_weeks, length(obs))
  expect_true(all(c("range_min_spend", "range_peak_spend", "range_max_spend") %in% names(s)))
})

test_that("week percentages sum to 100", {
  rdf   <- make_mock_response_df("gompertz")
  x_col <- "spendchannel"
  obs   <- rdf[[x_col]][seq(1, nrow(rdf), length.out = 30)]
  s <- hlpr_summary_core(
    rdf = rdf, x_col = x_col, rc_type = "gompertz",
    weekly_spend = mean(obs), obs_spend = obs,
    has_units = FALSE, cpu = NA_real_,
    params = list(b = -5, c = 0, d = 1000, e = 5e5), r2 = NULL,
    log_curve_no_peak = FALSE
  )
  expect_equal(s$pct_weeks_below + s$pct_weeks_in + s$pct_weeks_above, 100,
               tolerance = 1e-6)
})

test_that("attributes carry R2, log_curve_no_peak, params_summary", {
  rdf   <- make_mock_response_df("gompertz")
  x_col <- "spendchannel"
  obs   <- rdf[[x_col]][1:10]
  pfull <- list(center = list(b = -5, c = 0, d = 1000, e = 5e5),
                lower = NULL, upper = NULL)
  s <- hlpr_summary_core(
    rdf = rdf, x_col = x_col, rc_type = "gompertz",
    weekly_spend = mean(obs), obs_spend = obs,
    has_units = FALSE, cpu = NA_real_,
    params = pfull$center, r2 = NULL,
    log_curve_no_peak = FALSE, params_full = pfull
  )
  expect_false(attr(s, "log_curve_no_peak"))
  expect_identical(attr(s, "params_summary"), pfull)
})

test_that("log-scale curve with |b| > 1 gets log_curve_no_peak = FALSE (interior MR peak)", {
  rdf   <- make_mock_response_df("log_logistic")
  x_col <- "spendchannel"
  obs   <- rdf[[x_col]][seq(1, nrow(rdf), length.out = 20)]

  # The mock uses b = -5, so |b| > 1 — MR should have an interior peak
  mr_vals <- rdf$mr[!is.na(rdf$mr)]
  expect_true(which.max(mr_vals) > 2L, info = "MR peak should be interior, not at start")

  s <- hlpr_summary_core(
    rdf = rdf, x_col = x_col, rc_type = "log_logistic",
    weekly_spend = mean(obs), obs_spend = obs,
    has_units = FALSE, cpu = NA_real_,
    params = list(b = -5, c = 0, d = 1000, e = 5e5), r2 = NULL,
    log_curve_no_peak = (which.max(mr_vals) <= 2L)
  )

  # With an interior peak, should use peak-based range (not current-spend anchor)
  expect_false(attr(s, "log_curve_no_peak"))
  # range_min should be at peak MR, not anchored to 2x current
  expect_equal(s$range_min_spend, rdf[[x_col]][which.max(mr_vals)],
               tolerance = 0.05)
})

test_that("log-scale curve with |b| <= 1 gets log_curve_no_peak = TRUE (no interior peak)", {
  # Build a response df with shallow steepness: |b| = 0.8
  x_seq  <- seq(1e4, 2e6, length.out = 200)
  x_sc   <- x_seq / 1e6
  center <- 0 + (1000 - 0) / (1 + exp(-0.8 * (log(x_sc) - log(0.5))))
  mr     <- c(NA_real_, diff(center) / diff(x_seq))
  ar     <- center / x_seq

  rdf <- data.frame(
    spendchannel = x_seq, center = center, lower = center * 0.9,
    upper = center * 1.1, ar = ar, mr = mr,
    cp = ifelse(center > 0, x_seq / center, NA_real_),
    cp_lower = NA_real_, cp_upper = NA_real_,
    ar_lower = ar * 0.9, mr_lower = mr * 0.9,
    ar_upper = ar * 1.1, mr_upper = mr * 1.1
  )

  mr_vals <- rdf$mr[!is.na(rdf$mr)]
  expect_true(which.max(mr_vals) <= 2L, info = "MR should peak at start for |b| <= 1")

  obs <- rdf$spendchannel[seq(1, nrow(rdf), length.out = 20)]
  s <- hlpr_summary_core(
    rdf = rdf, x_col = "spendchannel", rc_type = "log_logistic",
    weekly_spend = mean(obs), obs_spend = obs,
    has_units = FALSE, cpu = NA_real_,
    params = list(b = -0.8, c = 0, d = 1000, e = 5e5), r2 = NULL,
    log_curve_no_peak = (which.max(mr_vals) <= 2L)
  )

  expect_true(attr(s, "log_curve_no_peak"))
})
