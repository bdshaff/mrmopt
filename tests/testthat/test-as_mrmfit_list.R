test_that("as_mrmfit_list errors on non-mrmfit_hier input", {
  expect_error(as_mrmfit_list(list(group = "g")), "fit_response_hier")
})

test_that("as_mrmfit_list errors on an unknown level", {
  fake <- structure(list(group = c("subtype", "station")), class = "mrmfit_hier")
  expect_error(as_mrmfit_list(fake, level = "nope"), "must be one of")
})

test_that("hlpr_params short-circuits on a precomputed unit view", {
  pr <- list(
    center = list(b = -1, c = 0, d = 100, e = 5),
    lower  = list(b = -2, c = 0, d = 80,  e = 3),
    upper  = list(b = -0.5, c = 0, d = 120, e = 7)
  )
  obj <- structure(list(params_hier_unit = pr, rc_type = "gompertz"),
                   class = c("mrmfit_hier_unit", "mrmfit"))
  expect_identical(hlpr_params(obj), pr)
  # mrm_response_function consumes it without a brms object (warns: unit view)
  f <- suppressWarnings(mrm_response_function(obj, location = "center"))
  expect_true(is.function(f))
  expect_true(is.finite(f(5)))
})

# Count only the "unit view" advisory warnings.
count_view_warnings <- function(expr) {
  n <- 0L
  withCallingHandlers(
    expr,
    warning = function(c) {
      if (grepl("designed for a single", conditionMessage(c))) {
        n <<- n + 1L
        invokeRestart("muffleWarning")
      }
    }
  )
  n
}

# Minimal fake unit view (no MCMC) for the defensive-behavior guards.
make_fake_unit <- function() {
  rdf <- data.frame(spend = 1:10, center = (1:10) * 10)
  structure(
    list(
      rc_type = "gompertz", unit_id = "u1", level = "station",
      spend_col = "spend", kpi_col = "conv",
      scale_values = list(x_min = 0, x_max = 100, x_offset = 0,
                          y_min = 0, y_max = 1000),
      response_df = rdf,
      params_hier_unit = list(
        center = list(b = -1, c = 0, d = 100, e = 5),
        lower  = list(b = -2, c = 0, d = 80,  e = 3),
        upper  = list(b = -0.5, c = 0, d = 120, e = 7)
      )
    ),
    class = c("mrmfit_hier_unit", "mrmfit")
  )
}

test_that("mrm_infer serves the cached response_df for a unit view", {
  u <- make_fake_unit()
  expect_identical(suppressWarnings(mrm_infer(u)), u$response_df)
})

test_that("unit-view functions emit one advisory warning per call", {
  u <- make_fake_unit()
  expect_equal(count_view_warnings(mrm_params(u)), 1L)
  expect_equal(count_view_warnings(mrm_response_function(u)), 1L)
  expect_equal(count_view_warnings(mrm_infer(u)), 1L)
  expect_warning(mrm_params(u), "designed for a single")
})

test_that("the depth guard suppresses warnings during intended internal use", {
  u   <- make_fake_unit()
  old <- options(mrmopt.unit_view_depth = 1L)
  on.exit(options(old), add = TRUE)
  expect_equal(count_view_warnings(mrm_params(u)), 0L)
})

test_that("mrm_infer errors on a custom grid for a unit view", {
  u <- make_fake_unit()
  expect_error(mrm_infer(u, length.out = 500), "per-unit view")
  expect_error(mrm_infer(u, xrange = c(1, 5)), "per-unit view")
})

test_that("diagnostics error clearly on a unit view", {
  u <- make_fake_unit()
  expect_error(mrm_plot_diagnostics(u), "diagnostics are not available")
  expect_error(mrm_plot(u, type = "diagnostics"), "diagnostics are not available")
})

test_that("print.mrmfit_hier_unit is informative", {
  expect_output(print(make_fake_unit()), "Hierarchical unit view")
  expect_output(print(make_fake_unit()), "u1")
})

test_that("as_draws_df.mrmfit_hier_unit returns the stored draws", {
  ud <- data.frame(
    b_b_Intercept = rnorm(10), b_c_Intercept = rnorm(10),
    b_d_Intercept = rnorm(10), b_e_Intercept = rnorm(10)
  )
  class(ud) <- c("draws_df", "draws", "tbl_df", "tbl", "data.frame")
  obj <- structure(list(.unit_draws = ud), class = c("mrmfit_hier_unit", "mrmfit"))
  got <- posterior::as_draws_df(obj)
  expect_identical(got, ud)
})
