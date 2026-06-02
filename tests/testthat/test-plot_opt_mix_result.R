# tests/testthat/test-plot_opt_mix_result.R
# Uses make_mock_opt_result() from helper-mock.R

# =========================================================================
# Existing plot types
# =========================================================================

test_that("plot allocation returns ggplot", {
  res <- make_mock_opt_result()
  p <- plot(res, type = "allocation")
  expect_s3_class(p, "ggplot")
})

test_that("plot kpi returns ggplot", {
  res <- make_mock_opt_result()
  p <- plot(res, type = "kpi")
  expect_s3_class(p, "ggplot")
})

test_that("plot comparison returns ggplot", {
  res <- make_mock_opt_result()
  p <- plot(res, type = "comparison")
  expect_s3_class(p, "ggplot")
})

test_that("plot posterior returns ggplot for posterior method", {
  res <- make_mock_opt_result(method = "posterior")
  p <- plot(res, type = "posterior")
  expect_s3_class(p, "ggplot")
})

test_that("plot posterior falls back to allocation for point method", {
  res <- make_mock_opt_result(method = "point")
  expect_message(
    p <- plot(res, type = "posterior"),
    "not available"
  )
  expect_s3_class(p, "ggplot")
})

# =========================================================================
# New plot types: curves and returns
# =========================================================================

test_that("plot curves returns ggplot", {
  res <- make_mock_opt_result()
  p <- plot(res, type = "curves")
  expect_s3_class(p, "ggplot")
})

test_that("plot returns returns ggplot", {
  res <- make_mock_opt_result()
  p <- plot(res, type = "returns")
  expect_s3_class(p, "ggplot")
})

test_that("plot curves errors when mrms is NULL", {
  res <- make_mock_opt_result()
  res$mrms <- NULL
  expect_error(plot(res, type = "curves"), "mrms")
})

test_that("plot returns errors when mrms is NULL", {
  res <- make_mock_opt_result()
  res$mrms <- NULL
  expect_error(plot(res, type = "returns"), "mrms")
})

test_that("plot curves works with posterior method", {
  res <- make_mock_opt_result(method = "posterior")
  p <- plot(res, type = "curves")
  expect_s3_class(p, "ggplot")
})
