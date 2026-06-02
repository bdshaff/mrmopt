test_that("mrm_prior() returns correct class with defaults", {
  p <- mrm_prior()
  expect_s3_class(p, "mrm_prior")
  expect_equal(p$midpoint_range, c(0.1, 0.9))
  expect_equal(p$ceiling_max, 5)
  expect_equal(p$floor_min, 0)
})

test_that("mrm_prior() accepts valid custom values", {
  p <- mrm_prior(midpoint_range = c(0.2, 0.7), ceiling_max = 3, floor_min = 10)
  expect_equal(p$midpoint_range, c(0.2, 0.7))
  expect_equal(p$ceiling_max, 3)
  expect_equal(p$floor_min, 10)
})

test_that("mrm_prior() rejects invalid midpoint_range", {
  expect_error(mrm_prior(midpoint_range = c(0.5)), "two-element")
  expect_error(mrm_prior(midpoint_range = c(-0.1, 0.5)), "between 0 and 1")
  expect_error(mrm_prior(midpoint_range = c(0.1, 1.5)), "between 0 and 1")
  expect_error(mrm_prior(midpoint_range = c(0.8, 0.2)), "less than")
  expect_error(mrm_prior(midpoint_range = "abc"), "two-element")
})

test_that("mrm_prior() rejects invalid ceiling_max", {
  expect_error(mrm_prior(ceiling_max = 0.5), ">= 1")
  expect_error(mrm_prior(ceiling_max = c(1, 2)), "single numeric")
  expect_error(mrm_prior(ceiling_max = "high"), "single numeric")
})

test_that("mrm_prior() rejects invalid floor_min", {
  expect_error(mrm_prior(floor_min = c(0, 1)), "single numeric")
  expect_error(mrm_prior(floor_min = "zero"), "single numeric")
})

test_that("print.mrm_prior() runs without error", {
  p <- mrm_prior()
  expect_output(print(p), "mrm_prior specification")
})
