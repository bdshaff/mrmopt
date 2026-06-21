# Internal helper: append derived response metrics (absolute response `ar`,
# marginal response `mr`, cost-per `cp`, and their lower/upper/mu variants) to a
# response data frame. Mirrors the derived-metrics block in mrm_infer(); factored
# out so the hierarchical inference path (mrm_infer_hier) produces a column
# schema identical to the single-fit response_df.
#
# Any change here should be mirrored in mrm_infer() and vice versa.
#
# res_df  data frame containing the x column and the response columns that are
#         present among: center, lower, upper, lower_mu, upper_mu
# x_col   name of the x (spend) column in res_df
#
# Returns res_df with the metric columns appended.

hlpr_response_metrics <- function(res_df, x_col) {

  add_ar_mr <- function(df, ycol, ar_name, mr_name) {
    df[[ar_name]] <- (df[[ycol]] - min(df[[ycol]])) / df[[x_col]]
    df[[mr_name]] <- c(NA, diff(df[[ycol]]) / diff(df[[x_col]]))
    df
  }
  cp_scaled <- function(df, ycol) {
    denom <- df[[ycol]] - min(df[[ycol]])
    df[[x_col]] / denom * (sum(denom) / sum(df[[ycol]]))
  }

  # --- center ---
  if (!is.null(res_df$center)) {
    res_df <- add_ar_mr(res_df, "center", "ar", "mr")
    res_df$cp       <- cp_scaled(res_df, "center")
    res_df$cp_lower <- res_df[[x_col]] / (res_df$center - min(res_df$center))
  }

  # --- prediction-interval bounds ---
  if (!is.null(res_df$lower)) {
    res_df <- add_ar_mr(res_df, "lower", "ar_lower", "mr_lower")
  }
  if (!is.null(res_df$upper)) {
    res_df <- add_ar_mr(res_df, "upper", "ar_upper", "mr_upper")
    res_df$cp_upper <- cp_scaled(res_df, "upper")
  }

  # --- mean-function credible bounds ---
  if (!is.null(res_df$lower_mu)) {
    res_df <- add_ar_mr(res_df, "lower_mu", "ar_lower_mu", "mr_lower_mu")
  }
  if (!is.null(res_df$upper_mu)) {
    res_df <- add_ar_mr(res_df, "upper_mu", "ar_upper_mu", "mr_upper_mu")
    res_df$cp_upper_mu <- cp_scaled(res_df, "upper_mu")
  }

  res_df
}
