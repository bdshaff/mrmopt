# ============================================================
# mrmopt hex sticker
# Requires: hexSticker, magick, ggplot2, mrmopt, dplyr
# Run once from the package root with the session models loaded.
# install.packages(c("hexSticker", "magick")) if needed.
#
# Session prerequisites:
#   - mrms_df must be loaded (tibble of per-channel model fits)
#     Columns: channel, curve_type, model
#   - Channels needed: paid_search__nonbrand, paid_social, youtube
#   - Curve types used: logistic, gompertz, reflected_weibull
# ============================================================

library(hexSticker)
library(magick)
library(ggplot2)
library(dplyr)
library(purrr)

# --- Color palette ---
bg_col     <- "#F5EDD8"   # oatmeal
border_col <- "#8B2500"   # brick red
curve1_col <- "#8B2500"   # brick red       — primary (reflected_weibull)
curve2_col <- "#D45C00"   # burnt orange    — mid     (gompertz)
curve3_col <- "#C8895A"   # warm terracotta — faint   (logistic)

# --- Pull three real-fit curves from session models ---
ch_a <- mrms_df |> filter(channel == "paid_search__nonbrand", curve_type == "logistic")          |> pull(model) |> pluck(1)
ch_b <- mrms_df |> filter(channel == "paid_social",           curve_type == "gompertz")          |> pull(model) |> pluck(1)
ch_c <- mrms_df |> filter(channel == "youtube",               curve_type == "reflected_weibull") |> pull(model) |> pluck(1)

norm_curve <- function(mrm, crop = 0.85) {
  rdf   <- mrm$response_df
  x_col <- names(rdf)[1]
  x     <- rdf[[x_col]]
  y     <- rdf$center
  df    <- data.frame(xn = x / max(x), yn = y / max(y))
  df[df$xn <= crop, ]
}

make_ribbon <- function(df, half_width = 0.04) {
  data.frame(
    xn    = df$xn,
    yn_lo = pmax(df$yn - half_width, 0),
    yn_hi = pmin(df$yn + half_width, 1.5)
  )
}

get_points <- function(df, xn_vals) {
  data.frame(
    xn = xn_vals,
    yn = approx(df$xn, df$yn, xout = xn_vals)$y
  )
}

df_a <- norm_curve(ch_a)
df_b <- norm_curve(ch_b)
df_c <- norm_curve(ch_c)

rib_a <- make_ribbon(df_a, 0.032)
rib_b <- make_ribbon(df_b, 0.038)
rib_c <- make_ribbon(df_c, 0.044)

pts_xn <- c(0.18, 0.42, 0.68)
pts_a  <- get_points(df_a, pts_xn)
pts_b  <- get_points(df_b, pts_xn)
pts_c  <- get_points(df_c, pts_xn)

# --- Build subplot ---
p <- ggplot() +
  geom_ribbon(data = rib_a, aes(x = xn, ymin = yn_lo, ymax = yn_hi),
              fill = curve3_col, alpha = 0.20) +
  geom_ribbon(data = rib_b, aes(x = xn, ymin = yn_lo, ymax = yn_hi),
              fill = curve2_col, alpha = 0.24) +
  geom_ribbon(data = rib_c, aes(x = xn, ymin = yn_lo, ymax = yn_hi),
              fill = curve1_col, alpha = 0.28) +
  geom_line(data = df_a, aes(x = xn, y = yn),
            color = curve3_col, linewidth = 0.9, alpha = 0.65) +
  geom_line(data = df_b, aes(x = xn, y = yn),
            color = curve2_col, linewidth = 1.1, alpha = 0.82) +
  geom_line(data = df_c, aes(x = xn, y = yn),
            color = curve1_col, linewidth = 1.7, alpha = 1.0) +
  geom_point(data = pts_a, aes(x = xn, y = yn),
             color = bg_col, fill = curve3_col, shape = 21,
             size = 1.5, stroke = 0.7) +
  geom_point(data = pts_b, aes(x = xn, y = yn),
             color = bg_col, fill = curve2_col, shape = 21,
             size = 1.8, stroke = 0.8) +
  geom_point(data = pts_c, aes(x = xn, y = yn),
             color = bg_col, fill = curve1_col, shape = 21,
             size = 2.2, stroke = 0.9) +
  scale_x_continuous(expand = c(0.02, 0)) +
  scale_y_continuous(expand = c(0.02, 0)) +
  theme_void() +
  theme(
    panel.background = element_rect(fill = "transparent", color = NA),
    plot.background  = element_rect(fill = "transparent", color = NA)
  )

# --- Render sticker ---
dir.create("man/figures", showWarnings = FALSE, recursive = TRUE)

sticker(
  subplot    = p,
  package    = "mrmopt",
  p_size     = 0.001,
  p_color    = bg_col,
  p_y        = 1.52,
  s_x        = 1.02,
  s_y        = 0.82,
  s_width    = 1.25,
  s_height   = 0.85,
  h_fill     = bg_col,
  h_color    = border_col,
  h_size     = 1.6,
  spotlight  = FALSE,
  filename   = "man/figures/logo.png",
  dpi        = 600
)

# Add text via magick using Outfit (modern Google Font via showtext/sysfonts)
# Render base without text first, then annotate
library(showtext)
library(sysfonts)
font_add_google("Outfit", "outfit")
showtext_auto()

image_read("man/figures/logo.png") |>
  # "ROAI MARKETING" — small, along the top-left hex border edge
  image_annotate(
    "ROAI MARKETING",
    gravity   = "NorthWest",
    location  = "+155+455",
    degrees   = -56,
    size      = 34,
    font      = "Outfit",
    color     = border_col,
    weight    = 500,
    kerning   = 3
  ) |>
  # "mrmopt" — bold, centered at the bottom
  image_annotate(
    "mrmopt",
    gravity   = "South",
    location  = "+0+110",
    size      = 130,
    font      = "Outfit",
    color     = border_col,
    weight    = 700
  ) |>
  image_write("man/figures/logo.png")

message("Logo saved to man/figures/logo.png")
