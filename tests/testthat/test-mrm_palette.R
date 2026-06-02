test_that("mrm_palette returns a named character vector", {
  pal <- mrm_palette()
  expect_type(pal, "character")
  expect_true(!is.null(names(pal)))
})

test_that("mrm_palette contains all required color names", {
  required <- c("response", "ci_band", "data_pts", "ar", "mr", "cp",
                "current", "range_fill", "range_line", "floor", "ceiling", "midpoint")
  pal <- mrm_palette()
  expect_true(all(required %in% names(pal)))
})

test_that("all palette values are valid 6-digit hex colors", {
  pal <- mrm_palette()
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", pal)))
})
