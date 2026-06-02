# Tests for all six rm_* response model functions
# Each function shares the same signature: rm_*(x, b, c, d, e)

# -------------------------------------------------------------------------
# Shared test helpers
# -------------------------------------------------------------------------

valid_x  <- seq(0.01, 2, length.out = 50)
std_args <- list(b = -2, c = 0, d = 1, e = 1)

# Standard saturation params (curve rises then plateaus)
gompertz_args  <- list(b = -2, c = 0, d = 1, e = 0.5)
logistic_args  <- list(b = -5, c = 0, d = 1, e = 1)
# Reflected: curve rises from c to d with increasing x
reflected_args <- list(b = -2, c = 0, d = 1, e = 1)
# Log forms require strictly positive x
log_x <- seq(0.01, 10, length.out = 50)
log_args <- list(b = -2, c = 0, d = 1, e = 1)


# -------------------------------------------------------------------------
# Input validation — applies to all six functions
# -------------------------------------------------------------------------

all_fns <- list(
  rm_Gompertz    = rm_Gompertz,
  rm_GompertzRef = rm_GompertzRef,
  rm_Logistic    = rm_Logistic,
  rm_LogLogistic = rm_LogLogistic,
  rm_Weibull     = rm_Weibull,
  rm_WeibullRef  = rm_WeibullRef
)

for (fn_name in names(all_fns)) {
  fn <- all_fns[[fn_name]]
  x_in <- if (fn_name %in% c("rm_LogLogistic", "rm_Weibull", "rm_WeibullRef")) log_x else valid_x

  test_that(paste(fn_name, "errors on non-numeric x"), {
    expect_error(fn("a", -2, 0, 1, 1), "numeric")
  })

  test_that(paste(fn_name, "errors when b is not length-1 numeric"), {
    expect_error(fn(x_in, c(-1, -2), 0, 1, 1), "b must be")
    expect_error(fn(x_in, "fast",    0, 1, 1), "b must be")
  })

  test_that(paste(fn_name, "errors when c is not length-1 numeric"), {
    expect_error(fn(x_in, -2, c(0, 0), 1, 1), "c must be")
    expect_error(fn(x_in, -2, "low",   1, 1), "c must be")
  })

  test_that(paste(fn_name, "errors when d is not length-1 numeric"), {
    expect_error(fn(x_in, -2, 0, c(1, 2), 1), "d must be")
    expect_error(fn(x_in, -2, 0, "high",  1), "d must be")
  })

  test_that(paste(fn_name, "errors when e is not length-1 numeric"), {
    expect_error(fn(x_in, -2, 0, 1, c(1, 2)), "e must be")
    expect_error(fn(x_in, -2, 0, 1, "mid"),   "e must be")
  })

  test_that(paste(fn_name, "errors when d <= c"), {
    expect_error(fn(x_in, -2, 1, 1, 1), "'d' must be greater")
    expect_error(fn(x_in, -2, 2, 1, 1), "'d' must be greater")
  })

  test_that(paste(fn_name, "returns numeric vector of same length as x"), {
    res <- fn(x_in, -2, 0, 1, 1)
    expect_type(res, "double")
    expect_length(res, length(x_in))
  })

  test_that(paste(fn_name, "works with a single-element x"), {
    x1 <- if (fn_name %in% c("rm_LogLogistic", "rm_Weibull", "rm_WeibullRef")) 1 else 0.5
    res <- fn(x1, -2, 0, 1, 1)
    expect_length(res, 1)
    expect_type(res, "double")
  })
}


# -------------------------------------------------------------------------
# Mathematical correctness — standard curves (non-log x)
# -------------------------------------------------------------------------

test_that("rm_Gompertz: output bounded between c and d", {
  y <- rm_Gompertz(valid_x, b = -2, c = 0, d = 1, e = 0.5)
  expect_true(all(y >= 0 - 1e-10 & y <= 1 + 1e-10))
})

test_that("rm_Gompertz: approaches c at x = -Inf (large negative x)", {
  # Gompertz: y = c + (d-c)*exp(-exp(b*(x-e))); as x -> -inf, exp(b*(x-e)) -> +inf, y -> c
  y_low <- rm_Gompertz(-1e6, b = -2, c = 0, d = 1, e = 0)
  expect_equal(y_low, 0, tolerance = 1e-4)
})

test_that("rm_Gompertz: approaches d at large positive x", {
  y_high <- rm_Gompertz(1e6, b = -2, c = 0, d = 1, e = 0)
  expect_equal(y_high, 1, tolerance = 1e-4)
})

test_that("rm_GompertzRef: output bounded between c and d", {
  y <- rm_GompertzRef(valid_x, b = -2, c = 0, d = 1, e = 1)
  expect_true(all(y >= 0 - 1e-10 & y <= 1 + 1e-10))
})

test_that("rm_GompertzRef: approaches c at large negative x (b < 0)", {
  # With b < 0: as x -> -Inf, b*(-x+e) -> -Inf, exp -> 0, exp(-0) = 1, y -> c
  y_low <- rm_GompertzRef(-1e6, b = -2, c = 0, d = 1, e = 1)
  expect_equal(y_low, 0, tolerance = 1e-4)
})

test_that("rm_GompertzRef: approaches d at large x", {
  y_high <- rm_GompertzRef(1e6, b = -2, c = 0, d = 1, e = 1)
  expect_equal(y_high, 1, tolerance = 1e-4)
})

test_that("rm_Logistic: output bounded between c and d", {
  y <- rm_Logistic(valid_x, b = -5, c = 0, d = 1, e = 1)
  expect_true(all(y >= 0 - 1e-10 & y <= 1 + 1e-10))
})

test_that("rm_Logistic: symmetric around midpoint e", {
  e_val <- 1
  y_lo  <- rm_Logistic(e_val - 0.5, b = -5, c = 0, d = 1, e = e_val)
  y_hi  <- rm_Logistic(e_val + 0.5, b = -5, c = 0, d = 1, e = e_val)
  expect_equal(y_lo + y_hi, 1, tolerance = 1e-6)
})

test_that("rm_Logistic: value at midpoint e is (c+d)/2", {
  y_mid <- rm_Logistic(1, b = -5, c = 0, d = 1, e = 1)
  expect_equal(y_mid, 0.5, tolerance = 1e-6)
})


# -------------------------------------------------------------------------
# Mathematical correctness — log-based curves
# -------------------------------------------------------------------------

test_that("rm_LogLogistic: output bounded between c and d for positive x", {
  y <- rm_LogLogistic(log_x, b = -2, c = 0, d = 1, e = 1)
  expect_true(all(y >= 0 - 1e-10 & y <= 1 + 1e-10))
})

test_that("rm_LogLogistic: value at x = e is (c+d)/2", {
  y_mid <- rm_LogLogistic(2, b = -5, c = 0, d = 1, e = 2)
  expect_equal(y_mid, 0.5, tolerance = 1e-6)
})

test_that("rm_Weibull: output bounded between c and d for positive x", {
  y <- rm_Weibull(log_x, b = -2, c = 0, d = 1, e = 1)
  expect_true(all(y >= 0 - 1e-10 & y <= 1 + 1e-10))
})

test_that("rm_WeibullRef: output bounded between c and d for positive x", {
  y <- rm_WeibullRef(log_x, b = -2, c = 0, d = 1, e = 1)
  expect_true(all(y >= 0 - 1e-10 & y <= 1 + 1e-10))
})

test_that("rm_WeibullRef: approaches c at very small positive x (b < 0)", {
  y_low <- rm_WeibullRef(1e-10, b = -2, c = 0, d = 1, e = 1)
  expect_equal(y_low, 0, tolerance = 1e-4)
})

test_that("rm_WeibullRef: approaches d at large x (b < 0)", {
  y_high <- rm_WeibullRef(1e10, b = -2, c = 0, d = 1, e = 1)
  expect_equal(y_high, 1, tolerance = 1e-4)
})

test_that("rm_LogLogistic at x = 0 returns c (log(-Inf) chain evaluates to floor)", {
  # log(0) = -Inf -> exp(+Inf) -> (d-c)/Inf = 0 -> y = c in R's arithmetic
  y <- rm_LogLogistic(0, b = -2, c = 0, d = 1, e = 1)
  expect_equal(y, 0, tolerance = 1e-10)
})
