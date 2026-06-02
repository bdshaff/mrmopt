test_that("mrm_plot_response errors on non-brmsfit input", {
  expect_error(mrm_plot_response(list()), "fit_response")
})

test_that("mrm_plot_response returns a ggplot object", {
  mock <- make_mock_mrmfit("gompertz")
  p    <- mrm_plot_response(mock, markup = FALSE, points = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("markup = FALSE and points = FALSE do not error", {
  mock <- make_mock_mrmfit("gompertz")
  expect_no_error(mrm_plot_response(mock, markup = FALSE, points = FALSE))
})

test_that("show_mr = TRUE does not error", {
  mock <- make_mock_mrmfit("gompertz")
  expect_no_error(mrm_plot_response(mock, markup = FALSE, points = FALSE, show_mr = TRUE))
})

test_that("x_var = 'spend' produces dollar-formatted x axis label", {
  mock <- make_mock_mrmfit("gompertz")
  p    <- mrm_plot_response(mock, markup = FALSE, points = FALSE, x_var = "spend")
  expect_equal(p$labels$x, "Spend")
})

test_that("x_var = 'units' errors when model has no units", {
  mock <- make_mock_mrmfit("gompertz")   # no units
  expect_error(
    mrm_plot_response(mock, x_var = "units"),
    "Units not available"
  )
})

test_that("x_var = 'units' works when model has units", {
  mock <- make_mock_mrmfit("gompertz", with_units = TRUE)
  p    <- mrm_plot_response(mock, markup = FALSE, points = FALSE, x_var = "units")
  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$x, "Units")
})
