test_that("substitutes single variable in formula", {
  f      <- y ~ x + 1
  result <- hlpr_replace_variables_in_formula(f, old_vars = "x", new_vars = "spend")
  expect_true(grepl("spend", deparse(result)))
  expect_false(grepl("\\bx\\b", deparse(result)))
})

test_that("substitutes response variable", {
  f      <- y ~ x + 1
  result <- hlpr_replace_variables_in_formula(f, old_vars = "y", new_vars = "opps")
  expect_true(grepl("opps", deparse(result)))
})

test_that("substitutes both x and y simultaneously", {
  f      <- y ~ c + (d - c) / (1 + exp(b * (x - e)))
  result <- hlpr_replace_variables_in_formula(
    f, old_vars = c("x", "y"), new_vars = c("spend", "kpi")
  )
  formula_str <- deparse(result)
  expect_true(grepl("spend", formula_str))
  expect_true(grepl("kpi",   formula_str))
  expect_false(grepl("\\bx\\b", formula_str))
  expect_false(grepl("\\by\\b", formula_str))
})

test_that("does not replace partial variable name matches (word boundary)", {
  f      <- y ~ exp_val + x
  result <- hlpr_replace_variables_in_formula(f, old_vars = "x", new_vars = "spend")
  # "exp_val" should NOT become "espendhd_val"
  expect_true(grepl("exp_val", deparse(result)))
})

test_that("errors when old_vars and new_vars have different lengths", {
  f <- y ~ x + 1
  expect_error(
    hlpr_replace_variables_in_formula(f, old_vars = c("x", "y"), new_vars = "spend"),
    "same"
  )
})

test_that("returns a formula object", {
  f      <- y ~ x + 1
  result <- hlpr_replace_variables_in_formula(f, old_vars = "x", new_vars = "spend")
  expect_s3_class(result, "formula")
})
