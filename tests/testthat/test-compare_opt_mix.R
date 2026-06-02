# tests/testthat/test-compare_opt_mix.R
# Reuses make_mock_opt_result() from test-plot_opt_mix_result.R (sourced via helper)

# =========================================================================
# compare()
# =========================================================================

test_that("compare returns tibble with correct structure", {
  a <- make_mock_opt_result()
  b <- make_mock_opt_result()
  result <- compare(a, b)

  expect_s3_class(result, "opt_mix_compare")
  expect_s3_class(result, "tbl_df")
  # n_channels + TOTAL row
  expect_equal(nrow(result), 3)
  expect_true("TOTAL" %in% result$channel)
})

test_that("compare auto-labels from method names", {
  a <- make_mock_opt_result(method = "point")
  b <- make_mock_opt_result(method = "posterior")
  result <- compare(a, b)

  labels <- attr(result, "labels")
  expect_equal(labels, c("point", "posterior"))
  expect_true("spend_point" %in% names(result))
  expect_true("spend_posterior" %in% names(result))
})

test_that("compare uses custom labels", {
  a <- make_mock_opt_result()
  b <- make_mock_opt_result()
  result <- compare(a, b, labels = c("scenario_A", "scenario_B"))

  expect_true("spend_scenario_A" %in% names(result))
  expect_true("kpi_scenario_B" %in% names(result))
})

test_that("compare errors when b is not opt_mix_result", {
  a <- make_mock_opt_result()
  expect_error(compare(a, "not_a_result"), "opt_mix_result")
})

test_that("compare errors when labels is wrong length", {
  a <- make_mock_opt_result()
  b <- make_mock_opt_result()
  expect_error(compare(a, b, labels = "one"), "length 2")
})

test_that("compare warns on mismatched channels", {
  a <- make_mock_opt_result()
  b <- make_mock_opt_result()
  b$solution$channel[1] <- "different_channel"
  expect_warning(compare(a, b), "Channel sets differ")
})

test_that("compare has spend_diff and kpi_diff columns", {
  a <- make_mock_opt_result()
  b <- make_mock_opt_result()
  result <- compare(a, b)

  expect_true("spend_diff" %in% names(result))
  expect_true("spend_diff_pct" %in% names(result))
  expect_true("kpi_diff" %in% names(result))
  expect_true("kpi_diff_pct" %in% names(result))
  expect_true("cp_diff" %in% names(result))
})


# =========================================================================
# plot.opt_mix_compare
# =========================================================================

test_that("plot.opt_mix_compare spend returns ggplot", {
  a <- make_mock_opt_result()
  b <- make_mock_opt_result()
  comp <- compare(a, b)
  p <- plot(comp, type = "spend")
  expect_s3_class(p, "ggplot")
})

test_that("plot.opt_mix_compare kpi returns ggplot", {
  a <- make_mock_opt_result()
  b <- make_mock_opt_result()
  comp <- compare(a, b)
  p <- plot(comp, type = "kpi")
  expect_s3_class(p, "ggplot")
})
