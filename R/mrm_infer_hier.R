#' Infer per-unit, per-level, and channel response curves from a hierarchical fit
#'
#' The hierarchical counterpart to \code{\link{mrm_infer}}. Produces a long
#' response data frame with one response curve per unit at \emph{every} level of
#' the hierarchy (e.g. each subtype mean and each subtype:station unit) plus the
#' channel-level (population mean) curve. Each curve has the same column schema
#' as the single-fit \code{response_df} (center, prediction-interval bounds
#' \code{lower}/\code{upper}, mean-function bounds \code{lower_mu}/\code{upper_mu},
#' and the derived \code{ar}/\code{mr}/\code{cp} metrics), with two extra key
#' columns: \code{id} (unit id, or \code{"(channel)"} for the mean curve) and
#' \code{level} (the cumulative grouping term, or \code{"channel"}).
#'
#' Each level's bands are produced with an \code{re_formula} that includes only
#' the grouping terms up to and including that level, so the uncertainty
#' correctly reflects the data available at that level.
#'
#' @param mrm A fitted \code{mrmfit_hier} object from
#'   \code{\link{fit_response_hier}}.
#' @param xrange Optional length-2 numeric range of x in scaled model space
#'   (as produced by \code{hlpr_scale_data}). When \code{NULL}, derived from the
#'   observed (scaled) spend range. The returned x column is always unscaled to
#'   original spend units.
#' @param length.out Number of points per curve. Default 1000.
#' @param scaled Logical; whether the model was fitted on scaled data.
#' @param include_channel Logical; include the channel-level mean curve. Default
#'   \code{TRUE}.
#' @return A long \code{data.frame} (one block of \code{length.out} rows per unit
#'   at each level and, optionally, the channel mean).
#' @importFrom stats fitted predict smooth.spline as.formula
#' @export

mrm_infer_hier <- function(mrm, xrange = NULL, length.out = 1000,
                           scaled = TRUE, include_channel = TRUE) {

  if (!inherits(mrm, "mrmfit_hier")) {
    stop("mrm must be a fitted model object created by fit_response_hier()",
         call. = FALSE)
  }

  rc_type    <- mrm$rc_type
  rc_data    <- mrm$data
  y          <- mrm$formula$resp
  group_cols <- mrm$group
  L          <- length(group_cols)
  # brms adds an interaction column (e.g. "subtype:station") to fit$data for
  # nested grouping terms; exclude those (they contain ":") along with the
  # response and grouping columns to isolate the spend column.
  x <- setdiff(names(rc_data),
               c(y, group_cols, grep(":", names(rc_data), value = TRUE)))
  if (length(x) != 1) {
    stop("Could not unambiguously identify the spend column in the fit data.",
         call. = FALSE)
  }

  ph      <- hlpr_params_hier(mrm, scaled = scaled)
  nesting <- ph$nesting
  term_name <- function(i) paste(group_cols[seq_len(i)], collapse = ":")
  re_formula_for <- function(i) {
    stats::as.formula(
      paste("~", paste(sprintf("(1 | %s)", vapply(seq_len(i), term_name, character(1))),
                       collapse = " + "))
    )
  }

  sv       <- if (scaled) mrm$scale_values else NULL
  x_offset <- if (!is.null(sv) && !is.null(sv$x_offset)) sv$x_offset else 0

  if (is.null(xrange)) {
    xrange_s <- c(min(rc_data[[x]], na.rm = TRUE),
                  2 * max(rc_data[[x]], na.rm = TRUE))
  } else {
    xrange_s <- xrange
  }
  xseq_s <- seq(xrange_s[1], xrange_s[2], length.out = length.out)

  unscale_x <- function(xs) {
    if (is.null(sv)) return(xs)
    if (!is.null(sv$x_min) && !is.null(sv$x_max)) {
      xs * (sv$x_max - sv$x_min) + sv$x_min - x_offset
    } else if (!is.null(sv$x_mean) && !is.null(sv$x_sd)) {
      xs * sv$x_sd + sv$x_mean - x_offset
    } else xs
  }
  unscale_y <- function(df) {
    if (is.null(sv)) return(df)
    if (!is.null(sv$y_min) && !is.null(sv$y_max)) {
      yr <- sv$y_max - sv$y_min
      for (col in colnames(df)) {
        df[[col]] <- if (grepl("Est.Error", col)) df[[col]] * yr else df[[col]] * yr + sv$y_min
      }
    } else if (!is.null(sv$y_mean) && !is.null(sv$y_sd)) {
      for (col in colnames(df)) {
        df[[col]] <- if (grepl("Est.Error", col)) df[[col]] * sv$y_sd else df[[col]] * sv$y_sd + sv$y_mean
      }
    }
    df
  }
  xseq_raw <- unscale_x(xseq_s)

  # factor-coerce a group value to the training levels
  as_train_factor <- function(col, val) {
    factor(val, levels = levels(factor(rc_data[[col]])))
  }

  build_block <- function(center_params, pred_slice, mu_slice, id, level) {
    center_params <- as.list(center_params)
    res <- data.frame(xseq_raw); names(res) <- x
    res$center   <- response(xseq_raw, center_params, type = rc_type)
    res$lower    <- pmax(stats::smooth.spline(pred_slice$Q2.5)$y, 0)
    res$upper    <- stats::smooth.spline(pred_slice$Q97.5)$y
    res$lower_mu <- pmax(stats::smooth.spline(mu_slice$Q2.5)$y, 0)
    res$upper_mu <- stats::smooth.spline(mu_slice$Q97.5)$y
    res <- hlpr_response_metrics(res, x)
    res$type <- rc_type; res$resp_var <- y; res$input_var <- x
    res$id <- id; res$level <- level
    if (!is.null(mrm$units_col) && !is.null(mrm$cost_per_unit)) {
      res$units <- res[[x]] / mrm$cost_per_unit
    }
    res
  }

  n <- length.out
  all_blocks <- list()

  # --- One block-set per hierarchy level ---
  for (i in seq_len(L)) {
    tnm      <- term_name(i)
    unit_tbl <- ph$levels[[tnm]]
    lab_col  <- paste0(".lab", i)

    # Representative full group combo for each unit (deeper levels are excluded
    # by re_formula, so any consistent child works)
    rep_idx <- match(unit_tbl$id, nesting[[lab_col]])
    newdata <- do.call(rbind, lapply(seq_len(nrow(unit_tbl)), function(k) {
      d <- data.frame(xseq_s); names(d) <- x
      for (g in group_cols) d[[g]] <- as_train_factor(g, nesting[[g]][rep_idx[k]])
      d
    }))

    ref <- re_formula_for(i)
    pred <- unscale_y(as.data.frame(stats::predict(mrm, newdata = newdata, re_formula = ref)))
    mu   <- unscale_y(as.data.frame(stats::fitted(mrm,  newdata = newdata, re_formula = ref)))

    for (k in seq_len(nrow(unit_tbl))) {
      rows <- ((k - 1) * n + 1):(k * n)
      cp <- as.list(unlist(unit_tbl[k, c("b", "c", "d", "e")]))
      all_blocks[[length(all_blocks) + 1]] <- build_block(
        cp, pred[rows, , drop = FALSE], mu[rows, , drop = FALSE],
        id = unit_tbl$id[k], level = tnm)
    }
  }

  # --- Channel-level mean curve (re_formula = NA) ---
  if (include_channel) {
    chan_newdata <- data.frame(xseq_s); names(chan_newdata) <- x
    for (g in group_cols) chan_newdata[[g]] <- as_train_factor(g, nesting[[g]][1])
    chan_pred <- unscale_y(as.data.frame(
      stats::predict(mrm, newdata = chan_newdata, re_formula = NA)))
    chan_mu   <- unscale_y(as.data.frame(
      stats::fitted(mrm,  newdata = chan_newdata, re_formula = NA)))
    all_blocks[[length(all_blocks) + 1]] <- build_block(
      ph$channel$center, chan_pred, chan_mu, id = "(channel)", level = "channel")
  }

  res_df <- do.call(rbind, all_blocks)
  rownames(res_df) <- NULL
  res_df
}
