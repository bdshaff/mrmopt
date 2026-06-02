make_stub <- function(spend_col = NULL, data_cols = NULL, resp = "opps") {
  stub <- list(spend_col = spend_col, formula = list(resp = resp))
  if (!is.null(data_cols)) {
    stub$data <- setNames(data.frame(matrix(0, 1, length(data_cols))), data_cols)
  }
  stub
}

test_that("strips 'spend_' prefix from spend_col", {
  m <- make_stub(spend_col = "spend_search")
  expect_equal(hlpr_channel_name(m), "search")
})

test_that("strips 'spend.' prefix from spend_col", {
  m <- make_stub(spend_col = "spend.display")
  expect_equal(hlpr_channel_name(m), "display")
})

test_that("strips 'spend' with no separator", {
  m <- make_stub(spend_col = "spendsearch")
  expect_equal(hlpr_channel_name(m), "search")
})

test_that("handles double underscores in channel name", {
  m <- make_stub(spend_col = "spend_video__streaming")
  # underscores / dots in the suffix are converted to spaces
  expect_equal(hlpr_channel_name(m), "video  streaming")
})

test_that("falls back to data column name when spend_col is NULL", {
  m <- make_stub(spend_col = NULL, data_cols = c("opps", "spendchannel"), resp = "opps")
  result <- hlpr_channel_name(m)
  # "spendchannel" -> sub removes "spend" -> "channel" -> gsub no-op -> "channel"
  expect_equal(result, "channel")
})

test_that("returns trimmed string (no leading/trailing whitespace)", {
  m <- make_stub(spend_col = "spend_channel")
  expect_equal(hlpr_channel_name(m), trimws(hlpr_channel_name(m)))
})
