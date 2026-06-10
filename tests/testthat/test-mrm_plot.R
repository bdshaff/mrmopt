# Tests for mrm_plot() and mrm_plot_diagnostics()
# mrm_plot() is the successor to plot.mrmfit(); diagnostics requires real MCMC
# draws so we only test the dashboard path here using the mock fixture.

test_that("mrm_plot errors on non-mrmfit input", {
  expect_error(mrm_plot(list()), "fit_response")
})

test_that("mrm_plot dashboard returns a patchwork object", {
  mock <- make_mock_mrmfit("gompertz")
  p <- mrm_plot(mock)
  expect_s3_class(p, "patchwork")
})

test_that("mrm_plot errors informatively when units not available", {
  mock <- make_mock_mrmfit("gompertz")
  expect_error(mrm_plot(mock, x_var = "units"), "units")
})

test_that("mrm_plot accepts interval = 'confidence' without error", {
  mock <- make_mock_mrmfit("gompertz")
  expect_no_error(mrm_plot(mock, interval = "confidence"))
})

test_that("mrm_plot accepts show_mr = TRUE without error", {
  mock <- make_mock_mrmfit("gompertz")
  expect_no_error(mrm_plot(mock, show_mr = TRUE))
})

test_that("mrm_plot accepts markup = FALSE without error", {
  mock <- make_mock_mrmfit("gompertz")
  expect_no_error(mrm_plot(mock, markup = FALSE))
})

test_that("mrm_plot_diagnostics errors on non-mrmfit input", {
  expect_error(mrm_plot_diagnostics(list()), "fit_response")
})


