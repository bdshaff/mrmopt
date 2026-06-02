test_that("min_max scaling works normally for non-log forms", {
  df <- data.frame(x = c(0, 50, 100), y = c(0, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "min_max", type = "gompertz")

  expect_equal(range(res$scaled_data$x), c(0, 1))
  expect_equal(range(res$scaled_data$y), c(0, 1))
  expect_equal(res$scale_values$x_min, 0)
  expect_equal(res$scale_values$x_max, 100)
})

test_that("min_max + log form uses ratio scaling for x", {
  df <- data.frame(x = c(10, 50, 100), y = c(0, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "min_max", type = "log_logistic")

  expect_equal(res$scaled_data$x, c(0.1, 0.5, 1.0))
  expect_true(all(res$scaled_data$x > 0))
  expect_equal(res$scale_values$x_min, 0)
  expect_equal(res$scale_values$x_max, 100)
  expect_equal(res$scale_values$x_offset, 0)
  expect_equal(range(res$scaled_data$y), c(0, 1))
})

test_that("ratio scaling works for weibull and reflected_weibull", {
  df <- data.frame(x = c(10, 50, 100), y = c(0, 250, 500))

  for (form in c("weibull", "reflected_weibull")) {
    res <- hlpr_scale_data(df, "x", "y", "min_max", type = form)
    expect_true(all(res$scaled_data$x > 0), info = form)
    expect_equal(res$scale_values$x_min, 0, info = form)
  }
})

test_that("x_offset is applied when x contains zeros for log forms", {
  df <- data.frame(x = c(0, 50, 100), y = c(10, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "min_max", type = "log_logistic")

  # Offset should be half the smallest positive value
  expect_equal(res$scale_values$x_offset, 25)
  # All scaled x values should be > 0
  expect_true(all(res$scaled_data$x > 0))
  # x_min stored as 0 for unscaling
  expect_equal(res$scale_values$x_min, 0)
})

test_that("x_offset is 0 when no zeros in x for log forms", {
  df <- data.frame(x = c(10, 50, 100), y = c(0, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "min_max", type = "log_logistic")

  expect_equal(res$scale_values$x_offset, 0)
})

test_that("x_offset is 0 for non-log forms even with x zeros", {
  df <- data.frame(x = c(0, 50, 100), y = c(0, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "min_max", type = "gompertz")

  expect_equal(res$scale_values$x_offset, 0)
})

test_that("log forms error when all x values are zero", {
  df <- data.frame(x = c(0, 0, 0), y = c(0, 250, 500))

  expect_error(
    hlpr_scale_data(df, "x", "y", "min_max", type = "log_logistic"),
    "All x values are zero"
  )
})

test_that("log forms error when x contains negative values", {
  df <- data.frame(x = c(-10, 50, 100), y = c(0, 250, 500))

  expect_error(
    hlpr_scale_data(df, "x", "y", "min_max", type = "weibull"),
    "non-negative"
  )
})

test_that("std + log form works: ratio-scales x, std-scales y", {
  df <- data.frame(x = c(10, 50, 100), y = c(0, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "std", type = "log_logistic")

  # x should be ratio-scaled (positive)
  expect_true(all(res$scaled_data$x > 0))
  expect_equal(res$scale_values$x_min, 0)
  expect_equal(res$scale_values$x_max, 100)
  # y should be std-scaled
  expect_true(!is.null(res$scale_values$y_mean))
  expect_true(!is.null(res$scale_values$y_sd))
  expect_true(is.null(res$scale_values$y_min))
})

test_that("std + log form with x zeros applies offset", {
  df <- data.frame(x = c(0, 50, 100), y = c(10, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "std", type = "log_logistic")

  expect_true(res$scale_values$x_offset > 0)
  expect_true(all(res$scaled_data$x > 0))
})

test_that("std scaling still works for non-log forms", {
  df <- data.frame(x = c(0, 50, 100), y = c(0, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "std", type = "gompertz")

  expect_true(!is.null(res$scale_values$x_mean))
  expect_true(!is.null(res$scale_values$x_sd))
})

test_that("ratio scaling infer_xrange starts above 0 for log forms", {
  df <- data.frame(x = c(10, 50, 100), y = c(0, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "min_max", type = "log_logistic")

  expect_true(res$scaled_xrange[1] > 0)
})

test_that("log form infer_xrange upper bound is 2", {
  df  <- data.frame(x = c(10, 50, 100), y = c(0, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "min_max", type = "reflected_weibull")
  expect_equal(res$scaled_xrange[2], 2)
})

test_that("non-log min_max: infer_xrange lower bound corresponds to x = 0 in scaled space", {
  df  <- data.frame(x = c(20, 50, 100), y = c(0, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "min_max", type = "gompertz")
  # lower bound should be the scaled value of 0: (0 - x_min)/(x_max - x_min)
  expected <- (0 - 20) / (100 - 20)
  expect_equal(res$scaled_xrange[1], expected, tolerance = 1e-9)
})

test_that("round-trip: unscaling x returns original values (min_max)", {
  df  <- data.frame(x = c(100, 500, 1000), y = c(0, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "min_max", type = "gompertz")
  sv  <- res$scale_values
  x_back <- res$scaled_data$x * (sv$x_max - sv$x_min) + sv$x_min
  expect_equal(x_back, df$x, tolerance = 1e-9)
})

test_that("round-trip: unscaling y returns original values (min_max)", {
  df  <- data.frame(x = c(100, 500, 1000), y = c(0, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "min_max", type = "gompertz")
  sv  <- res$scale_values
  y_back <- res$scaled_data$y * (sv$y_max - sv$y_min) + sv$y_min
  expect_equal(y_back, df$y, tolerance = 1e-9)
})

test_that("round-trip: unscaling x returns original values (std)", {
  df  <- data.frame(x = c(100, 500, 1000), y = c(0, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "std", type = "gompertz")
  sv  <- res$scale_values
  x_back <- res$scaled_data$x * sv$x_sd + sv$x_mean
  expect_equal(x_back, df$x, tolerance = 1e-9)
})

test_that("round-trip: log form unscaling x returns original values", {
  df  <- data.frame(x = c(10, 50, 100), y = c(0, 250, 500))
  res <- hlpr_scale_data(df, "x", "y", "min_max", type = "log_logistic")
  sv  <- res$scale_values
  x_back <- res$scaled_data$x * sv$x_max + sv$x_min - sv$x_offset
  expect_equal(x_back, df$x, tolerance = 1e-9)
})
