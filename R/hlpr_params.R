# Internal helper: extract and unscale b/c/d/e parameter estimates from a
# fitted mrmfit object. Returns a list with $center, $lower, $upper, each a
# named numeric list with elements b, c, d, e in original data units.

hlpr_params <- function(rc_fit, scaled = TRUE) {

  # Per-unit views from a hierarchical fit (as_mrmfit_list) carry precomputed,
  # already-unscaled parameters — there is no brms $fixed table to read.
  if (!is.null(rc_fit$params_hier_unit)) {
    return(rc_fit$params_hier_unit)
  }

  # Extract posterior summaries for parameters b, c, d, e
  posterior_summary <- summary(rc_fit)$fixed
  params <- posterior_summary[grepl("b|c|d|e", rownames(posterior_summary)), , drop = FALSE]
  params <- as.data.frame(params)

  center = params$Estimate
  names(center) = c("b","c","d","e")

  lower = params$`l-95% CI`
  names(lower) = c("b","c","d","e")

  upper = params$`u-95% CI`
  names(upper) = c("b","c","d","e")

  # Rescale parameters if the model was fitted on scaled data. The affine
  # unscaling is shared with the hierarchical path via hlpr_unscale_params().
  if (scaled && !is.null(rc_fit$scale_values)) {
    sv <- rc_fit$scale_values
    center <- hlpr_unscale_params(center, sv, rc_fit$rc_type)
    lower  <- hlpr_unscale_params(lower,  sv, rc_fit$rc_type)
    upper  <- hlpr_unscale_params(upper,  sv, rc_fit$rc_type)
  }

  # Create a list to hold the parameters
  params_list <- list(
    center = as.list(center),
    lower = as.list(lower),
    upper = as.list(upper)
  )

  # Return the list of parameters
  return(params_list)
}
