# tests/testthat/test-plot_opt_mix_result.R
# Uses make_mock_opt_result() from helper-mock.R

# =========================================================================
# opt_plot_* standalone functions — input validation
# =========================================================================

test_that("opt_plot_allocation errors on non-opt_mix_result", {
  expect_error(opt_plot_allocation(list()), "opt_mix_result")
})

test_that("opt_plot_comparison errors on non-opt_mix_result", {
  expect_error(opt_plot_comparison(list()), "opt_mix_result")
})

test_that("opt_plot_posterior errors on non-opt_mix_result", {
  expect_error(opt_plot_posterior(list()), "opt_mix_result")
})

test_that("opt_plot_posterior errors on point method result", {
  res <- make_mock_opt_result(method = "point")
  expect_error(opt_plot_posterior(res), "posterior method")
})

test_that("opt_plot_curves errors on non-opt_mix_result", {
  expect_error(opt_plot_curves(list()), "opt_mix_result")
})

test_that("opt_plot_returns errors on non-opt_mix_result", {
  expect_error(opt_plot_returns(list()), "opt_mix_result")
})

# =========================================================================
# opt_plot_* standalone functions — return ggplot
# =========================================================================

test_that("opt_plot_allocation returns ggplot (spend)", {
  res <- make_mock_opt_result()
  expect_s3_class(opt_plot_allocation(res, metric = "spend"), "ggplot")
})

test_that("opt_plot_allocation returns ggplot (kpi)", {
  res <- make_mock_opt_result()
  expect_s3_class(opt_plot_allocation(res, metric = "kpi"), "ggplot")
})

test_that("opt_plot_allocation returns ggplot with CI for posterior", {
  res <- make_mock_opt_result(method = "posterior")
  expect_s3_class(opt_plot_allocation(res), "ggplot")
})

test_that("opt_plot_comparison returns ggplot", {
  res <- make_mock_opt_result()
  expect_s3_class(opt_plot_comparison(res), "ggplot")
})

test_that("opt_plot_posterior returns ggplot for posterior method", {
  res <- make_mock_opt_result(method = "posterior")
  expect_s3_class(opt_plot_posterior(res), "ggplot")
})

test_that("opt_plot_curves returns ggplot", {
  res <- make_mock_opt_result()
  expect_s3_class(opt_plot_curves(res), "ggplot")
})

test_that("opt_plot_returns returns ggplot", {
  res <- make_mock_opt_result()
  expect_s3_class(opt_plot_returns(res), "ggplot")
})

test_that("opt_plot_curves errors when mrms is NULL", {
  res <- make_mock_opt_result()
  res$mrms <- NULL
  expect_error(opt_plot_curves(res), "mrms")
})

test_that("opt_plot_returns errors when mrms is NULL", {
  res <- make_mock_opt_result()
  res$mrms <- NULL
  expect_error(opt_plot_returns(res), "mrms")
})

test_that("opt_plot_curves works with posterior method", {
  res <- make_mock_opt_result(method = "posterior")
  expect_s3_class(opt_plot_curves(res), "ggplot")
})
