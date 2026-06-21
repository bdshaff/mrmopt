#' Print method for mrmfit_hier objects
#'
#' Displays a compact summary of a fitted hierarchical response curve model:
#' the channel and KPI, the hierarchy structure with per-level unit counts, the
#' channel-level (population mean) curve parameters in original data units, a
#' per-unit table of ceiling/midpoint and current performance, and the Bayes R2.
#'
#' @param x An \code{mrmfit_hier} object returned by
#'   \code{\link{fit_response_hier}}.
#' @param ... Additional arguments (ignored).
#' @return The object \code{x}, invisibly.
#'
#' @export

print.mrmfit_hier <- function(x, ...) {

  rc_type <- x$rc_type
  dollar <- function(v) paste0("$", formatC(v, format = "f", big.mark = ",", digits = 0))
  comma  <- function(v) formatC(v, format = "f", big.mark = ",", digits = 0)

  cat(cli_rule(paste0("Hierarchical Response Curve: ", rc_type)), "\n")
  cat("Channel: ", x$spend_col, "  |  KPI: ", x$kpi_col, "\n", sep = "")

  # --- Hierarchy structure ---
  cat(cli_rule("Hierarchy"), "\n")
  group_orig <- if (!is.null(x$group_orig)) x$group_orig else x$group
  ph <- x$params_hier
  for (i in seq_along(x$group)) {
    term <- paste(x$group[seq_len(i)], collapse = ":")
    n_units <- if (!is.null(ph) && !is.null(ph$levels[[term]])) {
      nrow(ph$levels[[term]])
    } else {
      length(x$levels[[i]])
    }
    cat(sprintf("  Level %d: %-20s %d unit(s)\n", i, group_orig[i], n_units))
  }
  cat("  Pooled parameters: ", paste(x$pool, collapse = ", "), "\n", sep = "")

  # --- Channel-level (population mean) parameters, unscaled ---
  cat(cli_rule("Channel-Level Parameters (mean curve)"), "\n")
  ch <- if (!is.null(x$params_hier)) x$params_hier$channel$center else
    tryCatch(hlpr_params(x, scaled = !is.null(x$scale_values))$center,
             error = function(e) NULL)
  if (!is.null(ch)) {
    labels <- list(b = "growth rate", c = "floor", d = "ceiling", e = "midpoint")
    for (p in c("b", "c", "d", "e")) {
      val_str <- if (p == "b") {
        formatC(ch[[p]], format = "e", digits = 2)
      } else if (p == "e") {
        dollar(ch[[p]])
      } else {
        comma(ch[[p]])
      }
      cat(sprintf("  %-20s %s\n", paste0(p, " (", labels[[p]], "):"), val_str))
    }
  } else {
    cat("  Parameters not available.\n")
  }

  # --- Per-unit table (innermost level only) ---
  s <- x$summary
  if (!is.null(s)) {
    innermost <- paste(x$group, collapse = ":")
    units <- s[s$level == innermost, , drop = FALSE]
    cat(cli_rule(paste0("Sub-Channel Units (", nrow(units), ")")), "\n")
    cat(sprintf("  %-18s %12s %12s %12s\n",
                "unit", "wkly spend", "KPI", "ceiling (d)"))
    for (i in seq_len(nrow(units))) {
      cat(sprintf("  %-18s %12s %12s %12s\n",
                  substr(units$id[i], 1, 18),
                  dollar(units$weekly_spend[i]),
                  comma(units$kpi_at_current[i]),
                  comma(units$d[i])))
    }
  }

  # --- Bayes R2 ---
  cat(cli_rule("Bayes R2"), "\n")
  if (!is.null(x$R2)) {
    cat(sprintf("  R2: %.4f (95%% CI: [%.4f, %.4f])\n",
                x$R2$Estimate, x$R2$Q2.5, x$R2$Q97.5))
  } else {
    cat("  R2 not available.\n")
  }

  cat("\nUse summary(x) for brms diagnostics; mrm_summary_hier(x) for the full table.\n")

  invisible(x)
}
