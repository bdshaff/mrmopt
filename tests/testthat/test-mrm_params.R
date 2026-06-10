fixed_params <- list(
  center = list(b = -5.0, c = 0.0, d = 1000.0, e = 500000.0),
  lower  = list(b = -6.0, c = -10.0, d = 950.0, e = 450000.0),
  upper  = list(b = -4.0, c = 10.0, d = 1050.0, e = 550000.0)
)

test_that("mrm_params errors on non-mrmfit input", {
  expect_error(mrm_params(list()),         "fit_response")
  expect_error(mrm_params("not_a_model"),  "fit_response")
})

test_that("mrm_params returns a tibble with 4 rows", {
  mock <- make_mock_mrmfit("gompertz")
  local_mocked_bindings(
    hlpr_params = function(...) fixed_params,
    .package = "mrmopt"
  )
  result <- mrm_params(mock)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4)
})

test_that("mrm_params has required columns", {
  mock <- make_mock_mrmfit("gompertz")
  local_mocked_bindings(
    hlpr_params = function(...) fixed_params,
    .package = "mrmopt"
  )
  result <- mrm_params(mock)
  expect_true(all(c("param", "name", "description", "center", "lower", "upper") %in% names(result)))
})

test_that("mrm_params param column is c('b','c','d','e') in order", {
  mock <- make_mock_mrmfit("gompertz")
  local_mocked_bindings(
    hlpr_params = function(...) fixed_params,
    .package = "mrmopt"
  )
  expect_equal(mrm_params(mock)$param, c("b", "c", "d", "e"))
})

test_that("mrm_params center, lower, upper are numeric", {
  mock <- make_mock_mrmfit("gompertz")
  local_mocked_bindings(
    hlpr_params = function(...) fixed_params,
    .package = "mrmopt"
  )
  result <- mrm_params(mock)
  expect_type(result$center, "double")
  expect_type(result$lower,  "double")
  expect_type(result$upper,  "double")
})
