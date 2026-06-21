test_that("min_max non-log form unscales b/c/d/e correctly", {
  sv <- list(x_min = 0, x_max = 100, x_offset = 0, y_min = 0, y_max = 500)
  v  <- c(b = -5, c = 0.1, d = 0.9, e = 0.5)
  out <- hlpr_unscale_params(v, sv, "gompertz")
  expect_equal(unname(out["b"]), -5 / 100)
  expect_equal(unname(out["e"]), 0.5 * 100)
  expect_equal(unname(out["c"]), 0.1 * 500)
  expect_equal(unname(out["d"]), 0.9 * 500)
})

test_that("std scaling unscales b/c/d/e correctly", {
  sv <- list(x_mean = 50, x_sd = 20, x_offset = 0, y_mean = 250, y_sd = 100)
  v  <- c(b = -5, c = 0.1, d = 0.9, e = 0.5)
  out <- hlpr_unscale_params(v, sv, "gompertz")
  expect_equal(unname(out["b"]), -5 / 20)
  expect_equal(unname(out["e"]), 0.5 * 20 + 50)
  expect_equal(unname(out["c"]), 0.1 * 100 + 250)
  expect_equal(unname(out["d"]), 0.9 * 100 + 250)
})

test_that("log forms leave b unchanged and scale e by x_max", {
  sv <- list(x_min = 0, x_max = 100, x_offset = 0, y_min = 0, y_max = 500)
  v  <- c(b = -5, c = 0.1, d = 0.9, e = 0.5)
  out <- hlpr_unscale_params(v, sv, "weibull")
  expect_equal(unname(out["b"]), -5)            # unchanged
  expect_equal(unname(out["e"]), 0.5 * 100)
})

test_that("x_offset is subtracted from e", {
  sv <- list(x_min = 0, x_max = 100, x_offset = 2, y_min = 0, y_max = 500)
  v  <- c(b = -5, c = 0.1, d = 0.9, e = 0.5)
  out <- hlpr_unscale_params(v, sv, "gompertz")
  expect_equal(unname(out["e"]), 0.5 * 100 + 0 - 2)
})

test_that("NULL scale_values returns the vector unchanged", {
  v <- c(b = -5, c = 0.1, d = 0.9, e = 0.5)
  expect_equal(hlpr_unscale_params(v, NULL, "gompertz"), v)
})
