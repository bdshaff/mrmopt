# hlpr_unscale_data_points is defined inside mrm_plot_response.R (internal helper)

make_scale_mock <- function(x_sc, y_sc, scale_values,
                            n_anchor = 0L, cost_per_unit = NULL) {
  mock <- list(
    data = data.frame(opps = y_sc, spendchannel = x_sc),
    formula = list(resp = "opps"),
    scale_values = scale_values,
    n_anchor_rows = n_anchor,
    cost_per_unit = cost_per_unit,
    units_col = if (!is.null(cost_per_unit)) "units_channel" else NULL
  )
  class(mock) <- c("mrmfit", "mock_brmsfit", "brmsfit")
  mock
}

test_that("returns data frame with x_plot_val and y_plot_val", {
  sv   <- list(x_min = 0, x_max = 1e6, x_offset = 0, y_min = 0, y_max = 1000)
  mock <- make_scale_mock(rep(0.5, 5), rep(0.6, 5), sv)
  res  <- hlpr_unscale_data_points(mock, "spend")
  expect_named(res, c("x_plot_val", "y_plot_val"))
})

test_that("min_max: correctly unscales x and y", {
  sv   <- list(x_min = 0, x_max = 1e6, x_offset = 0, y_min = 0, y_max = 1000)
  x_sc <- c(0.1, 0.5, 1.0)
  y_sc <- c(0.2, 0.5, 0.9)
  mock <- make_scale_mock(x_sc, y_sc, sv)
  res  <- hlpr_unscale_data_points(mock, "spend")
  expect_equal(res$x_plot_val, x_sc * 1e6, tolerance = 1e-6)
  expect_equal(res$y_plot_val, y_sc * 1000, tolerance = 1e-6)
})

test_that("std: correctly unscales x and y", {
  sv   <- list(x_mean = 3e5, x_sd = 1e5, x_offset = 0, y_mean = 500, y_sd = 100)
  x_sc <- c(-1, 0, 1)
  y_sc <- c(-1, 0, 1)
  mock <- make_scale_mock(x_sc, y_sc, sv)
  res  <- hlpr_unscale_data_points(mock, "spend")
  expect_equal(res$x_plot_val, x_sc * 1e5 + 3e5, tolerance = 1e-6)
  expect_equal(res$y_plot_val, y_sc * 100 + 500, tolerance = 1e-6)
})

test_that("excludes anchor rows from output", {
  sv     <- list(x_min = 0, x_max = 1e6, x_offset = 0, y_min = 0, y_max = 1000)
  # First row is the anchor (x=0, y=0)
  x_sc   <- c(0, 0.2, 0.5, 0.8)
  y_sc   <- c(0, 0.2, 0.5, 0.8)
  mock   <- make_scale_mock(x_sc, y_sc, sv, n_anchor = 1L)
  res    <- hlpr_unscale_data_points(mock, "spend")
  expect_equal(nrow(res), 3)
  expect_false(any(res$x_plot_val == 0))
})

test_that("converts x to units when x_var = 'units' and cost_per_unit is set", {
  sv   <- list(x_min = 0, x_max = 1e6, x_offset = 0, y_min = 0, y_max = 1000)
  x_sc <- c(0.1, 0.5, 1.0)
  y_sc <- c(0.2, 0.5, 0.9)
  mock <- make_scale_mock(x_sc, y_sc, sv, cost_per_unit = 0.05)
  res  <- hlpr_unscale_data_points(mock, "units")
  expect_equal(res$x_plot_val, (x_sc * 1e6) / 0.05, tolerance = 1e-6)
})
