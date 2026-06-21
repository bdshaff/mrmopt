test_that("returns a brmsformula with nl = TRUE", {
  f <- hlpr_define_response_form_hier("gompertz", x = "spend", y = "conv",
                                      group = "station")
  expect_s3_class(f, "brmsformula")
  expect_true(isTRUE(attr(f$formula, "nl")))
})

test_that("pooled parameters get a random-effect term; others do not", {
  f <- hlpr_define_response_form_hier("gompertz", x = "spend", y = "conv",
                                      group = "station",
                                      pool = c("b", "e", "d"))
  pf <- vapply(f$pforms, function(x) paste(deparse(x), collapse = ""), character(1))
  names(pf) <- vapply(f$pforms, function(x) all.vars(x)[1], character(1))

  expect_true(grepl("station", pf[["b"]]))
  expect_true(grepl("station", pf[["e"]]))
  expect_true(grepl("station", pf[["d"]]))
  # c is not pooled by default -> intercept only
  expect_false(grepl("station", pf[["c"]]))
})

test_that("nested group expands to cumulative interaction terms", {
  f <- hlpr_define_response_form_hier("gompertz", x = "spend", y = "conv",
                                      group = c("subtype", "station"),
                                      pool = "b")
  b_form <- paste(deparse(f$pforms$b), collapse = "")
  expect_true(grepl("\\(1 \\| subtype\\)", b_form))
  expect_true(grepl("subtype:station", b_form))
})

test_that("response and predictor names are preserved", {
  f <- hlpr_define_response_form_hier("gompertz", x = "myspend", y = "mykpi",
                                      group = "g")
  fs <- deparse(f$formula)
  expect_true(grepl("mykpi", fs))
  expect_true(grepl("myspend", fs))
})

test_that("errors when group is missing", {
  expect_error(
    hlpr_define_response_form_hier("gompertz", x = "spend", y = "conv",
                                   group = NULL),
    "group"
  )
})

test_that("log forms reparameterize the midpoint as le", {
  for (t in c("log_logistic", "weibull", "reflected_weibull")) {
    f <- hlpr_define_response_form_hier(t, x = "spend", y = "conv",
                                        group = "g", pool = c("b", "e", "d"))
    nms <- vapply(f$pforms, function(x) all.vars(x)[1], character(1))
    expect_true("le" %in% nms)
    expect_false("e" %in% nms)
    fstr <- paste(deparse(f$formula), collapse = "")
    expect_true(grepl("\\ble\\b", fstr))          # le appears
    expect_true(grepl("log\\(spend\\)", fstr))    # log(x) still present
    # le is pooled because "e" was in pool
    le_form <- f$pforms[[which(nms == "le")]]
    expect_true(grepl("\\(1 \\| g\\)", paste(deparse(le_form), collapse = "")))
  }
})

test_that("errors on invalid type (delegated to base helper)", {
  expect_error(
    hlpr_define_response_form_hier("banana", x = "spend", y = "conv",
                                   group = "g"),
    "Invalid type"
  )
})
