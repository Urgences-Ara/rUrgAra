#cahier charge :
# - Charge sa propre page
# - Gérer ses couleurs et polices mais valeurs par defaut ok
# - Ne pas casser l'environnement

#' Page de garde UrgAra
#'
#' @description
#' Facilite l'insertion d'une page de garde au format UrgAra dans un rapport Rmarkdown. ATTENTION : La police utilisée ne fonctionne que dans un environnement utilisant showtext::showtext_auto
#'
#' @details
#' Les paramètres de la page de garde sont anticipés pour une insertion
#' dans un Rmarkdown sur une page sans marge en A4
#' (`fig.width = 8.3`, `fig.height = 11.7`).
#' Les valeurs par défaut des colonnes de tab labels sont :
#' \itemize{
#'   \item \code{x} : 102 (le bord droit du texte)
#'   \item \code{y} : Espacement égal allant de y = 25 à y = 5
#'   \item \code{color} : white
#'   \item \code{fontface} : bold
#'   \item \code{fontfamily} : CO_bold (cocogoose). Cette valeur nécessite d'utiliser activate_showtext_auto pour s'afficher correctement
#'   \item \code{size} : 15
#' }
#' Ces valeurs sont projetés sur une fenetre graphique allant de 0 à 100 sur les deux axes
#'
#'
#' @param img_path character : chemin vers la page de garde au format png ou jpg
#' @param tab_labels data.frame ou tibble : Tableau contenant une ligne par ligne de texte à afficher sur la page de garde et au minimum une colonnes "labels". Les colonnes "x", "y", "color", "fontfamily", "fontface" et "size" pouvent être définies mais disposent de valeurs pas défaut si omises
#' @param activate_showtext_auto Booléen : Utilisation de showtext::showtext_auto pour afficher des polices personnalisées. Attention si oui, l'environnement global du projet sera modifié.
#'
#' @returns un plot
#' @export
#'
#' @import ggplot2
#' @importFrom png readPNG
#' @importFrom jpeg readJPEG
#' @importFrom ggpubr background_image
#' @importFrom sysfonts font_add
#' @importFrom showtext showtext_auto
#'
#' @examples
#' library(rUrgAra)
#' tab_labels = tibble::tibble(
#' labels = c("Rapports TRAUMA", "Quadrimestriel", "Q1 2025",
#'            stringr::str_wrap("Hopital de Chambery Urgences Pédiatriques", width = 30)),
#' color = c("white", "white", "white", "blue"),
#' size  = c(25, 22, 22, 18)
#' )
#' img_path = system.file("img/exemple_page_garde.png", package = "rUrgAra")
#' make_pageGarde(img_path = img_path, tab_labels = tab_labels, activate_showtext_auto = TRUE)
#'
make_pageGarde <- function(img_path, tab_labels, activate_showtext_auto = FALSE){
  #vérifications
  if(!any(names(tab_labels) %in% "labels") | !is.data.frame(tab_labels)) stop('tab_labels doit \u00eatre un data.frame ou tibble contenant au moins une colonne \"labels\"')
  if (!file.exists(img_path)) {
    stop(sprintf("Le fichier \'%s\' n\'existe pas.", img_path), call. = FALSE)
  }

  #Chargement du fond de la page de garde
  ext <- tolower(tools::file_ext(img_path))
  formats_autorises <- c("jpg", "jpeg", "png")
  if (ext %in% c("jpg", "jpeg")) {
    img <- readJPEG(img_path)
  } else if(ext %in% "png"){
    img <- readPNG(img_path)
  } else stop("Format d\'image non reconnu, le format de l\'image doit \u00eatre jpg, jpeg ou png.")

  # Chargement de la police d'écriture
  font_path <- system.file("fonts", "Co_Bold.otf", package = "rUrgAra")
  font_add("CO_bold", font_path)
  if(activate_showtext_auto){showtext_auto()}

  #Gestion des valeurs par défaut si non définies
  nb_lignes = nrow(tab_labels)
  if(!any(names(tab_labels) %in% "x")){
    tab_labels$x = 102
  }
  if(!any(names(tab_labels) %in% "y")){
    tab_labels$y <- seq(25, 5, length.out = nb_lignes)
  }
  if(!any(names(tab_labels) %in% "color")){
    tab_labels$color = c("white")
  }
  if(!any(names(tab_labels) %in% "fontface")){
    tab_labels$fontface = "bold"
  }
  if(!any(names(tab_labels) %in% "fontfamily")){
    tab_labels$fontfamily = "CO_bold"
  }
  if(!any(names(tab_labels) %in% "size")){
    tab_labels$size = 15
  }

  #Alerte si police nécessite showtext_auto
  if(any(tab_labels %in% "CO_bold") & !activate_showtext_auto) warning("La police utilis\u00e9e n\u00e9cessite activate_showtext_auto = TRUE pour s\'afficher correctement.")

  #Génération de la page de garde
  pageGarde = ggplot(tab_labels) +
    background_image(img) +
    geom_text(aes(label = labels, x = x, y = y), hjust = 1, vjust = 1,
              color = tab_labels$color, fontface = tab_labels$fontface,
              family = tab_labels$fontfamily, size = tab_labels$size) +
    coord_cartesian(xlim = c(0, 100), ylim = c(0,100)) +
    theme_void()
  return(pageGarde)
}

