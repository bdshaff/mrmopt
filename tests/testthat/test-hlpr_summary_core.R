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
