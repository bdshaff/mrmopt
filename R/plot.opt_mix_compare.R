#' Plot method for opt_mix_compare objects
#'
#' Produces a dumbbell chart comparing two optimization results side by side.
#'
#' @param x An `opt_mix_compare` tibble returned by [compare()].
#' @param type Character; `"spend"` (default) or `"kpi"`.
#' @param ... Additional arguments (currently unused).
#' @return A ggplot object.
#' @import ggplot2
#' @export

plot.opt_mix_compare <- function(x,
                                 type = c("spend", "kpi"),
                                 ...) {

  type <- match.arg(type)
  labels <- attr(x, "labels")

  # Exclude TOTAL row from plot
  df <- x[x$channel != "TOTAL", ]

  if (type == "spend") {
    col_a <- paste0("spend_", labels[1])
    col_b <- paste0("spend_", labels[2])
    current_col <- "current_spend"
    y_label <- "Weekly Spend ($)"
    title <- paste0("Spend Comparison: ", labels[1], " vs. ", labels[2])
    fmt <- scales::dollar_format()
  } else {
    col_a <- paste0("kpi_", labels[1])
    col_b <- paste0("kpi_", labels[2])
    current_col <- "current_kpi"
    y_label <- "Weekly KPI"
    title <- paste0("KPI Comparison: ", labels[1], " vs. ", labels[2])
    fmt <- scales::comma_format()
  }

  # Order by mean of A and B
  ch_order <- df$channel[order((df[[col_a]] + df[[col_b]]) / 2)]
  df$channel <- factor(df$channel, levels = ch_order)

  ggplot(df, aes(y = channel)) +
    # Current spend as faint reference
    geom_point(
      aes(x = .data[[current_col]]),
      shape = 124, size = 4, color = "grey60"
    ) +
    # Segment connecting A and B
    geom_segment(
      aes(x = .data[[col_a]], xend = .data[[col_b]],
          yend = channel),
      linewidth = 0.8, color = "grey50"
    ) +
    # Result A
    geom_point(aes(x = .data[[col_a]]),
               color = "firebrick", size = 3) +
    # Result B
    geom_point(aes(x = .data[[col_b]]),
               color = "steelblue", size = 3) +
    scale_x_continuous(labels = fmt) +
    labs(
      x = y_label,
      y = NULL,
      title = title,
      subtitle = paste0(
        "Red = ", labels[1], "  |  Blue = ", labels[2],
        "  |  Grey = current"
      )
    ) +
    theme_minimal()
}
