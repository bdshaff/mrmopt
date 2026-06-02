# tests/testthat/test-hlpr_opt_metrics.R

test_that("hlpr_opt_metrics returns named list with kpi, ar, mr, cp", {
  m <- make_mock_mrmfit("gompertz", with_units = TRUE)
  rdf <- m$response_df
  x_col <- names(rdf)[1]
  mid_spend <- stats::median(rdf[[x_col]])

  result <- hlpr_opt_metrics(m, mid_spend)

  expect_type(result, "list")
  expect_named(result, c("kpi", "ar", "mr", "cp"))
  expect_true(all(vapply(result, is.numeric, logical(1))))
})

test_that("hlpr_opt_metrics interpolates correctly at known point", {
  m <- make_mock_mrmfit("gompertz", with_units = TRUE)
  rdf <- m$response_df
  x_col <- names(rdf)[1]

  # Pick an exact point from the response_df
  idx <- 100
  exact_spend <- rdf[[x_col]][idx]
  result <- hlpr_opt_metrics(m, exact_spend)

  expect_equal(result$kpi, rdf$center[idx], tolerance = 1e-6)
  expect_equal(result$ar, rdf$ar[idx], tolerance = 1e-6)
})

test_that("hlpr_opt_metrics extrapolates at boundaries", {
  m <- make_mock_mrmfit("gompertz", with_units = TRUE)
  rdf <- m$response_df
  x_col <- names(rdf)[1]

  # Beyond max should still return a value (rule = 2)
  beyond <- max(rdf[[x_col]]) * 2
  result <- hlpr_opt_metrics(m, beyond)

  expect_true(is.finite(result$kpi))
  expect_true(is.finite(result$ar))
})
