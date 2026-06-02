valid_params <- list(b = -2, c = 0, d = 1, e = 0.5)
valid_x      <- seq(0.01, 2, length.out = 20)

# -------------------------------------------------------------------------
# Input validation
# -------------------------------------------------------------------------

test_that("response() errors when x is not numeric", {
  expect_error(response("a", valid_params, "gompertz"), "numeric")
})

test_that("response() errors when params is missing a required element", {
  expect_error(response(valid_x, list(b = -2, c = 0, d = 1), "gompertz"), "params must be")
  expect_error(response(valid_x, list(b = -2, c = 0, e = 1), "gompertz"), "params must be")
})

test_that("response() errors when params contains non-numeric elements", {
  bad <- valid_params
  bad$b <- "steep"
  expect_error(response(valid_x, bad, "gompertz"), "numeric")
})

test_that("response() errors when a param element has length > 1", {
  bad <- valid_params
  bad$b <- c(-1, -2)
  expect_error(response(valid_x, bad, "gompertz"), "length 1")
})

# -------------------------------------------------------------------------
# Output properties
# -------------------------------------------------------------------------

test_that("response() returns numeric vector of correct length", {
  y <- response(valid_x, valid_params, "gompertz")
  expect_type(y, "double")
  expect_length(y, length(valid_x))
})

test_that("response() output matches direct rm_* call for all types", {
  types <- c("logistic", "gompertz", "reflected_gompertz",
             "log_logistic", "weibull", "reflected_weibull")
  x_in  <- seq(0.1, 2, length.out = 20)
  for (t in types) {
    fn  <- rm_dispatch(t)
    y1  <- response(x_in, valid_params, t)
    y2  <- fn(x_in, b = valid_params$b, c = valid_params$c,
              d = valid_params$d, e = valid_params$e)
    expect_equal(y1, y2, tolerance = 1e-10, info = t)
  }
})
