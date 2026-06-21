# Internal helper: extract channel-level and per-unit b/c/d/e parameters from a
# fitted mrmfit_hier object, unscaled to original data units. Supports nested
# hierarchies of arbitrary depth.
#
# The channel-level (population) parameters come from fixef(). For a unit at
# hierarchy level i, the parameter is composed down the nesting chain:
#
#   population intercept  +  Sigma_{j=1..i} (level-j ancestor deviation)
#
# i.e. a station-level curve sums the population value, its subtype deviation,
# and its subtype:station deviation. Following the prototype, per-unit
# lower/upper bounds hold the ancestor deviations at their point estimates and
# swap only the unit's own (innermost) deviation for its Q2.5/Q97.5 — so the
# interval reflects that unit's shrinkage uncertainty. Non-pooled parameters
# take the channel value and CI for every unit.
#
# Returns a list:
#   $channel : list(center, lower, upper), each a named b/c/d/e vector (unscaled)
#   $levels  : named list keyed by the cumulative grouping term ("subtype",
#              "subtype:station", ...); each a tibble with columns id, b, c, d, e
#              (center) and <par>_lower / <par>_upper, unscaled.
#   $nesting : the distinct group-column combinations with cumulative level
#              labels (.lab1, .lab2, ...) used by the inference/summary helpers.

hlpr_params_hier <- function(mrm, scaled = TRUE) {

  sv      <- if (scaled) mrm$scale_values else NULL
  rc_type <- mrm$rc_type
  pool    <- mrm$pool
  pars    <- c("b", "c", "d", "e")
  group_cols <- mrm$group
  L <- length(group_cols)

  # For log forms the midpoint is modeled internally as le = log(e); read it
  # under the name "le", compose in log space, then exponentiate to e before
  # unscaling. internal()/expe() localize that translation.
  is_log   <- !is.null(rc_type) &&
    rc_type %in% c("log_logistic", "weibull", "reflected_weibull")
  internal <- function(p) if (p == "e" && is_log) "le" else p
  expe     <- function(v) { if (is_log) v[["e"]] <- exp(v[["e"]]); v }

  # --- Channel-level (population) estimates, scaled space ---
  fe <- brms::fixef(mrm)
  rn <- vapply(pars, function(p) paste0(internal(p), "_Intercept"), character(1))
  pop <- list(
    center = stats::setNames(fe[rn, "Estimate"], pars),
    lower  = stats::setNames(fe[rn, "Q2.5"],     pars),
    upper  = stats::setNames(fe[rn, "Q97.5"],    pars)
  )
  channel <- list(
    center = hlpr_unscale_params(expe(pop$center), sv, rc_type),
    lower  = hlpr_unscale_params(expe(pop$lower),  sv, rc_type),
    upper  = hlpr_unscale_params(expe(pop$upper),  sv, rc_type)
  )

  re <- brms::ranef(mrm)
  term_name <- function(i) paste(group_cols[seq_len(i)], collapse = ":")

  # --- Nesting map: distinct group combos with cumulative level labels ---
  # Level-i label joins the first i grouping columns with "_" (matching the
  # interaction level ids brms produces, e.g. "alpha_st1").
  combos <- unique(mrm$data[, group_cols, drop = FALSE])
  combos[] <- lapply(combos, as.character)
  for (i in seq_len(L)) {
    combos[[paste0(".lab", i)]] <- if (i == 1) {
      combos[[group_cols[1]]]
    } else {
      apply(combos[, group_cols[seq_len(i)], drop = FALSE], 1,
            paste, collapse = "_")
    }
  }

  # --- Compose parameters per level ---
  levels_out <- list()
  for (i in seq_len(L)) {
    tnm   <- term_name(i)
    arr_i <- re[[tnm]]
    re_pars_i <- dimnames(arr_i)[[3]]

    # One row per distinct level-i unit, carrying its ancestor labels
    sub <- combos[!duplicated(combos[[paste0(".lab", i)]]), , drop = FALSE]

    rows <- lapply(seq_len(nrow(sub)), function(k) {
      anc <- vapply(seq_len(i),
                    function(j) sub[[paste0(".lab", j)]][k], character(1))

      center <- pop$center; lower <- pop$center; upper <- pop$center

      for (p in pars) {
        rp <- paste0(internal(p), "_Intercept")
        if (p %in% pool) {
          # Sum ancestor point deviations for shallower levels (j < i)
          base <- pop$center[[p]]
          if (i > 1) {
            for (j in seq_len(i - 1)) {
              arrj <- re[[term_name(j)]]
              if (rp %in% dimnames(arrj)[[3]]) {
                base <- base + arrj[anc[j], "Estimate", rp]
              }
            }
          }
          # This unit's own (level-i) deviation supplies center/lower/upper
          if (rp %in% re_pars_i) {
            center[[p]] <- base + arr_i[anc[i], "Estimate", rp]
            lower[[p]]  <- base + arr_i[anc[i], "Q2.5",     rp]
            upper[[p]]  <- base + arr_i[anc[i], "Q97.5",    rp]
          } else {
            center[[p]] <- base; lower[[p]] <- base; upper[[p]] <- base
          }
        } else {
          # non-pooled: channel value + channel CI
          lower[[p]] <- pop$lower[[p]]
          upper[[p]] <- pop$upper[[p]]
        }
      }

      cu <- hlpr_unscale_params(expe(center), sv, rc_type)
      lu <- hlpr_unscale_params(expe(lower),  sv, rc_type)
      uu <- hlpr_unscale_params(expe(upper),  sv, rc_type)

      tibble::tibble(
        id      = anc[i],
        b = cu[["b"]], c = cu[["c"]], d = cu[["d"]], e = cu[["e"]],
        b_lower = lu[["b"]], c_lower = lu[["c"]], d_lower = lu[["d"]], e_lower = lu[["e"]],
        b_upper = uu[["b"]], c_upper = uu[["c"]], d_upper = uu[["d"]], e_upper = uu[["e"]]
      )
    })

    levels_out[[tnm]] <- do.call(rbind, rows)
  }

  list(channel = channel, levels = levels_out, nesting = combos)
}
