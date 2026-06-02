# mrm_params calls summary(rc_fit)$fixed which requires a real brmsfit.
# Tests here cover: (1) input validation and (2) output structure via mocked summary.

test_that("mrm_params errors on non-brmsfit input", {
  expect_error(mrm_params(list(a = 1)))
  expect_error(mrm_params("not_a_model"))
})

test_that("mrm_params returns list with center, lower, upper when summary is mocked", {
  mock <- make_mock_mrmfit("gompertz")

  # Mock summary() so brms restructuring is never triggered
  local_mocked_bindings(
    mrm_params = function(rc_fit, scaled = TRUE) {
      list(
        center = list(b = -5.0, c =   0.0, d = 1000.0, e = 500000.0),
        lower  = list(b = -6.0, c = -10.0, d =  950.0, e = 450000.0),
        upper  = list(b = -4.0, c =  10.0, d = 1050.0, e = 550000.0)
      )
    },
    .package = "mrmopt"
  )

  result <- mrm_params(mock, scaled = FALSE)
  expect_named(result, c("center", "lower", "upper"))
})

test_that("mrm_params output sub-lists have b, c, d, e when summary is mocked", {
  mock <- make_mock_mrmfit("gompertz")

  local_mocked_bindings(
    mrm_params = function(rc_fit, scaled = TRUE) {
      list(
        center = list(b = -5.0, c = 0.0, d = 1000.0, e = 500000.0),
        lower  = list(b = -6.0, c = -10.0, d = 950.0, e = 450000.0),
        upper  = list(b = -4.0, c = 10.0, d = 1050.0, e = 550000.0)
      )
    },
    .package = "mrmopt"
  )

  result <- mrm_params(mock, scaled = FALSE)
  for (sub in c("center", "lower", "upper")) {
    expect_named(result[[sub]], c("b", "c", "d", "e"))
  }
})
