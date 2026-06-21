# Internal helper: unscale a single b/c/d/e parameter vector from scaled model
# space back to original data units. Mirrors the affine transforms used in
# hlpr_params(); factored out so the hierarchical path (hlpr_params_hier) can
# reuse identical unscaling for per-unit parameters.
#
# v             named numeric vector with elements b, c, d, e (scaled space)
# scale_values  the $scale_values list stored on the fit (or NULL)
# rc_type       response curve type string
#
# Returns the named vector in original data units. When scale_values is NULL
# (model fit without scaling) v is returned unchanged.

hlpr_unscale_params <- function(v, scale_values, rc_type) {

  if (is.null(scale_values)) return(v)

  sv <- scale_values
  x_offset <- if (!is.null(sv$x_offset)) sv$x_offset else 0
  log_forms <- c("log_logistic", "weibull", "reflected_weibull")
  is_log_form <- !is.null(rc_type) && rc_type %in% log_forms

  # --- Unscale x-related params (b, e) ---
  if (is_log_form) {
    v["e"] <- v["e"] * sv$x_max - x_offset
    # b is unchanged for log forms (operates on the log-scale argument)
  } else if (!is.null(sv$x_min) && !is.null(sv$x_max)) {
    x_range <- sv$x_max - sv$x_min
    v["b"] <- v["b"] / x_range
    v["e"] <- v["e"] * x_range + sv$x_min - x_offset
  } else if (!is.null(sv$x_mean) && !is.null(sv$x_sd)) {
    v["b"] <- v["b"] / sv$x_sd
    v["e"] <- v["e"] * sv$x_sd + sv$x_mean - x_offset
  }

  # --- Unscale y-related params (c, d) ---
  if (!is.null(sv$y_min) && !is.null(sv$y_max)) {
    y_range <- sv$y_max - sv$y_min
    v["c"] <- v["c"] * y_range + sv$y_min
    v["d"] <- v["d"] * y_range + sv$y_min
  } else if (!is.null(sv$y_mean) && !is.null(sv$y_sd)) {
    v["c"] <- v["c"] * sv$y_sd + sv$y_mean
    v["d"] <- v["d"] * sv$y_sd + sv$y_mean
  }

  v
}
