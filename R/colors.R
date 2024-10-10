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
  `UrgAraGrey` = "#999999",
  `UrgAraDarkGrey` = "#767171",
  `UrgAraDarkGreen` = "#548235",
  `UrgAraBrown` = "#843C0C",
  `UrgAraDeepPurple` = "#893BC3",
  `UrgAraCyan` = "#00FFCC"
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
                       "UrgAraOrange", "UrgAraYellow", "UrgAraPurple",
                       "UrgAraPink", "UrgAraGrey", "UrgAraDarkGreen", "UrgAraBrown",
                       "UrgAraDeepPurple", "UrgAraCyan", "UrgAraDarkGrey"),
  `duo` = UrgAra_cols("UrgAraBlue", "UrgAraRed")
)

#' UrgAra color palette
#'
#' @description
#' Returns a vector of colors of length n from UrgAra's color palette.
#'
#'
#' @param n the number of colors to return
#' @param palette The name of the palette. For more information rUrgAra:::UrgAra_palettes
#'
#' @return a vector
#' @export
#'
#' @examples
#' library(rUrgAra)
#' library(ggplot2)
#' ggplot(mtcars, aes(mpg, wt)) +
#'   geom_point(aes(colour = factor(cyl))) +
#'   scale_colour_manual(values = pal_UrgAra())
#'
pal_UrgAra <- function(n = NULL, palette = "main"){
  #extraction of the color palette
  col_pal <- UrgAra_palettes[[palette]] %>% unlist %>% unname

  #check
  if(is.null(col_pal)){stop(paste0("The color palette ", palette, " is not a valid rUrgAra palette. ",
                                   "Available palettes are : ", paste(names(UrgAra_palettes), collapse = ", ")))}

  #first n values
  if(!is.null(n)){
    if(n < 0 | n > length(col_pal) | n %% 1 != 0){stop(paste0("n must be a positive interger lower than ", length(col_pal) + 1))}
    col_pal <- col_pal[seq_len(n)]
  }

  return(col_pal)
  }


