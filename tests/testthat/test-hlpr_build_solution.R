# tests/testthat/test-hlpr_build_solution.R

test_that("hlpr_build_solution returns tibble with all expected columns", {
  m1 <- make_mock_mrmfit("gompertz", with_units = TRUE)
  m2 <- make_mock_mrmfit("weibull", with_units = TRUE)
  mrms <- list(ch_a = m1, ch_b = m2)

  sol <- hlpr_build_solution(
    channels = c("ch_a", "ch_b"),
    mrms = mrms,
    weekly_spend = c(200000, 300000),
    weekly_kpi = c(5000, 8000),
    n_weeks = 1
  )

  expected_cols <- c(
    "channel",
    "current_weekly_spend", "current_weekly_units", "current_weekly_kpi",
    "current_cost_per", "current_rr",
    "current_spend_share", "current_kpi_share",
    "weekly_spend", "weekly_spend_lower", "weekly_spend_upper",
    "weekly_kpi", "weekly_kpi_lower", "weekly_kpi_upper",
    "weekly_units", "weekly_units_lower", "weekly_units_upper",
    "cost_per", "rr",
    "period_spend", "period_kpi", "period_units",
    "spend_share", "kpi_share"
  )

  expect_s3_class(sol, "tbl_df")
  expect_equal(names(sol), expected_cols)
  expect_equal(nrow(sol), 2)
})


test_that("point and posterior produce identical column names", {
  m1 <- make_mock_mrmfit("gompertz", with_units = TRUE)
  m2 <- make_mock_mrmfit("weibull", with_units = TRUE)
  mrms <- list(ch_a = m1, ch_b = m2)
  spend <- c(200000, 300000)
  kpi <- c(5000, 8000)

  sol_point <- hlpr_build_solution(
    channels = c("ch_a", "ch_b"), mrms = mrms,
    weekly_spend = spend, weekly_kpi = kpi
  )

  sol_post <- hlpr_build_solution(
    channels = c("ch_a", "ch_b"), mrms = mrms,
    weekly_spend = spend, weekly_kpi = kpi,
    weekly_spend_lower = spend * 0.8, weekly_spend_upper = spend * 1.2,
    weekly_kpi_lower = kpi * 0.9, weekly_kpi_upper = kpi * 1.1
  )

  expect_identical(names(sol_point), names(sol_post))
  expect_true(all(is.na(sol_point$weekly_spend_lower)))
  expect_false(any(is.na(sol_post$weekly_spend_lower)))
})


test_that("current-state metrics match model summary", {
  m1 <- make_mock_mrmfit("gompertz", with_units = TRUE)
  mrms <- list(ch_a = m1)

  sol <- hlpr_build_solution(
    channels = "ch_a", mrms = mrms,
    weekly_spend = 200000, weekly_kpi = 5000
  )

  expect_equal(unname(sol$current_weekly_spend), unname(m1$summary$weekly_spend))
  expect_equal(unname(sol$current_weekly_kpi), unname(m1$summary$kpi_at_current))
  expect_equal(unname(sol$current_cost_per), unname(m1$summary$cp_at_current))
  expect_equal(unname(sol$current_weekly_units), unname(m1$summary$weekly_units))
})


test_that("units are NA when cost_per_unit is NULL", {
  m1 <- make_mock_mrmfit("gompertz", with_units = FALSE)
  mrms <- list(ch_a = m1)

  sol <- hlpr_build_solution(
    channels = "ch_a", mrms = mrms,
    weekly_spend = 200000, weekly_kpi = 5000
  )

  expect_true(is.na(sol$weekly_units))
  expect_true(is.na(sol$weekly_units_lower))
  expect_true(is.na(sol$weekly_units_upper))
  expect_true(is.na(sol$rr))
})


test_that("units computed correctly from cost_per_unit", {
  m1 <- make_mock_mrmfit("gompertz", with_units = TRUE)
  mrms <- list(ch_a = m1)
  spend <- 200000

  sol <- hlpr_build_solution(
    channels = "ch_a", mrms = mrms,
    weekly_spend = spend, weekly_kpi = 5000
  )

  expect_equal(unname(sol$weekly_units), spend / m1$cost_per_unit)
})


test_that("response rate computed correctly", {
  m1 <- make_mock_mrmfit("gompertz", with_units = TRUE)
  mrms <- list(ch_a = m1)
  spend <- 200000
  kpi <- 5000

  sol <- hlpr_build_solution(
    channels = "ch_a", mrms = mrms,
    weekly_spend = spend, weekly_kpi = kpi
  )

  expected_units <- spend / m1$cost_per_unit
  expect_equal(unname(sol$rr), kpi / expected_units)
})


test_that("shares sum to 1", {
  m1 <- make_mock_mrmfit("gompertz", with_units = TRUE)
  m2 <- make_mock_mrmfit("logistic", with_units = TRUE)
  mrms <- list(ch_a = m1, ch_b = m2)

  sol <- hlpr_build_solution(
    channels = c("ch_a", "ch_b"), mrms = mrms,
    weekly_spend = c(200000, 300000),
    weekly_kpi = c(5000, 8000)
  )

  expect_equal(sum(sol$spend_share), 1, tolerance = 1e-10)
  expect_equal(sum(sol$kpi_share), 1, tolerance = 1e-10)
  expect_equal(sum(sol$current_spend_share), 1, tolerance = 1e-10)
  expect_equal(sum(sol$current_kpi_share), 1, tolerance = 1e-10)
})


test_that("period scaling is correct", {
  m1 <- make_mock_mrmfit("gompertz", with_units = TRUE)
  mrms <- list(ch_a = m1)
  spend <- 200000
  kpi <- 5000
  n_weeks <- 13

  sol <- hlpr_build_solution(
    channels = "ch_a", mrms = mrms,
    weekly_spend = spend, weekly_kpi = kpi,
    n_weeks = n_weeks
  )

  expect_equal(sol$period_spend, spend * n_weeks)
  expect_equal(sol$period_kpi, kpi * n_weeks)
  expect_equal(sol$period_units, sol$weekly_units * n_weeks)
})


test_that("output is sorted by cost_per ascending", {
  m1 <- make_mock_mrmfit("gompertz", with_units = TRUE)
  m2 <- make_mock_mrmfit("weibull", with_units = TRUE)
  mrms <- list(ch_a = m1, ch_b = m2)

  sol <- hlpr_build_solution(
    channels = c("ch_a", "ch_b"), mrms = mrms,
    weekly_spend = c(500000, 100000),
    weekly_kpi = c(5000, 8000)
  )

  expect_true(all(diff(sol$cost_per) >= 0))
})
