# -------------------------------------------------------------------------
# mrm_plot_compare tests
# -------------------------------------------------------------------------

# Two mocks with same channel, same type (will trigger collision path)
make_pair <- function(type = "gompertz", with_dates = TRUE) {
  m1 <- make_mock_mrmfit(type)
  m2 <- make_mock_mrmfit(type)
  if (with_dates) {
    m1$date_range <- as.Date(c("2023-01-01", "2023-12-31"))
    m2$date_range <- as.Date(c("2024-01-01", "2024-12-31"))
  } else {
    m1$date_range <- NULL
    m2$date_range <- NULL
  }
  list(m1, m2)
}

# -------------------------------------------------------------------------
# Input validation
# -------------------------------------------------------------------------

test_that("errors when models list has fewer than 2 elements", {
  mock <- make_mock_mrmfit("gompertz")
  expect_error(mrm_plot_compare(list(mock)), "at least 2")
})

test_that("errors when models is not a list", {
  expect_error(mrm_plot_compare("not_a_list"), "at least 2")
})

# -------------------------------------------------------------------------
# Returns ggplot
# -------------------------------------------------------------------------

test_that("returns a ggplot for default (response, overlay)", {
  pair <- make_pair()
  p    <- mrm_plot_compare(pair)
  expect_s3_class(p, "ggplot")
})

test_that("returns a ggplot for plot_type = 'return'", {
  pair <- make_pair()
  p    <- mrm_plot_compare(pair, plot_type = "return")
  expect_s3_class(p, "ggplot")
})

test_that("returns a ggplot for plot_type = 'costper'", {
  pair <- make_pair()
  p    <- mrm_plot_compare(pair, plot_type = "costper")
  expect_s3_class(p, "ggplot")
})

# -------------------------------------------------------------------------
# Layout
# -------------------------------------------------------------------------

test_that("layout = 'facet' adds FacetWrap to plot", {
  pair <- make_pair()
  p    <- mrm_plot_compare(pair, layout = "facet")
  expect_true(inherits(p$facet, "FacetWrap"))
})

test_that("layout = 'overlay' does not add FacetWrap", {
  pair <- make_pair()
  p    <- mrm_plot_compare(pair, layout = "overlay")
  expect_false(inherits(p$facet, "FacetWrap"))
})

# -------------------------------------------------------------------------
# Label collision resolution
# -------------------------------------------------------------------------

test_that("same channel + same type + date_range: labels include date shorthand", {
  pair <- make_pair(with_dates = TRUE)
  p    <- mrm_plot_compare(pair)
  # Extract model_id values from the plot data
  model_ids <- unique(p$data$model_id)
  expect_equal(length(model_ids), 2)
  # Both labels should contain the year (from Mon 'YY format)
  expect_true(all(grepl("'23|'24", model_ids)))
})

test_that("same channel + same type + no date_range: labels get positional suffix", {
  pair <- make_pair(with_dates = FALSE)
  p    <- mrm_plot_compare(pair)
  model_ids <- unique(p$data$model_id)
  expect_equal(length(model_ids), 2)
  # Should contain "(1)" and "(2)" or similar disambiguation
  expect_true(any(grepl("\\(1\\)|\\(2\\)", model_ids)))
})

test_that("different curve types same channel: labels are type names without date", {
  m1 <- make_mock_mrmfit("gompertz")
  m2 <- make_mock_mrmfit("logistic")
  p  <- mrm_plot_compare(list(m1, m2))
  model_ids <- unique(p$data$model_id)
  expect_true("gompertz" %in% model_ids)
  expect_true("logistic"  %in% model_ids)
})

test_that("user-supplied names are used as labels (names bug regression)", {
  m1    <- make_mock_mrmfit("gompertz")
  m2    <- make_mock_mrmfit("gompertz")
  named <- list("Period A" = m1, "Period B" = m2)
  p     <- mrm_plot_compare(named)
  model_ids <- unique(p$data$model_id)
  expect_true("Period A" %in% model_ids)
  expect_true("Period B" %in% model_ids)
})

# -------------------------------------------------------------------------
# x_var = units
# -------------------------------------------------------------------------

test_that("x_var = 'units' errors when models have no units", {
  pair <- make_pair()
  expect_error(mrm_plot_compare(pair, x_var = "units"), "Units not available")
})

test_that("x_var = 'units' works when models have units", {
  m1 <- make_mock_mrmfit("gompertz", with_units = TRUE)
  m2 <- make_mock_mrmfit("logistic", with_units = TRUE)
  p  <- mrm_plot_compare(list(m1, m2), x_var = "units")
  expect_s3_class(p, "ggplot")
})
