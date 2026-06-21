#' Resolve an mrm_prior specification into a hierarchical brms prior object
#'
#' Extends \code{\link{hlpr_resolve_prior}} for hierarchical fits. Population
#' (channel-level) priors on \code{b}/\code{c}/\code{d}/\code{e} are produced by
#' \code{\link{hlpr_resolve_prior}} unchanged. In addition, partial-pooling
#' standard-deviation priors (\code{class = "sd"}) are appended for each pooled
#' parameter at each level of the hierarchy.
#'
#' @inheritParams hlpr_resolve_prior
#' @param group A character vector of grouping column names, ordered outermost
#'   to innermost (the same vector passed to
#'   \code{\link{hlpr_define_response_form_hier}}).
#' @param pool A character vector naming which of \code{b}, \code{c}, \code{d},
#'   \code{e} receive group-level effects.
#' @param group_sd_prior An optional single \code{brms} distribution string
#'   (e.g. \code{"exponential(1)"}) applied to every partial-pooling SD. When
#'   \code{NULL} (default), per-parameter defaults are used: a wider prior on
#'   the scale parameter \code{d} and a moderate prior on the shape parameters.
#' @return A \code{brmsprior} object containing both population-level and
#'   group-level SD priors.
#'
#' @details
#' SD priors are specified in scaled parameter space, consistent with the
#' population priors. The defaults are weakly informative:
#' \itemize{
#'   \item shape parameters (\code{b}, \code{e}): \code{exponential(1)}
#'   \item scale parameter (\code{d}): \code{exponential(0.5)} — wider, so the
#'     ceiling can vary substantially across units to reflect size differences.
#' }
#'
#' @seealso \code{\link{hlpr_resolve_prior}}, \code{\link{fit_response_hier}}
#' @keywords internal

hlpr_resolve_prior_hier <- function(mrm_prior = NULL,
                                    scaled_data,
                                    x, y,
                                    scale_method,
                                    scale_values,
                                    type,
                                    group,
                                    pool = c("b", "e", "d"),
                                    group_sd_prior = NULL) {

  # --- Population-level priors (channel mean) — reuse the single-fit path ---
  pop_prior <- hlpr_resolve_prior(
    mrm_prior = mrm_prior,
    scaled_data = scaled_data,
    x = x, y = y,
    scale_method = scale_method,
    scale_values = scale_values,
    type = type
  )

  pool <- intersect(pool, c("b", "c", "d", "e"))

  # --- Log-form midpoint reparameterization (e -> le = log(e)) ---
  # The formula for log forms uses `le` in place of log(e). Convert the resolved
  # `e` population prior (a truncated normal on scaled e) into a prior on `le`,
  # placed on the log scale with matching truncation bounds.
  log_forms <- c("log_logistic", "weibull", "reflected_weibull")
  is_log <- type %in% log_forms
  if (is_log) {
    e_row <- pop_prior[pop_prior$nlpar == "e", ]
    e_lb  <- as.numeric(e_row$lb)
    e_ub  <- as.numeric(e_row$ub)
    le_lb <- log(e_lb)
    le_ub <- log(e_ub)
    le_mean <- (le_lb + le_ub) / 2
    le_sd   <- max((le_ub - le_lb) / 2, 0.5)
    le_prior <- brms::prior_string(
      paste0("normal(", round(le_mean, 4), ", ", round(le_sd, 4), ")"),
      nlpar = "le", lb = round(le_lb, 4), ub = round(le_ub, 4)
    )
    pop_prior <- do.call(c, list(pop_prior[pop_prior$nlpar != "e", ], le_prior))
  }

  if (length(pool) == 0) {
    return(pop_prior)
  }

  # Internal parameter name for the midpoint (le on log forms)
  nlpar_for <- function(p) if (p == "e" && is_log) "le" else p

  # --- Level identifiers (match the nested terms in the hier formula) ---
  level_terms <- vapply(
    seq_along(group),
    function(i) paste(group[seq_len(i)], collapse = ":"),
    character(1)
  )

  # --- Default SD prior per parameter (scaled space) ---
  sd_dist <- function(p) {
    if (!is.null(group_sd_prior)) return(group_sd_prior)
    if (p == "d") "exponential(0.5)" else "exponential(1)"
  }

  # --- One sd prior per pooled parameter per level ---
  sd_priors <- list()
  for (p in pool) {
    for (lvl in level_terms) {
      sd_priors[[length(sd_priors) + 1]] <- brms::prior_string(
        sd_dist(p), class = "sd", nlpar = nlpar_for(p), group = lvl
      )
    }
  }

  # Combine via c() — consistent with hlpr_resolve_prior()'s brmsprior handling
  prior <- do.call(c, c(list(pop_prior), sd_priors))
  return(prior)
}
