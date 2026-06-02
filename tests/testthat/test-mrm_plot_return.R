test_that("mrm_plot_return errors on non-brmsfit input", {
  expect_error(mrm_plot_return(list()), "fit_response")
})

test_that("mrm_plot_return returns a ggplot object", {
  mock <- make_mock_mrmfit("gompertz")
  p    <- mrm_plot_return(mock, markup = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("location = 'lower' does not error", {
  mock <- make_mock_mrmfit("gompertz")
  expect_no_error(mrm_plot_return(mock, location = "lower", markup = FALSE))
})

test_that("location = 'upper' does not error", {
  mock <- make_mock_mrmfit("gompertz")
  expect_no_error(mrm_plot_return(mock, location = "upper", markup = FALSE))
})

test_that("location = 'center' does not error", {
  mock <- make_mock_mrmfit("gompertz")
  expect_no_error(mrm_plot_return(mock, location = "center", markup = FALSE))
})

test_that("x_var = 'units' errors when model has no units", {
  mock <- make_mock_mrmfit("gompertz")
  expect_error(mrm_plot_return(mock, x_var = "units"), "Units not available")
})

test_that("x_var = 'units' works when model has units", {
  mock <- make_mock_mrmfit("gompertz", with_units = TRUE)
  p    <- mrm_plot_return(mock, markup = FALSE, x_var = "units")
  expect_s3_class(p, "ggplot")
})
