#' Add company logo to a plot
#'
#' @description Adds a company logo (by default Urg'Ara) to a plot. A custom logo can be used by specifying a path to the logo.
#' Optionally a data quality indicator can also be added
#'
#' @param plot A ggplot object
#' @param logo The path to an image file. If NULL, the Urg'Ara logo will be used instead
#' @param height The height of the logo in proportion of the graph (default 0.1)
#' @param width The width of the logo in proportion of the graph (default 0.2)
#' @param height_qual The height of the logo deplaying data quality in proportion of the graph (height/1.33)
#' @param width_qual The width of the logo in proportion of the graph (width/1.33)
#' @param position The position of the logo. Possible values are "bottom right", "bottom", "bottom left", "top right", "top", "top left".
#' @param remove.margin Should the margin of the plot be removed on the side of the logo for a more precise fit
#' @param add_quality Boolean : Should a data quality indicator be added to the plot ? The position is determined automatically
#' @param quality_lvl numeric : Exhaustivity of the data used in percent (between 0 and 100)
#' @param geometry_logo char : Argument geometry utilisé dans magick::image_resize. geometry = "200x" par défaut
#'
#' @return a ggplot2 object
#'
#' @export
#' @examples
#' library(rUrgAra)
#' library(ggplot2)
#' plot_cars = ggplot(cars, ggplot2::aes(x = speed, y = dist)) +
#'   geom_point() +
#'   ggpubr::theme_pubclean()
#'
#' plot_add_logo(plot_cars)#default
#' plot_add_logo(plot_cars, position = "top left")#logo at the top
#' plot_add_logo(plot_cars, width = 0.4)#wider logo
#' plot_add_logo(plot_cars, add_quality = TRUE, quality_lvl = 75)#information on data quality
plot_add_logo <- function(plot, logo = NULL,
                          height = 0.1, width = 0.2,
                          height_qual = height*3/4, width_qual = width*3/4,
                          position = c("bottom right", "bottom", "bottom left",
                                       "top right", "top", "top left"),
                          remove.margin = TRUE,
                          add_quality = FALSE, quality_lvl = NULL,
                          geometry_logo = "200x"
                          ){
  #type check
  if(!is.numeric(height) | !is.numeric(width) | !is.numeric(height_qual) | !is.numeric(width_qual)){
    stop("Height and width must be numerical")} else
      if(!dplyr::between(height, 0, 1) | !dplyr::between(width, 0, 1) |
         !dplyr::between(height_qual, 0, 1) | !dplyr::between(width_qual, 0, 1)){
        stop("Height and width must be between 0 and 1")
      }
  if(!is.character(position)){stop("position must be a character vector")} else
    if(!position[1] %in% c("bottom right", "bottom", "bottom left",
                           "top right", "top", "top left")){
      stop("Wrong value for position. Check the help page for a list of allowed values")
    }
  if(!ggplot2::is.ggplot(plot)) stop("plot must be a ggplot object")
  if(!is.null(logo)){
    if(!stringr::str_detect(logo, ".jpg$")) stop("Logo must point to a .jpg file")
    if(!file.exists(logo)) stop(paste0(logo, " does not exist"))
  }
  if(add_quality){
    if(is.null(quality_lvl)){stop("quality_lvl must be between 0 and 100")}
    if(!dplyr::between(quality_lvl, 0, 100)){stop("quality_lvl must be between 0 and 100")}
  }

  #removing margins of input plot
  if(remove.margin){
    if(grepl("^top", position[1])){
          plot = plot +
            ggplot2::theme(plot.margin = ggplot2::margin(t = 0))
    } else if(grepl("^bottom", position[1])){
          plot = plot +
            ggplot2::theme(plot.margin = ggplot2::margin(b = 0))
    }
  }

  #Extraction of the max height/width
  width_max = max(width, width_qual)
  height_max = max(height, height_qual)

  #loading of the logo
  if(is.null(logo)){logo = system.file("img/logo_urgara.jpg", package = "rUrgAra")}
  logo_img = magick::image_read(logo) %>%
    magick::image_resize(geometry_logo, filter = "Triangle") # Optionnel : filtre plus léger

  #resolution of position
  quality_offset = dplyr::if_else(add_quality, width_qual, 0)#offset used to leave room for the quality logo
  xy_logo = dplyr::case_when(
    position[1] == "bottom right" ~ c(1-width, height_max/2),
    position[1] == "bottom" ~ c(0.5 - ((width + quality_offset)/2) + quality_offset, height_max/2),
    position[1] == "bottom left" ~ c(0, height_max/2),
    position[1] == "top right" ~ c(1-width, 1-height_max/2),
    position[1] == "top" ~ c(0.5 - ((width + quality_offset)/2) + quality_offset, 1-height_max/2),#0.5-(width/2)-quality_offset
    position[1] == "top left" ~ c(0, 1-height_max/2)
  )
  #y coordinate of the plot (0 if logo at the top, 0+heigth if logo at the bottom)
  y_plot = dplyr::if_else(grepl("bottom", position[1]), 0 + height_max, 0)

  #adding logo image to the plot at designated coordinates
  plot_logoed = cowplot::ggdraw() +
    cowplot::draw_plot(plot, x = 0, y = y_plot, width = 1, height = 1-height) +
    cowplot::draw_image(logo_img, x = xy_logo[1], y = xy_logo[2], width = width, height = height, vjust = 0.5)

  #Adding the quality logo if add_quality
  if(add_quality){
    #Creation of the logo. image_graph is used to garanty the correct size of the text
    file_img_quality = paste0("img/iconQuality/iconQualData_", round(quality_lvl), ".png")
    img_qualite = magick::image_read(system.file(file_img_quality, package = "rUrgAra"))
    # img_qualite <- magick::image_graph(res = 1200, height = 300, width = 600)
    # print(fct_make_icon_qual(round(quality_lvl)))
    # grDevices::dev.off()

    xy_quality = dplyr::case_when(
      position[1] == "bottom right" ~ c(0, height_max/2),
      position[1] == "bottom" ~ c(0.5 - ((width + quality_offset)/2), height_max/2),
      position[1] == "bottom left" ~ c(1 - width_qual, height_max/2),
      position[1] == "top right" ~ c(0, 1 - height_max/2),
      position[1] == "top" ~ c(0.5 - ((width + quality_offset)/2), 1 - height_max/2),
      position[1] == "top left" ~ c(1-width/2, 1 - height_max/2)
    )

    plot_logoed = plot_logoed +
      cowplot::draw_image(img_qualite, x = xy_quality[1], y = xy_quality[2], width = width_qual, height = height_qual,
                          vjust = 0.5)
  }

  return(plot_logoed)
}


#' Icon qualité des données
#'
#' @param p Numeric entre 0 et 100 => Nombre à insérer au centre du cercle
#'
#' @returns un ggplot
#'
#' @import ggplot2
#' @importFrom grDevices colorRampPalette
#' @importFrom dplyr tibble
#' @importFrom grid roundrectGrob gpar unit
#'
fct_make_icon_qual <- function(p){
  if(!is.numeric(p)){stop("p doit etre numeric")}
  if(p < 0 | p > 100){stop("p doit etre compris entre 0 et 100")}
  # Créer une palette de couleurs allant du bleu au rouge
  paletteGenerator <- colorRampPalette(c("#A50026",
                                         "#D73027", "#F46D43", "#FDAE61",
                                         # "#FEE08B",
                                         # "#D9EF8B",
                                         "#A6D96A", "#66BD63", "#1A9850",
                                         "#006837"))
  palette = paletteGenerator(101)
  # Générer 10 couleurs intermédiaires
  p_round = round(p)
  bg_col = palette[p_round + 1]
  lab = paste0(round(p), "%")


  plot_icon = ggplot(tibble()) +
    annotation_custom(
      grob = roundrectGrob(x = 0, y = 0, width = 6, height = 3, r = unit(0.5, "npc"), gp = gpar(fill = bg_col, col = NA)),
      xmin = -0, xmax = 1, ymin = -0, ymax = 1
    ) +
    geom_text(aes(label = lab, x = 0, y = 0), color = "white", size = 3,
              fontface = "bold", hjust = 0.5, vjust = 0.5) +
    coord_cartesian(xlim = c(-3, 3), ylim = c(-2.5, 2.5)) +
    theme_void() +
    theme(
      panel.background = element_rect(fill = "transparent", colour = NA),
      plot.background = element_rect(fill = "transparent", colour = NA),
      legend.background = element_rect(fill = "transparent", colour = NA),
      legend.box.background = element_rect(fill = "transparent", colour = NA)
    )
  return(plot_icon)
}
