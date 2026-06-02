# mrm_summary calls mrm_infer() internally which requires predict().
# We test using the mock object which has a pre-built $summary (not re-running inference).
# Tests focus on structure, output class, and the print method.

test_that("mrm_summary errors on non-brmsfit input", {
  expect_error(mrm_summary(list(rc_type = "gompertz")), "fit_response")
})

test_that("print.mrm_summary runs without error on mock summary", {
  mock <- make_mock_mrmfit("gompertz")
  s    <- mock$summary
  class(s) <- c("mrm_summary", "tbl_df", "tbl", "data.frame")
  # print method should produce output without error
  expect_output(print(s), ignore.case = TRUE)
})

test_that("mock summary pct_weeks sum to 100", {
  mock <- make_mock_mrmfit("gompertz")
  s    <- mock$summary
  total <- s$pct_weeks_below + s$pct_weeks_in + s$pct_weeks_above
  expect_equal(total, 100, tolerance = 0.01)
})

test_that("mock summary range spend fields are positive numerics", {
  mock <- make_mock_mrmfit("gompertz")
  s    <- mock$summary
  expect_true(is.numeric(s$range_min_spend)  && s$range_min_spend  > 0)
  expect_true(is.numeric(s$range_peak_spend) && s$range_peak_spend > 0)
  expect_true(is.numeric(s$range_max_spend)  && s$range_max_spend  > 0)
})

test_that("mock summary weekly_spend is a positive scalar", {
  mock <- make_mock_mrmfit("gompertz")
  s    <- mock$summary
  expect_true(is.numeric(s$weekly_spend) && s$weekly_spend > 0)
})
