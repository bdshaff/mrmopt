# tests/testthat/test-hlpr_extract_draws.R

test_that("hlpr_extract_draws returns correct structure for single model", {
  m <- make_mock_mrmfit("gompertz")
  result <- hlpr_extract_draws(m)

  expect_type(result, "list")
  expect_length(result, 1)

  dl <- result[[1]]
  expect_type(dl$curve_fn, "closure")
  expect_type(dl$b, "double")
  expect_type(dl$c, "double")
  expect_type(dl$d, "double")
  expect_type(dl$e, "double")
  expect_equal(dl$n_draws, 50L)
  expect_equal(length(dl$b), 50L)
})


test_that("hlpr_extract_draws returns named list for multiple models", {
  m1 <- make_mock_mrmfit("gompertz")
  m2 <- make_mock_mrmfit("weibull")
  mrms <- list(search = m1, display = m2)

  result <- hlpr_extract_draws(mrms)

  expect_length(result, 2)
  expect_equal(names(result), c("search", "display"))
})


test_that("unscaling is correct for standard form (min_max)", {
  m <- make_mock_mrmfit("gompertz")
  sv <- m$scale_values  # x_min=0, x_max=1e6, y_min=0, y_max=1000

  # Get raw scaled draws
  raw <- as_draws_df.mock_brmsfit(m)
  result <- hlpr_extract_draws(m)[[1]]

  x_range <- sv$x_max - sv$x_min  # 1e6

  # b: b_raw / x_range
  expect_equal(result$b, raw$b_b_Intercept / x_range, tolerance = 1e-10)
  # e: e_raw * x_range + x_min - x_offset
  expect_equal(result$e, raw$b_e_Intercept * x_range + sv$x_min, tolerance = 1e-10)
  # c: c_raw * y_range + y_min
  expect_equal(result$c, raw$b_c_Intercept * (sv$y_max - sv$y_min) + sv$y_min, tolerance = 1e-10)
  # d: d_raw * y_range + y_min
  expect_equal(result$d, raw$b_d_Intercept * (sv$y_max - sv$y_min) + sv$y_min, tolerance = 1e-10)
})


test_that("unscaling is correct for log form", {
  m <- make_mock_mrmfit("weibull")
  sv <- m$scale_values
  x_offset <- if (!is.null(sv$x_offset)) sv$x_offset else 0

  raw <- as_draws_df.mock_brmsfit(m)
  result <- hlpr_extract_draws(m)[[1]]

  # b: unchanged for log forms
  expect_equal(result$b, raw$b_b_Intercept, tolerance = 1e-10)
  # e: e_raw * x_max - x_offset
  expect_equal(result$e, raw$b_e_Intercept * sv$x_max - x_offset, tolerance = 1e-10)
  # c, d: same y-unscaling as standard forms
  expect_equal(result$c, raw$b_c_Intercept * (sv$y_max - sv$y_min) + sv$y_min, tolerance = 1e-10)
  expect_equal(result$d, raw$b_d_Intercept * (sv$y_max - sv$y_min) + sv$y_min, tolerance = 1e-10)
})


test_that("curve_fn is callable and returns numeric", {
  m <- make_mock_mrmfit("gompertz")
  result <- hlpr_extract_draws(m)[[1]]

  y <- result$curve_fn(
    500000,
    b = result$b[1],
    c = result$c[1],
    d = result$d[1],
    e = result$e[1]
  )

  expect_type(y, "double")
  expect_length(y, 1)
  expect_false(is.na(y))
})
