test_that("center metrics (ar, mr, cp_lower) match definitions", {
  df <- data.frame(spend = c(1, 2, 3, 4), center = c(0, 1, 2, 3))
  out <- hlpr_response_metrics(df, "spend")

  expect_equal(out$ar, (df$center - min(df$center)) / df$spend)
  expect_equal(out$mr, c(NA, diff(df$center) / diff(df$spend)))
  expect_true("cp" %in% names(out))
  expect_true("cp_lower" %in% names(out))
})

test_that("lower/upper/mu branches add their columns", {
  df <- data.frame(
    spend    = c(1, 2, 3, 4),
    center   = c(0, 1, 2, 3),
    lower    = c(0, 0.8, 1.6, 2.4),
    upper    = c(0, 1.2, 2.4, 3.6),
    lower_mu = c(0, 0.9, 1.8, 2.7),
    upper_mu = c(0, 1.1, 2.2, 3.3)
  )
  out <- hlpr_response_metrics(df, "spend")

  expect_true(all(c("ar_lower", "mr_lower",
                    "ar_upper", "mr_upper", "cp_upper",
                    "ar_lower_mu", "mr_lower_mu",
                    "ar_upper_mu", "mr_upper_mu", "cp_upper_mu") %in% names(out)))
  expect_equal(out$mr_upper, c(NA, diff(df$upper) / diff(df$spend)))
})

test_that("missing optional columns are skipped without error", {
  df <- data.frame(spend = c(1, 2, 3), center = c(0, 1, 2))
  out <- hlpr_response_metrics(df, "spend")
  expect_false("ar_lower" %in% names(out))   # no 'lower' column supplied
  expect_true("ar" %in% names(out))
})
