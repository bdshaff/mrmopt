# Minimal fake mrmfit_hier carrying just the fields the plotters read.
make_fake_hier <- function() {
  rdf <- rbind(
    data.frame(spend = 1:10, center = (1:10) * 10, id = "u1", level = "station"),
    data.frame(spend = 1:10, center = (1:10) * 8,  id = "u2", level = "station"),
    data.frame(spend = 1:10, center = (1:10) * 9,  id = "(channel)", level = "channel")
  )
  lvl <- tibble::tibble(
    id = c("u1", "u2"),
    b = c(-1, -1.2), c = c(0, 0), d = c(110, 90), e = c(4, 6),
    b_lower = c(-1.3, -1.5), c_lower = c(0, 0), d_lower = c(95, 75), e_lower = c(3, 5),
    b_upper = c(-0.7, -0.9), c_upper = c(0, 0), d_upper = c(125, 105), e_upper = c(5, 7)
  )
  ph <- list(
    channel = list(center = list(b = -1.1, c = 0, d = 100, e = 5)),
    levels  = list(station = lvl)
  )
  s <- tibble::tibble(
    id = c("u1", "u2", "(channel)"),
    level = c("station", "station", "channel"),
    n_weeks = c(20, 15, 35)
  )
  obj <- list(
    response_df = rdf, params_hier = ph, summary = s,
    spend_col = "spend", rc_type = "gompertz",
    units_col = NULL, cost_per_unit = NULL,
    group = "station", levels = list(station = c("u1", "u2"))
  )
  class(obj) <- c("mrmfit_hier", "brmsfit")
  obj
}

# Render a patchwork/ggplot to a null device to confirm it assembles.
expect_builds <- function(p) {
  expect_no_error({
    grDevices::pdf(NULL)
    on.exit(grDevices::dev.off(), add = TRUE)
    print(p)
  })
}

test_that("mrm_plot_hier_response returns a buildable ggplot", {
  p <- mrm_plot_hier_response(make_fake_hier())
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("mrm_plot_hier_shrinkage builds for each param", {
  fh <- make_fake_hier()
  for (pr in c("e", "b", "d", "c")) {
    p <- mrm_plot_hier_shrinkage(fh, param = pr)
    expect_s3_class(p, "ggplot")
    expect_no_error(ggplot2::ggplot_build(p))
  }
})

test_that("mrm_plot_hier dashboard returns a patchwork", {
  p <- mrm_plot_hier(make_fake_hier())            # default type = "dashboard"
  expect_s3_class(p, "patchwork")
  expect_builds(p)
})

test_that("plot.mrmfit_hier dispatches to the dashboard", {
  p <- plot(make_fake_hier())
  expect_s3_class(p, "patchwork")
})

test_that("errors on non-mrmfit_hier input", {
  expect_error(mrm_plot_hier(list(rc_type = "gompertz")), "fit_response_hier")
  expect_error(mrm_plot_hier_response(list(rc_type = "gompertz")), "fit_response_hier")
  expect_error(mrm_plot_hier_shrinkage(list(rc_type = "gompertz")), "fit_response_hier")
})


# --- Nested (2-level) fake -------------------------------------------------
make_fake_hier2 <- function() {
  grid <- 1:10
  block <- function(id, lvl, mult) {
    data.frame(spend = grid, center = grid * mult, id = id, level = lvl)
  }
  rdf <- rbind(
    block("alpha", "subtype", 9), block("beta", "subtype", 9),
    block("alpha_st1", "subtype:station", 10), block("alpha_st2", "subtype:station", 8),
    block("beta_st3", "subtype:station", 11),  block("beta_st4", "subtype:station", 6),
    block("(channel)", "channel", 9)
  )
  lvl_tbl <- function(ids, d) tibble::tibble(
    id = ids, b = -1, c = 0, d = d, e = seq(4, 6, length.out = length(ids)),
    b_lower = -1.3, c_lower = 0, d_lower = d * 0.9, e_lower = 3,
    b_upper = -0.7, c_upper = 0, d_upper = d * 1.1, e_upper = 7
  )
  ph <- list(
    channel = list(center = list(b = -1.1, c = 0, d = 100, e = 5)),
    levels  = list(
      subtype           = lvl_tbl(c("alpha", "beta"), c(105, 95)),
      `subtype:station` = lvl_tbl(c("alpha_st1", "alpha_st2", "beta_st3", "beta_st4"),
                                  c(110, 90, 115, 60))
    )
  )
  s <- tibble::tibble(
    id = c("alpha", "beta", "alpha_st1", "alpha_st2", "beta_st3", "beta_st4", "(channel)"),
    level = c("subtype", "subtype", rep("subtype:station", 4), "channel"),
    n_weeks = c(50, 50, 25, 25, 25, 25, 100)
  )
  obj <- list(
    response_df = rdf, params_hier = ph, summary = s,
    spend_col = "spend", rc_type = "gompertz",
    units_col = NULL, cost_per_unit = NULL,
    group = c("subtype", "station")
  )
  class(obj) <- c("mrmfit_hier", "brmsfit")
  obj
}

test_that("nested response plot defaults to the innermost level", {
  p <- mrm_plot_hier_response(make_fake_hier2())
  expect_s3_class(p, "ggplot")
  ids <- unique(ggplot2::ggplot_build(p)$plot$data$id)
  expect_setequal(ids, c("alpha_st1", "alpha_st2", "beta_st3", "beta_st4"))
})

test_that("nested response plot honors an explicit level", {
  p <- mrm_plot_hier_response(make_fake_hier2(), level = "subtype")
  expect_s3_class(p, "ggplot")
  expect_setequal(unique(ggplot2::ggplot_build(p)$plot$data$id), c("alpha", "beta"))
})

test_that("nested shrinkage plot builds for each level", {
  fh <- make_fake_hier2()
  for (lv in c("subtype", "subtype:station")) {
    p <- mrm_plot_hier_shrinkage(fh, param = "d", level = lv)
    expect_s3_class(p, "ggplot")
    expect_no_error(ggplot2::ggplot_build(p))
  }
})

test_that("nested dashboard builds one response panel per level", {
  expect_builds(mrm_plot_hier(make_fake_hier2()))
})

test_that("response / shrinkage error on an unknown level", {
  expect_error(mrm_plot_hier_response(make_fake_hier2(), level = "nope"), "not found")
  expect_error(mrm_plot_hier_shrinkage(make_fake_hier2(), level = "nope"), "not found")
})
