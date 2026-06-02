test_that("hlpr_resolve_prior returns brmsprior for min_max + gompertz", {
  scaled_data <- data.frame(x = seq(0, 1, length.out = 50),
                            y = seq(0, 1, length.out = 50))
  scale_values <- list(x_min = 0, x_max = 100, y_min = 0, y_max = 500)

  result <- hlpr_resolve_prior(
    mrm_prior = mrm_prior(),
    scaled_data = scaled_data,
    x = "x", y = "y",
    scale_method = "min_max",
    scale_values = scale_values,
    type = "gompertz"
  )

  expect_s3_class(result, "brmsprior")
  expect_true(all(c("b", "c", "d", "e") %in% result$nlpar))
})

test_that("hlpr_resolve_prior returns brmsprior for std + gompertz", {
  scaled_data <- data.frame(x = rnorm(50), y = rnorm(50))
  scale_values <- list(x_mean = 50, x_sd = 20, y_mean = 250, y_sd = 100)

  result <- hlpr_resolve_prior(
    mrm_prior = mrm_prior(),
    scaled_data = scaled_data,
    x = "x", y = "y",
    scale_method = "std",
    scale_values = scale_values,
    type = "gompertz"
  )

  expect_s3_class(result, "brmsprior")
  expect_true(all(c("b", "c", "d", "e") %in% result$nlpar))
})

test_that("hlpr_resolve_prior uses negative b for reflected forms", {
  scaled_data <- data.frame(x = seq(0, 1, length.out = 50),
                            y = seq(0, 1, length.out = 50))
  scale_values <- list(x_min = 0, x_max = 100, y_min = 0, y_max = 500)

  result <- hlpr_resolve_prior(
    mrm_prior = mrm_prior(),
    scaled_data = scaled_data,
    x = "x", y = "y",
    scale_method = "min_max",
    scale_values = scale_values,
    type = "reflected_gompertz"
  )

  b_row <- result[result$nlpar == "b", ]
  expect_true(as.numeric(b_row$ub) <= 0)
  expect_true(as.numeric(b_row$lb) < 0)
})

test_that("hlpr_resolve_prior enforces e > 0 for log forms", {
  scaled_data <- data.frame(x = seq(0, 1, length.out = 50),
                            y = seq(0, 1, length.out = 50))
  scale_values <- list(x_min = 0, x_max = 100, y_min = 0, y_max = 500)

  result <- hlpr_resolve_prior(
    mrm_prior = mrm_prior(),
    scaled_data = scaled_data,
    x = "x", y = "y",
    scale_method = "min_max",
    scale_values = scale_values,
    type = "log_logistic"
  )

  e_row <- result[result$nlpar == "e", ]
  expect_true(as.numeric(e_row$lb) > 0)
})

test_that("hlpr_resolve_prior warns when midpoint starts at 0 for log forms", {
  scaled_data <- data.frame(x = seq(0, 1, length.out = 50),
                            y = seq(0, 1, length.out = 50))
  scale_values <- list(x_min = 0, x_max = 100, y_min = 0, y_max = 500)

  expect_warning(
    hlpr_resolve_prior(
      mrm_prior = mrm_prior(midpoint_range = c(0, 0.9)),
      scaled_data = scaled_data,
      x = "x", y = "y",
      scale_method = "min_max",
      scale_values = scale_values,
      type = "log_logistic"
    ),
    "log"
  )
})

test_that("hlpr_resolve_prior rejects unknown type", {
  scaled_data <- data.frame(x = seq(0, 1, length.out = 50),
                            y = seq(0, 1, length.out = 50))
  scale_values <- list(x_min = 0, x_max = 100, y_min = 0, y_max = 500)

  expect_error(
    hlpr_resolve_prior(
      mrm_prior = mrm_prior(),
      scaled_data = scaled_data,
      x = "x", y = "y",
      scale_method = "min_max",
      scale_values = scale_values,
      type = "banana"
    ),
    "Unknown response form"
  )
})

test_that("hlpr_resolve_prior uses NULL mrm_prior for defaults", {
  scaled_data <- data.frame(x = seq(0, 1, length.out = 50),
                            y = seq(0, 1, length.out = 50))
  scale_values <- list(x_min = 0, x_max = 100, y_min = 0, y_max = 500)

  result <- hlpr_resolve_prior(
    mrm_prior = NULL,
    scaled_data = scaled_data,
    x = "x", y = "y",
    scale_method = "min_max",
    scale_values = scale_values,
    type = "gompertz"
  )

  expect_s3_class(result, "brmsprior")
})

test_that("std scaling: ceiling_max correctly converts to scaled space", {
  # Case where y_mean is large relative to y_sd
  set.seed(7831)
  y_orig <- rnorm(50, mean = 1000, sd = 50)
  x_orig <- runif(50, 0, 100)
  y_mean <- mean(y_orig); y_sd <- sd(y_orig)
  x_mean <- mean(x_orig); x_sd <- sd(x_orig)

  scaled_data <- data.frame(
    x = (x_orig - x_mean) / x_sd,
    y = (y_orig - y_mean) / y_sd
  )
  scale_values <- list(x_mean = x_mean, x_sd = x_sd,
                       y_mean = y_mean, y_sd = y_sd)

  result <- hlpr_resolve_prior(
    mrm_prior = mrm_prior(ceiling_max = 2),
    scaled_data = scaled_data,
    x = "x", y = "y",
    scale_method = "std",
    scale_values = scale_values,
    type = "gompertz"
  )

  # d_ub in scaled space should correspond to 2 * max(y_orig) in original
  d_ub_scaled <- as.numeric(result$ub[result$nlpar == "d"])
  d_ub_original <- d_ub_scaled * y_sd + y_mean
  expect_equal(d_ub_original, 2 * max(y_orig), tolerance = 0.01)
})

test_that("ceiling_max changes d upper bound", {
  scaled_data <- data.frame(x = seq(0, 1, length.out = 50),
                            y = seq(0, 1, length.out = 50))
  scale_values <- list(x_min = 0, x_max = 100, y_min = 0, y_max = 500)

  result_low <- hlpr_resolve_prior(
    mrm_prior = mrm_prior(ceiling_max = 2),
    scaled_data = scaled_data,
    x = "x", y = "y",
    scale_method = "min_max",
    scale_values = scale_values,
    type = "gompertz"
  )
  result_high <- hlpr_resolve_prior(
    mrm_prior = mrm_prior(ceiling_max = 10),
    scaled_data = scaled_data,
    x = "x", y = "y",
    scale_method = "min_max",
    scale_values = scale_values,
    type = "gompertz"
  )

  d_ub_low <- as.numeric(result_low$ub[result_low$nlpar == "d"])
  d_ub_high <- as.numeric(result_high$ub[result_high$nlpar == "d"])
  expect_true(d_ub_high > d_ub_low)
})
