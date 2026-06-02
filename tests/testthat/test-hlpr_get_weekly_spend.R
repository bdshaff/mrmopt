# hlpr_get_weekly_spend computes mean(data[[2]]) unscaled using scale_values.
# data[[2]] is the x (spend) column — brms stores data with response first, x second.

make_spend_mock <- function(x_scaled, y_scaled, scale_values) {
  list(
    data = data.frame(opps = y_scaled, spendchannel = x_scaled),
    scale_values = scale_values,
    n_anchor_rows = 0L
  )
}

test_that("min_max: returns correct weekly spend", {
  sv      <- list(x_min = 0, x_max = 1e6, x_offset = 0, y_min = 0, y_max = 1000)
  x_sc    <- rep(0.5, 10)       # scaled mean = 0.5
  mock    <- make_spend_mock(x_sc, runif(10), sv)
  result  <- hlpr_get_weekly_spend(mock)
  # 0.5 * (1e6 - 0) + 0 - 0 = 500000
  expect_equal(result, 500000)
})

test_that("std: returns correct weekly spend", {
  sv     <- list(x_mean = 300000, x_sd = 100000, x_offset = 0, y_mean = 500, y_sd = 100)
  x_sc   <- rep(0, 10)        # scaled mean = 0 -> raw = mean
  mock   <- make_spend_mock(x_sc, runif(10), sv)
  result <- hlpr_get_weekly_spend(mock)
  # 0 * 100000 + 300000 - 0 = 300000
  expect_equal(result, 300000)
})

test_that("applies x_offset correctly", {
  sv     <- list(x_min = 0, x_max = 1e6, x_offset = 1000, y_min = 0, y_max = 1000)
  x_sc   <- rep(0.5, 10)
  mock   <- make_spend_mock(x_sc, runif(10), sv)
  result <- hlpr_get_weekly_spend(mock)
  # 0.5 * 1e6 + 0 - 1000 = 499000
  expect_equal(result, 499000)
})

test_that("errors when scale_values contains neither x_min/x_max nor x_mean/x_sd", {
  sv   <- list(x_offset = 0, y_min = 0, y_max = 1000)
  mock <- make_spend_mock(rep(0.5, 5), runif(5), sv)
  expect_error(hlpr_get_weekly_spend(mock), "scaling method")
})

test_that("returns a scalar numeric", {
  sv     <- list(x_min = 0, x_max = 1e6, x_offset = 0, y_min = 0, y_max = 1000)
  x_sc   <- runif(20, 0, 1)
  mock   <- make_spend_mock(x_sc, runif(20), sv)
  result <- hlpr_get_weekly_spend(mock)
  expect_length(result, 1)
  expect_type(result, "double")
})
