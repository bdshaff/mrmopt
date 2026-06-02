valid_types <- c("logistic", "log_logistic", "gompertz",
                 "reflected_gompertz", "weibull", "reflected_weibull")

test_that("returns a brmsformula for all valid types", {
  for (t in valid_types) {
    result <- hlpr_define_response_form(t, x = "spend", y = "opps")
    expect_s3_class(result, "brmsformula")
  }
})

test_that("nl attribute is TRUE on the returned formula", {
  result <- hlpr_define_response_form("gompertz", x = "spend", y = "opps")
  expect_true(isTRUE(attr(result$formula, "nl")))
})

test_that("response variable in formula matches supplied y", {
  for (t in valid_types) {
    result      <- hlpr_define_response_form(t, x = "myspend", y = "mykpi")
    formula_str <- deparse(result$formula)
    expect_true(grepl("mykpi", formula_str))
  }
})

test_that("predictor variable in formula matches supplied x", {
  result      <- hlpr_define_response_form("gompertz", x = "myspend", y = "mykpi")
  formula_str <- deparse(result$formula)
  expect_true(grepl("myspend", formula_str))
})

test_that("errors when x is NULL", {
  expect_error(hlpr_define_response_form("gompertz", x = NULL, y = "opps"), "NULL")
})

test_that("errors when y is NULL", {
  expect_error(hlpr_define_response_form("gompertz", x = "spend", y = NULL), "NULL")
})

test_that("errors on invalid type", {
  expect_error(hlpr_define_response_form("banana", x = "spend", y = "opps"), "Invalid type")
})
