#' Remplacer le texte d'un élément SVG
#'
#' Remplace le contenu textuel d'un élément d'un document SVG identifié
#' par son attribut \code{id}.
#'
#' Cette fonction est destinée à renseigner dynamiquement un gabarit SVG,
#' par exemple avec le nom d'un établissement, une période ou la valeur
#' d'un indicateur.
#'
#' @param page_svg Document SVG lu avec [xml2::read_xml()].
#'
#' @param id Chaîne de caractères correspondant à l'attribut \code{id}
#'   de l'élément SVG dont le texte doit être remplacé.
#'
#' @param valeur Valeur à insérer dans l'élément SVG. Elle est convertie
#'   en chaîne de caractères avec [as.character()].
#'
#' @return Le document SVG modifié, sous la forme d'un objet XML.
#'
#' @details
#' L'élément est recherché avec une expression XPath portant sur son
#' attribut \code{id}.
#'
#' Si aucun élément correspondant n'est trouvé, la fonction génère une
#' erreur.
#'
#' La fonction modifie l'objet SVG puis le retourne. Elle n'écrit pas
#' automatiquement le résultat dans un fichier. Le document produit peut
#' être enregistré avec [xml2::write_xml()].
#'
#' @examples
#' \dontrun{
#' page_svg <- xml2::read_xml("gabarit.svg")
#'
#' page_svg <- svg_remplacer_texte(
#'   page_svg = page_svg,
#'   id = "nom_etablissement",
#'   valeur = "CH BELLEY"
#' )
#'
#' page_svg <- svg_remplacer_texte(
#'   page_svg = page_svg,
#'   id = "nombre_passages",
#'   valeur = 5490
#' )
#'
#' xml2::write_xml(
#'   page_svg,
#'   file = "rapport_CH_BELLEY.svg"
#' )
#' }
#'
#' @importFrom xml2 xml_find_first xml_text "xml_text<-"
#'
#' @seealso
#' [integrer_ggplot_svg()],
#' [xml2::read_xml()],
#' [xml2::write_xml()]
#'
#' @export
svg_remplacer_texte <- function(page_svg, id, valeur) {

  xpath <- sprintf("//*[@id=\'%s\']", id)

  noeud <- xml_find_first(page_svg, xpath)

  if (inherits(noeud, "xml_missing")) {
    stop(
      "Identifiant absent du gabarit SVG : ",
      id
    )
  }

  xml_text(noeud) <- as.character(valeur)

  return(page_svg)
}


#' Intégrer un graphique ggplot dans un document SVG
#'
#' Intègre un graphique \code{ggplot} dans une zone réservée d'un document
#' SVG. La zone est identifiée par son attribut \code{id} et doit posséder
#' les attributs \code{x}, \code{y}, \code{width} et \code{height}.
#'
#' Le graphique est enregistré temporairement au format SVG avec
#' \pkg{svglite}, puis son contenu vectoriel est copié dans le document SVG
#' principal.
#'
#' @param page_svg Document SVG lu avec [xml2::read_xml()].
#'
#' @param plot Objet graphique héritant de la classe \code{ggplot}.
#'
#' @param zone_id Chaîne de caractères correspondant à l'attribut \code{id}
#'   de la zone réservée au graphique dans le gabarit SVG.
#'
#'   Cette zone est généralement représentée par un rectangle créé dans
#'   Adobe Illustrator.
#'
#' @param graphique_id Identifiant attribué au nouvel élément SVG contenant
#'   le graphique. Par défaut, cet identifiant est construit en ajoutant
#'   le préfixe \code{"graph_"} à \code{zone_id}.
#'
#' @return Le document SVG modifié, sous la forme d'un objet XML.
#'
#' @details
#' La fonction réalise les opérations suivantes :
#'
#' \enumerate{
#'   \item recherche de la zone réservée grâce à son identifiant ;
#'   \item lecture de sa position et de ses dimensions ;
#'   \item génération temporaire du graphique au format SVG ;
#'   \item création d'un élément SVG imbriqué dans le document principal ;
#'   \item copie du contenu vectoriel du graphique ;
#'   \item suppression de la zone réservée initiale.
#' }
#'
#' La zone réservée doit posséder les quatre attributs suivants :
#'
#' \itemize{
#'   \item \code{x} ;
#'   \item \code{y} ;
#'   \item \code{width} ;
#'   \item \code{height}.
#' }
#'
#' Les dimensions de la zone sont utilisées en millimètres lors de la
#' génération du graphique avec [ggplot2::ggsave()].
#'
#' L'attribut SVG \code{preserveAspectRatio} est fixé à \code{"none"}.
#' Le graphique occupe donc exactement la largeur et la hauteur de la zone,
#' au prix d'une éventuelle déformation si son ratio initial diffère de
#' celui de la zone.
#'
#' La fonction ne crée pas directement de fichier de sortie. Le document
#' retourné doit être enregistré avec [xml2::write_xml()].
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#'
#' page_svg <- xml2::read_xml("gabarit.svg")
#'
#' graphique <- ggplot(
#'   data.frame(
#'     periode = c("Q1 2025", "Q1 2026"),
#'     passages = c(5100, 5490)
#'   ),
#'   aes(
#'     x = periode,
#'     y = passages
#'   )
#' ) +
#'   geom_col(fill = "#C8294A") +
#'   theme_minimal()
#'
#' page_svg <- integrer_ggplot_svg(
#'   page_svg = page_svg,
#'   plot = graphique,
#'   zone_id = "zone_graphique_activite"
#' )
#'
#' xml2::write_xml(
#'   page_svg,
#'   file = "rapport_CH_BELLEY.svg"
#' )
#' }
#'
#' @importFrom ggplot2 ggsave
#' @importFrom xml2 read_xml xml_add_child xml_add_sibling xml_attr xml_children
#' @importFrom xml2 xml_find_first xml_new_root xml_remove xml_root
#'
#' @seealso
#' [svg_remplacer_texte()],
#' [ggplot2::ggsave()],
#' [xml2::read_xml()],
#' [xml2::write_xml()]
#'
#' @export
integrer_ggplot_svg <- function(
    page_svg,
    plot,
    zone_id,
    graphique_id = paste0("graph_", zone_id)
) {

  # 1. Recherche de la zone dans le gabarit
  zone <- xml_find_first(
    page_svg,
    sprintf("//*[@id=\'%s\']", zone_id)
  )

  if (inherits(zone, "xml_missing")) {
    stop(
      "Zone SVG introuvable : ",
      zone_id
    )
  }

  # 2. Lecture des coordonnées
  x <- as.numeric(xml_attr(zone, "x"))
  y <- as.numeric(xml_attr(zone, "y"))

  largeur <- as.numeric(xml_attr(zone, "width"))
  hauteur <- as.numeric(xml_attr(zone, "height"))

  if (anyNA(c(x, y, largeur, hauteur))) {
    stop(
      "La zone doit poss\u00e9der les attributs ",
      "x, y, width et height."
    )
  }

  # 3. Création du ggplot en SVG
  fichier_plot <- tempfile(fileext = ".svg")

  ggsave(
    filename = fichier_plot,
    plot = plot,
    device = svglite::svglite,
    width = largeur,
    height = hauteur,
    units = "mm",
    bg = "transparent"
  )

  plot_svg <- read_xml(fichier_plot)
  plot_root <- xml_root(plot_svg)

  # 4. Lecture du viewBox du graphique
  viewbox <- xml_attr(plot_root, "viewBox")

  if (is.na(viewbox)) {
    stop(
      "Le SVG produit par svglite ne poss\u00e8de pas de viewBox."
    )
  }

  # 5. Création d'un SVG imbriqué dans la page
  graphique <- xml_new_root(
    "svg",
    id = graphique_id,
    x = as.character(x),
    y = as.character(y),
    width = as.character(largeur),
    height = as.character(hauteur),
    viewBox = viewbox,
    preserveAspectRatio = "none"
  )

  # 6. Copie du contenu du ggplot
  enfants <- xml_children(plot_root)

  for (enfant in enfants) {
    xml_add_child(
      graphique,
      enfant,
      .copy = TRUE
    )
  }

  # 7. Ajout du graphique après la zone
  xml_add_sibling(
    zone,
    graphique,
    .where = "after"
  )

  # 8. Suppression du rectangle repère
  xml_remove(zone)

  return(page_svg)
}
