# uga_theme.R
# University of Georgia ggplot2 Theme and Color Palettes
# Consistent with BUSN 5000 course materials
#
# Usage:
#   source("uga_theme.R")
#   ggplot(data, aes(x, y)) +
#     geom_point() +
#     theme_uga() +
#     scale_color_uga("categorical")

library(ggplot2)
library(scales)

# =============================================================================
# COLOR DEFINITIONS
# =============================================================================

#' UGA Color Palette
#'
#' Named vector of official UGA colors
uga_colors <- c(
  # Primary

dawg_red       = "#BA0C2F",
  dawg_black     = "#000000",
  dawg_white     = "#FFFFFF",

  # Extended palette (from BUSN 5000)
  dawg_grey      = "#9EA2A2",
  lake_herrick   = "#00A3AD",
  olympic        = "#004E60",
  odyssey        = "#C8D8EB",
  creamery       = "#D6D2C4",

  # Legacy colors (for backward compatibility)
  bulldog_red    = "#BA0C2F",
  arch_black     = "#000000",
  chapel_white   = "#FFFFFF",
  glory_red      = "#E4002B",
  heritage_red   = "#8B0A1E",
  warm_gray      = "#6A6A6A",
  silver         = "#A7A9AC",
  cream          = "#F7F5F0",
  slate          = "#333333",

  # Additional grays for charts
  light_gray     = "#EEEEEE",
  mid_gray       = "#999999"
)

#' Get UGA color by name
#'
#' @param ... Color names from the UGA palette
#' @return Named character vector of hex codes
#' @examples
#' uga_col("dawg_red", "dawg_black")
#' uga_col("lake_herrick")
uga_col <- function(...) {
  cols <- c(...)
  if (is.null(cols)) {
    return(uga_colors)
  }
  uga_colors[cols]
}

# =============================================================================
# COLOR PALETTES
# =============================================================================

#' UGA Color Palettes
#'
#' Pre-defined palettes for different visualization needs
uga_palettes <- list(
  # Main categorical palette (up to 6 categories) - BUSN 5000 style
  categorical = c(
    uga_colors["dawg_red"],
    uga_colors["dawg_black"],
    uga_colors["dawg_grey"],
    uga_colors["lake_herrick"],
    uga_colors["olympic"],
    uga_colors["odyssey"]
  ),

  # Alternative categorical (softer)
  categorical_soft = c(
    uga_colors["dawg_red"],
    uga_colors["dawg_grey"],
    uga_colors["odyssey"],
    uga_colors["creamery"],
    uga_colors["lake_herrick"],
    uga_colors["mid_gray"]
  ),

  # Two-color palette for binary comparisons
  binary = c(
    uga_colors["dawg_red"],
    uga_colors["dawg_black"]
  ),

  # Sequential red (light to dark)
  sequential_red = c(
    "#FADBD8",
    "#F1948A",
    "#E74C3C",
    "#BA0C2F",
    "#8B0A1E",
    "#5D0614"
  ),

  # Sequential gray (light to dark)
  sequential_gray = c(
    "#F7F5F0",
    "#E0DEDA",
    "#C0BEBA",
    "#A7A9AC",
    "#6A6A6A",
    "#333333"
  ),

  # Sequential teal (light to dark)
  sequential_teal = c(
    "#C8D8EB",
    "#8CC4C8",
    "#4DB0B5",
    "#00A3AD",
    "#007A82",
    "#004E60"
  ),

  # Diverging (red to black through gray)
  diverging = c(
    "#BA0C2F",
    "#D4726A",
    "#EEEEEE",
    "#666666",
    "#000000"
  ),

  # Diverging (red to teal)
  diverging_teal = c(
    "#BA0C2F",
    "#D4726A",
    "#EEEEEE",
    "#5FB5B9",
    "#00A3AD"
  ),

  # Highlight palette (one accent, rest muted)
  highlight = c(
    uga_colors["dawg_red"],
    rep(uga_colors["dawg_grey"], 5)
  )
)

#' Get UGA Palette
#'
#' @param name Palette name
#' @param n Number of colors needed (optional)
#' @param type "discrete" or "continuous"
#' @return Vector of colors or color ramp function
uga_pal <- function(name = "categorical", n = NULL, type = "discrete") {
  pal <- uga_palettes[[name]]
  if (is.null(pal)) {
    stop(paste("Palette", name, "not found. Available palettes:",
               paste(names(uga_palettes), collapse = ", ")))
  }

  if (type == "continuous") {
    return(colorRampPalette(pal))
  }

  if (!is.null(n)) {
    if (n <= length(pal)) {
      return(pal[1:n])
    } else {
      warning(paste("Requested", n, "colors but palette has", length(pal),
                    ". Interpolating."))
      return(colorRampPalette(pal)(n))
    }
  }

  return(pal)
}

# =============================================================================
# GGPLOT2 SCALE FUNCTIONS
# =============================================================================

#' Discrete color scale using UGA palette
#'
#' @param palette Palette name from uga_palettes
#' @param ... Additional arguments passed to discrete_scale
#' @examples
#' ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
#'   geom_point() +
#'   scale_color_uga("categorical")
scale_color_uga <- function(palette = "categorical", ...) {
  pal <- uga_palettes[[palette]]
  discrete_scale("colour", "uga",
                 function(n) uga_pal(palette, n),
                 ...)
}

#' Alias for scale_color_uga
scale_colour_uga <- scale_color_uga

#' Discrete fill scale using UGA palette
#'
#' @param palette Palette name from uga_palettes
#' @param ... Additional arguments passed to discrete_scale
scale_fill_uga <- function(palette = "categorical", ...) {
  discrete_scale("fill", "uga",
                 function(n) uga_pal(palette, n),
                 ...)
}

#' Continuous color scale using UGA palette
#'
#' @param palette Palette name (should be sequential or diverging)
#' @param ... Additional arguments passed to scale_color_gradientn
scale_color_uga_c <- function(palette = "sequential_red", ...) {
  pal <- uga_palettes[[palette]]
  scale_color_gradientn(colours = pal, ...)
}

#' Alias for scale_color_uga_c
scale_colour_uga_c <- scale_color_uga_c

#' Continuous fill scale using UGA palette
#'
#' @param palette Palette name (should be sequential or diverging)
#' @param ... Additional arguments passed to scale_fill_gradientn
scale_fill_uga_c <- function(palette = "sequential_red", ...) {
  pal <- uga_palettes[[palette]]
  scale_fill_gradientn(colours = pal, ...)
}

# =============================================================================
# GGPLOT2 THEME
# =============================================================================

#' UGA ggplot2 Theme
#'
#' A clean, professional theme following UGA brand guidelines.
#' Consistent with BUSN 5000 course materials.
#'
#' @param base_size Base font size (default 15, matching BUSN 5000)
#' @param base_family Base font family (default "" uses system sans-serif)
#' @param base_line_size Base line size
#' @param base_rect_size Base rect size
#' @param grid Show grid lines? Options: "none", "x", "y", "both" (default "y")
#' @param axis_lines Show axis lines? Options: "none", "x", "y", "both" (default "both")
#'
#' @return A ggplot2 theme object
#'
#' @examples
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point(color = uga_col("dawg_red")) +
#'   theme_uga()
#'
#' # Minimal version without grid
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   theme_uga(grid = "none")
theme_uga <- function(
    base_size = 15,
    base_family = "",
    base_line_size = 0.5,
    base_rect_size = 0.5,
    grid = "y",
    axis_lines = "both"
) {

  # Start with minimal theme (consistent with BUSN 5000)
  ret <- theme_minimal(
    base_size = base_size,
    base_family = base_family,
    base_line_size = base_line_size,
    base_rect_size = base_rect_size
  )

  # Customize to match BUSN 5000 styling
  ret <- ret + theme(
    # Text elements
    text = element_text(
      color = uga_colors["dawg_black"],
      family = base_family
    ),

    # Plot title - size 20 matching BUSN 5000
    plot.title = element_text(
      size = 20,
      face = "bold",
      color = uga_colors["dawg_black"],
      hjust = 0,
      margin = margin(b = 10)
    ),

    # Plot subtitle
    plot.subtitle = element_text(
      size = rel(0.9),
      color = uga_colors["dawg_grey"],
      hjust = 0,
      margin = margin(b = 15)
    ),

    # Plot caption
    plot.caption = element_text(
      size = rel(0.7),
      color = uga_colors["dawg_grey"],
      hjust = 1,
      margin = margin(t = 10)
    ),

    # Axis titles - size 16 matching BUSN 5000
    axis.title = element_text(
      size = 16,
      color = uga_colors["slate"]
    ),
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 10)),

    # Axis text
    axis.text = element_text(
      size = rel(0.8),
      color = uga_colors["dawg_grey"]
    ),

    # Legend
    legend.title = element_text(
      size = rel(0.85),
      face = "bold",
      color = uga_colors["slate"]
    ),
    legend.text = element_text(
      size = rel(0.8),
      color = uga_colors["dawg_grey"]
    ),
    legend.position = "bottom",
    legend.key = element_blank(),
    legend.background = element_blank(),

    # Panel
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA),

    # Strip (facets)
    strip.text = element_text(
      size = rel(0.9),
      face = "bold",
      color = uga_colors["dawg_black"]
    ),
    strip.background = element_rect(
      fill = uga_colors["creamery"],
      color = NA
    ),

    # Margins
    plot.margin = margin(15, 15, 15, 15)
  )

  # Grid lines
  if (grid == "none") {
    ret <- ret + theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
    )
  } else if (grid == "x") {
    ret <- ret + theme(
      panel.grid.major.x = element_line(
        color = uga_colors["light_gray"],
        linewidth = 0.3
      ),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank()
    )
  } else if (grid == "y") {
    ret <- ret + theme(
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(
        color = uga_colors["light_gray"],
        linewidth = 0.3
      ),
      panel.grid.minor = element_blank()
    )
  } else {
    ret <- ret + theme(
      panel.grid.major = element_line(
        color = uga_colors["light_gray"],
        linewidth = 0.3
      ),
      panel.grid.minor = element_blank()
    )
  }

  # Axis lines
  if (axis_lines == "none") {
    ret <- ret + theme(
      axis.line = element_blank()
    )
  } else if (axis_lines == "x") {
    ret <- ret + theme(
      axis.line.x = element_line(
        color = uga_colors["slate"],
        linewidth = 0.4
      ),
      axis.line.y = element_blank()
    )
  } else if (axis_lines == "y") {
    ret <- ret + theme(
      axis.line.x = element_blank(),
      axis.line.y = element_line(
        color = uga_colors["slate"],
        linewidth = 0.4
      )
    )
  } else {
    ret <- ret + theme(
      axis.line = element_line(
        color = uga_colors["slate"],
        linewidth = 0.4
      )
    )
  }

  return(ret)
}

#' UGA Theme for Publications
#'
#' A more compact theme suitable for journal figures
#'
#' @param ... Arguments passed to theme_uga
theme_uga_pub <- function(...) {
  theme_uga(
    base_size = 10,
    grid = "none",
    axis_lines = "both",
    ...
  ) +
    theme(
      legend.position = "right",
      plot.margin = margin(5, 5, 5, 5)
    )
}

#' UGA Theme for Presentations
#'
#' Optimized for Beamer slides, matching BUSN 5000 styling
#'
#' @param ... Arguments passed to theme_uga
theme_uga_present <- function(...) {
  theme_uga(
    base_size = 15,
    grid = "y",
    axis_lines = "x",
    ...
  ) +
    theme(
      legend.position = "bottom",
      plot.title = element_text(size = 20),
      axis.title = element_text(size = 16),
      plot.margin = margin(10, 10, 10, 10)
    )
}

#' UGA Theme for PDF Documents
#'
#' Optimized for reports, white papers, and formal PDF documents.
#' More compact than theme_uga_present(), with smaller fonts suitable for print.
#' Matches the styling in pdf/uga-doc.tex with red titles.
#'
#' @param ... Arguments passed to theme_uga
#' @examples
#' # Set as default for entire document
#' theme_set(theme_uga_doc())
#'
#' # Or use per-plot
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   theme_uga_doc()
theme_uga_doc <- function(...) {
  theme_uga(
    base_size = 11,
    grid = "y",
    axis_lines = "both",
    ...
  ) +
    theme(
      # Red titles to match document section headers
      plot.title = element_text(
        size = 14,
        face = "bold",
        color = uga_colors["dawg_red"],
        margin = margin(b = 8)
      ),
      plot.subtitle = element_text(
        size = 11,
        color = uga_colors["dawg_grey"],
        margin = margin(b = 10)
      ),
      # Compact sizing for print
      axis.title = element_text(size = 10),
      axis.text = element_text(size = 9),
      legend.position = "bottom",
      legend.text = element_text(size = 9),
      legend.title = element_text(size = 10),
      plot.margin = margin(10, 10, 10, 10)
    )
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

#' Show UGA Color Palette
#'
#' Displays all colors in a palette as a plot
#'
#' @param palette Name of palette to display (default: all)
show_uga_palette <- function(palette = NULL) {
  if (is.null(palette)) {
    # Show all palettes
    all_pals <- names(uga_palettes)
    par(mfrow = c(ceiling(length(all_pals) / 2), 2), mar = c(1, 1, 2, 1))

    for (pal_name in all_pals) {
      pal <- uga_palettes[[pal_name]]
      n <- length(pal)
      image(1:n, 1, as.matrix(1:n), col = pal,
            xlab = "", ylab = "", xaxt = "n", yaxt = "n",
            main = pal_name)
    }
    par(mfrow = c(1, 1), mar = c(5.1, 4.1, 4.1, 2.1))
  } else {
    pal <- uga_palettes[[palette]]
    n <- length(pal)

    df <- data.frame(
      x = 1:n,
      y = 1,
      color = pal
    )

    ggplot(df, aes(x, y, fill = factor(x))) +
      geom_tile(width = 0.9, height = 0.5) +
      scale_fill_manual(values = pal) +
      labs(title = paste("UGA Palette:", palette)) +
      theme_void() +
      theme(
        legend.position = "none",
        plot.title = element_text(hjust = 0.5, face = "bold", size = 14)
      ) +
      geom_text(aes(label = color), vjust = 2, size = 3)
  }
}

#' Show all UGA colors
#'
#' Creates a reference plot of all defined colors
show_uga_colors <- function() {
  # Filter out duplicate aliases
  unique_colors <- uga_colors[!duplicated(uga_colors)]

  df <- data.frame(
    name = names(unique_colors),
    hex = unname(unique_colors),
    y = rev(seq_along(unique_colors))
  )

  ggplot(df, aes(x = 1, y = y, fill = hex)) +
    geom_tile(width = 3, height = 0.8) +
    geom_text(aes(x = 2.8, label = name), hjust = 0, size = 4) +
    geom_text(aes(x = -0.3, label = hex), hjust = 1, size = 3.5,
              color = "gray40") +
    scale_fill_identity() +
    coord_cartesian(xlim = c(-1.5, 5)) +
    labs(title = "UGA Color Palette Reference") +
    theme_void() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 16,
                                margin = margin(b = 20))
    )
}

# =============================================================================
# PRINT CONFIRMATION
# =============================================================================

message("UGA theme loaded successfully!")
message("Available themes: theme_uga(), theme_uga_pub(), theme_uga_present(), theme_uga_doc()")
message("Available scales: scale_color_uga(), scale_fill_uga(), scale_color_uga_c(), scale_fill_uga_c()")
message("Available palettes: ", paste(names(uga_palettes), collapse = ", "))
