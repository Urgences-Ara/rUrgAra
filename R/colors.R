#' UrgAra_colors
#'
#' List of colors used by UrgAra
#'
#' @format A list
UrgAra_colors <- list(
  `UrgAraBlue` = "#125486",
  `UrgAraRed` = "#e91b1d",
  `UrgAraBlue2` = "#1c6fad",
  `UrgAraRed2` = "#e34041",
  `UrgAraGreen` = "#aecf38",
  `UrgAraLightBlue` = "#93CDDD",
  `UrgAraOrange` = "#eb9846",
  `UrgAraYellow` = "#FFFF33",
  `UrgAraPurple` = "#d084db",
  `UrgAraPink` = "#F781BF",
  `UrgAraGrey` = "#999999"
  )


#' Extract any color from UrgAra globale palette
#'
#' @description Extract any color from UrgAra globale palette
#'
#' @param ... name of the colors to extract from a palette
#'
#' @return a vector of named HEX colors
#'
#' @export
UrgAra_cols <- function(...) {
  cols <- c(...)

  if (is.null(cols))
    return (UrgAra_colors)

  UrgAra_colors[cols]
}


#' UrgAra_palettes
#'
#' List of colors palettes using UrgAra's colors
#'
#' @format A list

UrgAra_palettes <- list(
  `main` = UrgAra_cols("UrgAraBlue2", "UrgAraRed2", "UrgAraGreen", "UrgAraLightBlue",
                       "UrgAraOrange", "UrgAraYellow", "UrgAraBrown",  "UrgAraPurple",
                       "UrgAraPink", "UrgAraGrey"),
  `duo` = UrgAra_cols("UrgAraBlue", "UrgAraRed")
)


#' Return function to interpolate an UrgAra color palette
#'
#' @param palette Character name of palette in UrgAra_palettes
#' @param reverse Boolean indicating whether the palette should be reversed
#' @param ... Additional arguments to pass to colorRampPalette()
#'
UrgAra_pal <- function(palette = "main", reverse = FALSE, ...) {
  pal <- UrgAra_palettes[[palette]]

  if (reverse) pal <- rev(pal)

  # grDevices::colorRampPalette(pal)(3)
  fun = function(n){
    vec_pal = unlist(pal[seq_len(n)])
    names(vec_pal) <- NULL
    return(vec_pal)
  }
  return(fun)
}


#' Color scale constructor for UrgAra colors
#'
#' @param palette Character name of palette in UrgAra_palettes
#' @param discrete Boolean indicating whether color aesthetic is discrete or not
#' @param reverse Boolean indicating whether the palette should be reversed
#' @param ... Additional arguments passed to discrete_scale() or
#'            scale_color_gradientn(), used respectively when discrete is TRUE or FALSE
#'
#' @export
scale_color_UrgAra <- function(palette = "main", discrete = TRUE, reverse = FALSE, ...) {
  pal <- UrgAra_pal(palette = palette, reverse = reverse)

  if (discrete) {
    ggplot2::discrete_scale("colour", paste0("UrgAra_", palette), palette = pal, ...)
  } else {
    ggplot2::scale_color_gradientn(colours = pal(256), ...)
  }
}

#' Fill scale constructor for drsimonj colors
#'
#' @param palette Character name of palette in UrgAra_palettes (main or duo)
#' @param discrete Boolean indicating whether color aesthetic is discrete or not
#' @param reverse Boolean indicating whether the palette should be reversed
#' @param ... Additional arguments passed to discrete_scale() or
#'            scale_fill_gradientn(), used respectively when discrete is TRUE or FALSE
#'
#' @export
scale_fill_UrgAra <- function(palette = "main", discrete = TRUE, reverse = FALSE, ...) {
  pal <- UrgAra_pal(palette = palette, reverse = reverse)

  if (discrete) {
    ggplot2::discrete_scale("fill", paste0("UrgAra_", palette), palette = pal, ...)
  } else {
    ggplot2::scale_fill_gradientn(colours = pal(256), ...)
  }
}
