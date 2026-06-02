fixed_params <- list(
  center = list(b = -5.0, c = 0.0, d = 1000.0, e = 500000.0),
  lower  = list(b = -6.0, c = -10.0, d = 950.0, e = 450000.0),
  upper  = list(b = -4.0, c = 10.0, d = 1050.0, e = 550000.0)
)

test_that("mrm_params_summary errors on non-brmsfit input", {
  expect_error(mrm_params_summary(list()), "fit_response")
})

test_that("mrm_params_summary returns a tibble with 4 rows", {
  mock <- make_mock_mrmfit("gompertz")
  local_mocked_bindings(
    mrm_params = function(...) fixed_params,
    .package = "mrmopt"
  )
  result <- mrm_params_summary(mock)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4)
})

test_that("mrm_params_summary has required columns", {
  mock <- make_mock_mrmfit("gompertz")
  local_mocked_bindings(
    mrm_params = function(...) fixed_params,
    .package = "mrmopt"
  )
  result   <- mrm_params_summary(mock)
  expected <- c("param", "name", "description", "center", "lower", "upper")
  expect_true(all(expected %in% names(result)))
})

test_that("param column is c('b','c','d','e') in order", {
  mock <- make_mock_mrmfit("gompertz")
  local_mocked_bindings(
    mrm_params = function(...) fixed_params,
    .package = "mrmopt"
  )
  result <- mrm_params_summary(mock)
  expect_equal(result$param, c("b", "c", "d", "e"))
})

test_that("center, lower, upper are numeric columns", {
  mock <- make_mock_mrmfit("gompertz")
  local_mocked_bindings(
    mrm_params = function(...) fixed_params,
    .package = "mrmopt"
  )
  result <- mrm_params_summary(mock)
  expect_type(result$center, "double")
  expect_type(result$lower,  "double")
  expect_type(result$upper,  "double")
})
