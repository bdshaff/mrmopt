#' Extract and unscale posterior draws from fitted MRM models
#'
#' Pre-processes posterior draws from one or more `mrmfit` objects so they can
#' be evaluated directly with `rm_dispatch()` on unscaled (original-unit) x
#' values. This avoids the overhead of `brms::posterior_epred()` in tight
#' optimization loops.
#'
#' @param mrms A single `mrmfit` object or a list of `mrmfit` objects.
#' @return A list (one element per model) of lists, each containing:
#'   \describe{
#'     \item{curve_fn}{The response curve function from `rm_dispatch()`.}
#'     \item{b, c, d, e}{Numeric vectors of unscaled posterior draws.}
#'     \item{n_draws}{Number of posterior draws available.}
#'     \item{channel}{Channel name (from list names, if any).}
#'   }
#' @importFrom posterior as_draws_df
#' @keywords internal

hlpr_extract_draws <- function(mrms) {

 if (inherits(mrms, "mrmfit")) mrms <- list(mrms)

 log_forms <- c("log_logistic", "weibull", "reflected_weibull")

 result <- lapply(seq_along(mrms), function(i) {
   m <- mrms[[i]]
   sv <- m$scale_values
   rc_type <- m$rc_type
   is_log <- rc_type %in% log_forms

   x_offset <- if (!is.null(sv$x_offset)) sv$x_offset else 0

   # Extract raw (scaled) posterior draws
   raw <- posterior::as_draws_df(m)
   b_raw <- raw$b_b_Intercept
   c_raw <- raw$b_c_Intercept
   d_raw <- raw$b_d_Intercept
   e_raw <- raw$b_e_Intercept

   # --- Unscale x-related params (b, e) ---
   if (is_log) {
     b_out <- b_raw
     e_out <- e_raw * sv$x_max - x_offset
   } else if (!is.null(sv$x_min) && !is.null(sv$x_max)) {
     # standard form, min_max scaling
     x_range <- sv$x_max - sv$x_min
     b_out <- b_raw / x_range
     e_out <- e_raw * x_range + sv$x_min - x_offset
   } else if (!is.null(sv$x_mean) && !is.null(sv$x_sd)) {
     # standard form, std scaling
     b_out <- b_raw / sv$x_sd
     e_out <- e_raw * sv$x_sd + sv$x_mean - x_offset
   } else {
     stop("Unrecognized scale_values structure for model ", i)
   }

   # --- Unscale y-related params (c, d) ---
   if (!is.null(sv$y_min) && !is.null(sv$y_max)) {
     y_range <- sv$y_max - sv$y_min
     c_out <- c_raw * y_range + sv$y_min
     d_out <- d_raw * y_range + sv$y_min
   } else if (!is.null(sv$y_mean) && !is.null(sv$y_sd)) {
     c_out <- c_raw * sv$y_sd + sv$y_mean
     d_out <- d_raw * sv$y_sd + sv$y_mean
   } else {
     stop("Unrecognized y scale_values structure for model ", i)
   }

   list(
     curve_fn = rm_dispatch(rc_type),
     b = b_out,
     c = c_out,
     d = d_out,
     e = e_out,
     n_draws = length(b_out),
     channel = names(mrms)[i]
   )
 })

 names(result) <- names(mrms)
 result
}
