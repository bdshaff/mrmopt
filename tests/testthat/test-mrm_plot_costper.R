test_that("mrm_plot_costper errors on non-brmsfit input", {
  expect_error(mrm_plot_costper(list()), "fit_response")
})

test_that("mrm_plot_costper returns a ggplot object", {
  mock <- make_mock_mrmfit("gompertz")
  p    <- mrm_plot_costper(mock, markup = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("markup = FALSE does not error", {
  mock <- make_mock_mrmfit("gompertz")
  expect_no_error(mrm_plot_costper(mock, markup = FALSE))
})

test_that("x_var = 'units' errors when model has no units", {
  mock <- make_mock_mrmfit("gompertz")
  expect_error(mrm_plot_costper(mock, x_var = "units"), "Units not available")
})

test_that("x_var = 'units' works when model has units", {
  mock <- make_mock_mrmfit("gompertz", with_units = TRUE)
  p    <- mrm_plot_costper(mock, markup = FALSE, x_var = "units")
  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$x, "Units")
})

test_that("y axis label is 'Cost per KPI'", {
  mock <- make_mock_mrmfit("gompertz")
  p    <- mrm_plot_costper(mock, markup = FALSE)
  expect_equal(p$labels$y, "Cost per KPI")
})
