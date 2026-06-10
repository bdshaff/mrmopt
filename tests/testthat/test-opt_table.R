# tests/testthat/test-opt_table.R
# Uses make_mock_opt_result() from helper-mock.R

# =========================================================================
# Input validation
# =========================================================================

test_that("opt_table errors on non-opt_mix_result", {
  expect_error(opt_table(list()), "opt_mix_result")
  expect_error(opt_table("not_an_opt"), "opt_mix_result")
})

# =========================================================================
# Return structure
# =========================================================================

test_that("opt_table returns a tibble", {
  res <- make_mock_opt_result()
  tbl <- opt_table(res)
  expect_s3_class(tbl, "tbl_df")
})

test_that("opt_table includes TOTAL row", {
  res <- make_mock_opt_result()
  tbl <- opt_table(res)
  expect_true("TOTAL" %in% tbl$channel)
})

test_that("opt_table has one row per channel plus TOTAL", {
  res <- make_mock_opt_result()
  tbl <- opt_table(res)
  n_channels <- nrow(res$solution)
  expect_equal(nrow(tbl), n_channels + 1L)
})

test_that("opt_table contains expected columns", {
  res <- make_mock_opt_result()
  tbl <- opt_table(res)
  expected_cols <- c(
    "channel",
    "current_spend", "optimal_spend", "spend_delta", "spend_delta_pct",
    "current_kpi", "optimal_kpi", "kpi_delta", "kpi_delta_pct",
    "current_cp", "optimal_cp", "cp_delta",
    "current_spend_share", "optimal_spend_share", "spend_share_shift",
    "current_kpi_share", "optimal_kpi_share", "kpi_share_shift"
  )
  expect_true(all(expected_cols %in% names(tbl)))
})

test_that("opt_table carries method attribute", {
  res <- make_mock_opt_result(method = "point")
  tbl <- opt_table(res)
  expect_equal(attr(tbl, "method"), "point")
})

test_that("opt_table carries n_draws attribute for posterior", {
  res <- make_mock_opt_result(method = "posterior")
  tbl <- opt_table(res)
  expect_false(is.null(attr(tbl, "n_draws")))
})

test_that("opt_table carries n_weeks attribute", {
  res <- make_mock_opt_result()
  tbl <- opt_table(res)
  expect_false(is.null(attr(tbl, "n_weeks")))
})

# =========================================================================
# TOTAL row arithmetic
# =========================================================================

test_that("opt_table TOTAL spend equals sum of channels", {
  res <- make_mock_opt_result()
  tbl <- opt_table(res)
  channel_rows <- tbl[tbl$channel != "TOTAL", ]
  total_row <- tbl[tbl$channel == "TOTAL", ]
  expect_equal(unname(total_row$optimal_spend), sum(channel_rows$optimal_spend))
  expect_equal(unname(total_row$current_spend), sum(channel_rows$current_spend))
})

test_that("opt_table spend_delta_pct is consistent with spend columns", {
  res <- make_mock_opt_result()
  tbl <- opt_table(res)
  channel_rows <- tbl[tbl$channel != "TOTAL", ]
  expect_equal(
    channel_rows$spend_delta_pct,
    (channel_rows$optimal_spend / channel_rows$current_spend) - 1,
    tolerance = 1e-10
  )
})
