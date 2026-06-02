test_that("rm_dispatch returns a function for each valid type", {
  valid_types <- c("logistic", "log_logistic", "gompertz",
                   "reflected_gompertz", "weibull", "reflected_weibull")
  for (t in valid_types) {
    fn <- rm_dispatch(t)
    expect_true(is.function(fn), info = t)
  }
})

test_that("rm_dispatch returns the correct function for each type", {
  expect_identical(rm_dispatch("gompertz"),          rm_Gompertz)
  expect_identical(rm_dispatch("reflected_gompertz"), rm_GompertzRef)
  expect_identical(rm_dispatch("logistic"),           rm_Logistic)
  expect_identical(rm_dispatch("log_logistic"),       rm_LogLogistic)
  expect_identical(rm_dispatch("weibull"),            rm_Weibull)
  expect_identical(rm_dispatch("reflected_weibull"),  rm_WeibullRef)
})

test_that("rm_dispatch errors on invalid type with informative message", {
  expect_error(rm_dispatch("banana"),    "Invalid type")
  expect_error(rm_dispatch(""),          "Invalid type")
  expect_error(rm_dispatch("Gompertz"),  "Invalid type")  # case-sensitive
})

test_that("dispatched function produces numeric output", {
  fn <- rm_dispatch("gompertz")
  y  <- fn(seq(0, 2, length.out = 10), b = -2, c = 0, d = 1, e = 1)
  expect_type(y, "double")
  expect_length(y, 10)
})
