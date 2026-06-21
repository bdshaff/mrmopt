make_scaled <- function() {
  list(
    scaled_data  = data.frame(x = seq(0, 1, length.out = 50),
                              y = seq(0, 1, length.out = 50),
                              station = rep(letters[1:5], 10)),
    scale_values = list(x_min = 0, x_max = 100, y_min = 0, y_max = 500)
  )
}

test_that("returns brmsprior with population b/c/d/e plus sd rows", {
  s <- make_scaled()
  result <- hlpr_resolve_prior_hier(
    mrm_prior = mrmopt_prior(),
    scaled_data = s$scaled_data,
    x = "x", y = "y",
    scale_method = "min_max",
    scale_values = s$scale_values,
    type = "gompertz",
    group = "station",
    pool = c("b", "e", "d")
  )

  expect_s3_class(result, "brmsprior")
  expect_true(all(c("b", "c", "d", "e") %in% result$nlpar))

  sd_rows <- result[result$class == "sd", ]
  expect_equal(nrow(sd_rows), 3)                       # b, e, d
  expect_setequal(sd_rows$nlpar, c("b", "e", "d"))
  expect_true(all(sd_rows$group == "station"))
})

test_that("non-pooled parameters get no sd prior", {
  s <- make_scaled()
  result <- hlpr_resolve_prior_hier(
    mrm_prior = mrmopt_prior(),
    scaled_data = s$scaled_data,
    x = "x", y = "y",
    scale_method = "min_max",
    scale_values = s$scale_values,
    type = "gompertz",
    group = "station",
    pool = "b"
  )
  sd_rows <- result[result$class == "sd", ]
  expect_equal(nrow(sd_rows), 1)
  expect_equal(sd_rows$nlpar, "b")
})

test_that("nested group yields one sd prior per level per pooled param", {
  s <- make_scaled()
  s$scaled_data$subtype <- rep(c("p", "q"), 25)
  result <- hlpr_resolve_prior_hier(
    mrm_prior = mrmopt_prior(),
    scaled_data = s$scaled_data,
    x = "x", y = "y",
    scale_method = "min_max",
    scale_values = s$scale_values,
    type = "gompertz",
    group = c("subtype", "station"),
    pool = c("b", "e")
  )
  sd_rows <- result[result$class == "sd", ]
  # 2 pooled params x 2 levels (subtype, subtype:station)
  expect_equal(nrow(sd_rows), 4)
  expect_setequal(sd_rows$group, c("subtype", "subtype:station"))
})

test_that("log forms move the midpoint prior to le on the log scale", {
  s <- make_scaled()
  result <- hlpr_resolve_prior_hier(
    mrm_prior = mrmopt_prior(),
    scaled_data = s$scaled_data,
    x = "x", y = "y",
    scale_method = "min_max",
    scale_values = s$scale_values,
    type = "log_logistic",
    group = "station",
    pool = c("b", "e", "d")
  )
  expect_true("le" %in% result$nlpar)
  expect_false("e" %in% result$nlpar)

  # le population bounds are on the log scale (negative for scaled e in (0,1))
  le_pop <- result[result$nlpar == "le" & result$class == "b", ]
  expect_lt(as.numeric(le_pop$ub), 0)

  # sd prior for the midpoint is on le, not e
  sd_rows <- result[result$class == "sd", ]
  expect_true("le" %in% sd_rows$nlpar)
  expect_false("e" %in% sd_rows$nlpar)
})

test_that("group_sd_prior overrides the default distribution", {
  s <- make_scaled()
  result <- hlpr_resolve_prior_hier(
    mrm_prior = mrmopt_prior(),
    scaled_data = s$scaled_data,
    x = "x", y = "y",
    scale_method = "min_max",
    scale_values = s$scale_values,
    type = "gompertz",
    group = "station",
    pool = c("b", "d"),
    group_sd_prior = "exponential(3)"
  )
  sd_rows <- result[result$class == "sd", ]
  expect_true(all(sd_rows$prior == "exponential(3)"))
})
