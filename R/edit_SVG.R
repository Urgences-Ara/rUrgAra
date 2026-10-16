#' Remplacer le texte d'un élément SVG
#'
#' Remplace le contenu d'un élément texte SVG. Les valeurs multilignes sont
#' réparties dans plusieurs éléments \code{tspan}.
#'
#' ATTENTION : La fonction modifie directement l'arbre xml de "svg". L'objet est modifié même
#' sans réatribution. La fonction est utilisée pour son effet de bord pas son retour.
#'
#' @param svg Document SVG lu avec [xml2::read_xml()].
#'
#' @param id Identifiant de l'élément texte à remplacer.
#'
#' @param valeur Valeur à insérer. Un vecteur est interprété comme plusieurs
#'   lignes. Les retours à la ligne \code{"\\n"} sont également traités.
#'
#' @param interligne Décalage vertical entre deux lignes. La valeur par défaut,
#'   \code{"1.2em"}, correspond à 120 % de la taille de police.
#'
#' @param id_zone_centrage Identifiant facultatif de l'objet sur lequel le
#'   texte doit être centré horizontalement. L'objet peut être un cercle, une
#'   ellipse ou un rectangle.
#'
#'   Si \code{NULL}, la position horizontale existante est conservée.
#'
#' @return Le document SVG modifié, retourné invisiblement. Le document fourni
#'   dans \code{svg} est également modifié directement.
#'
#' @examples
#' \dontrun{
#' svg_remplacer_texte(
#'   svg = page_svg,
#'   id = "txt_nb_passages_sous_pop",
#'   valeur = c("14 538", "(58,4 %)"),
#'   id_zone_centrage = "zone_txt_nb_passages_sous_pop"
#' )
#' }
#'
#' @export
svg_remplacer_texte <- function(
    svg,
    id,
    valeur,
    interligne = "1.2em",
    id_zone_centrage = NULL
) {

  # Recherche du texte à modifier
  noeud <- xml2::xml_find_first(
    svg,
    sprintf("//*[@id=\'%s\']", id)
  )

  if (inherits(noeud, "xml_missing")) {
    stop(
      "Identifiant absent du gabarit SVG : ",
      id,
      call. = FALSE
    )
  }

  # Un vecteur est considéré comme une série de lignes.
  # Les retours à la ligne sont également traités.
  lignes <- unlist(
    strsplit(
      as.character(valeur),
      split = "\n",
      fixed = TRUE
    ),
    use.names = FALSE
  )

  if (length(lignes) == 0L) {
    lignes <- ""
  }

  # Recherche des tspan existants
  tspans <- xml2::xml_find_all(
    noeud,
    ".//*[local-name()=\'tspan\']"
  )

  # Conservation de la position verticale initiale
  if (length(tspans) > 0L) {

    y_initial <- xml2::xml_attr(
      tspans[[1L]],
      "y"
    )

  } else {

    y_initial <- xml2::xml_attr(
      noeud,
      "y"
    )
  }

  if (is.na(y_initial) || y_initial == "") {
    y_initial <- "0"
  }

  # Position horizontale existante par défaut
  if (length(tspans) > 0L) {

    x <- xml2::xml_attr(
      tspans[[1L]],
      "x"
    )

  } else {

    x <- xml2::xml_attr(
      noeud,
      "x"
    )
  }

  if (is.na(x) || x == "") {
    x <- "0"
  }

  # Centrage éventuel sur un objet de référence
  if (!is.null(id_zone_centrage)) {

    zone <- xml2::xml_find_first(
      svg,
      sprintf(
        "//*[@id=\'%s\']",
        id_zone_centrage
      )
    )

    if (inherits(zone, "xml_missing")) {
      stop(
        "Zone de centrage absente du gabarit SVG : ",
        id_zone_centrage,
        call. = FALSE
      )
    }

    type_zone <- xml2::xml_name(zone)

    x_centre <- switch(
      type_zone,

      circle = as.numeric(
        xml2::xml_attr(zone, "cx")
      ),

      ellipse = as.numeric(
        xml2::xml_attr(zone, "cx")
      ),

      rect = {
        x_zone <- as.numeric(
          xml2::xml_attr(zone, "x")
        )

        largeur_zone <- as.numeric(
          xml2::xml_attr(zone, "width")
        )

        x_zone + largeur_zone / 2
      },

      stop(
        "La zone de centrage doit \u00eatre un cercle, ",
        "une ellipse ou un rectangle. Type rencontr\u00e9 : ",
        type_zone,
        ".",
        call. = FALSE
      )
    )

    if (is.na(x_centre)) {
      stop(
        "Impossible de d\u00e9terminer le centre horizontal de la zone `",
        id_zone_centrage,
        "`.",
        call. = FALSE
      )
    }

    # Lecture du transform existant
    transformation <- xml2::xml_attr(
      noeud,
      "transform"
    )

    # Cas fréquent produit par Illustrator :
    # transform="translate(x y)"
    motif_translate <- paste0(
      "^translate\\(",
      "\\s*[-+0-9.eE]+",
      "[ ,]+",
      "([-+0-9.eE]+)",
      "\\s*\\)$"
    )

    if (
      !is.na(transformation) &&
      grepl(motif_translate, transformation)
    ) {

      y_translate <- sub(
        motif_translate,
        "\\1",
        transformation
      )

      xml2::xml_attr(
        noeud,
        "transform"
      ) <- sprintf(
        "translate(%s %s)",
        x_centre,
        y_translate
      )

      # Les tspan sont positionnés par rapport au translate
      x <- "0"

    } else {

      # En l'absence de translate, la coordonnée est absolue
      x <- as.character(x_centre)
    }

    # Centrage dynamique du texte autour de x
    xml2::xml_attr(
      noeud,
      "text-anchor"
    ) <- "middle"
  }

  # Suppression des anciens tspan
  if (length(tspans) > 0L) {
    xml2::xml_remove(tspans)
  }

  # Suppression des éventuels textes directement contenus dans le nœud
  noeuds_texte <- xml2::xml_find_all(
    noeud,
    "./text()[normalize-space()]"
  )

  if (length(noeuds_texte) > 0L) {
    xml2::xml_remove(noeuds_texte)
  }

  # Création d'un tspan par ligne
  for (i in seq_along(lignes)) {

    nouveau_tspan <- xml2::xml_add_child(
      noeud,
      "tspan",
      lignes[[i]]
    )

    xml2::xml_attr(
      nouveau_tspan,
      "x"
    ) <- x

    if (i == 1L) {

      xml2::xml_attr(
        nouveau_tspan,
        "y"
      ) <- y_initial

    } else {

      xml2::xml_attr(
        nouveau_tspan,
        "dy"
      ) <- interligne
    }
  }

  invisible(svg)
}


#' Intégrer un graphique ggplot dans un document SVG
#'
#' Intègre un graphique \code{ggplot} dans une zone réservée d'un document
#' SVG. La zone est identifiée par son attribut \code{id} et doit posséder
#' les attributs \code{x}, \code{y}, \code{width} et \code{height}.
#'
#' ATTENTION : La fonction modifie directement l'arbre xml de "svg". L'objet est modifié même
#' sans réatribution. La fonction est utilisée pour son effet de bord pas son retour.
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

  invisible(page_svg)
}





#' Lister les zones dynamiques d'un gabarit SVG
#'
#' Recherche dans un document SVG les éléments dont l'identifiant commence
#' par un préfixe associé aux zones de texte ou aux zones graphiques.
#'
#' Cette fonction permet notamment de vérifier rapidement les identifiants
#' disponibles dans un gabarit SVG avant de remplacer les textes avec
#' [svg_remplacer_texte()] ou d'intégrer des graphiques avec
#' [integrer_ggplot_svg()].
#'
#' @param svg Document SVG lu avec [xml2::read_xml()].
#'
#' @param prefixe_texte Chaîne de caractères correspondant au préfixe utilisé
#'   pour identifier les zones de texte. La valeur par défaut est
#'   \code{"txt_"}.
#'
#' @param prefixe_plot Chaîne de caractères correspondant au préfixe utilisé
#'   pour identifier les zones réservées aux graphiques. La valeur par défaut
#'   est \code{"plot_"}.
#'
#' @return Un tibble comportant une ligne par zone trouvée et les colonnes
#'   suivantes :
#'
#' \describe{
#'   \item{\code{type}}{Type de zone : \code{"texte"} ou \code{"plot"}.}
#'   \item{\code{id}}{Identifiant SVG de la zone.}
#'   \item{\code{noeud}}{Nom du nœud SVG, par exemple \code{"text"},
#'   \code{"rect"} ou \code{"g"}.}
#'   \item{\code{contenu}}{Contenu textuel de l'élément. Cette colonne est
#'   principalement utile pour les zones de texte.}
#'   \item{\code{x}}{Coordonnée horizontale de l'élément, si disponible.}
#'   \item{\code{y}}{Coordonnée verticale de l'élément, si disponible.}
#'   \item{\code{width}}{Largeur de l'élément, si disponible.}
#'   \item{\code{height}}{Hauteur de l'élément, si disponible.}
#' }
#'
#' @details
#' La recherche porte sur tous les éléments possédant un attribut
#' \code{id}. Le type de zone est déterminé uniquement à partir du préfixe
#' de cet identifiant.
#'
#' Par exemple :
#'
#' \itemize{
#'   \item \code{txt_nb_passages} est classé comme zone de texte ;
#'   \item \code{plot_diagramme_charge} est classé comme zone graphique.
#' }
#'
#' Les colonnes de coordonnées correspondent aux attributs directement
#' présents sur l'élément identifié. Si l'identifiant est porté par un groupe
#' \code{<g>} plutôt que par le rectangle ou le texte lui-même, ces
#' coordonnées peuvent être absentes.
#'
#' @examples
#' \dontrun{
#' # À partir d'un fichier SVG
#' zones <- lister_zones_svg(
#'   svg = "gabarit.svg"
#' )
#'
#' zones
#'
#' # À partir d'un objet XML déjà chargé
#' page_svg <- xml2::read_xml("gabarit.svg")
#'
#' zones <- lister_zones_svg(
#'   svg = page_svg,
#'   prefixe_texte = "label_",
#'   prefixe_plot = "graphique_"
#' )
#'
#' # Lister uniquement les identifiants des textes
#' zones$id[zones$type == "texte"]
#'
#' # Lister uniquement les zones graphiques
#' subset(zones, type == "plot")
#' }
#'
#' @seealso
#' [svg_remplacer_texte()],
#' [integrer_ggplot_svg()],
#' [xml2::read_xml()]
#'
#' @importFrom xml2 read_xml
#' @importFrom xml2 xml_attr
#' @importFrom xml2 xml_find_all
#' @importFrom xml2 xml_name
#' @importFrom xml2 xml_text
#' @importFrom tibble tibble
#'
#' @export
lister_zones_svg <- function(
    svg,
    prefixe_texte = "txt_",
    prefixe_plot = "plot_"
) {

  # Contrôle des préfixes
  if (
    !is.character(prefixe_texte) ||
    length(prefixe_texte) != 1L ||
    is.na(prefixe_texte)
  ) {
    stop(
      "`prefixe_texte` doit \u00eatre une cha\u00eene de caract\u00e8res de longueur 1.",
      call. = FALSE
    )
  }

  if (
    !is.character(prefixe_plot) ||
    length(prefixe_plot) != 1L ||
    is.na(prefixe_plot)
  ) {
    stop(
      "`prefixe_plot` doit \u00eatre une cha\u00eene de caract\u00e8res de longueur 1.",
      call. = FALSE
    )
  }

  if (identical(prefixe_texte, prefixe_plot)) {
    stop(
      "Les pr\u00e9fixes des textes et des graphiques doivent \u00eatre diff\u00e9rents.",
      call. = FALSE
    )
  }

  # Recherche de tous les éléments possédant un ID
  noeuds <- xml2::xml_find_all(
    svg,
    "//*[@id]"
  )

  if (length(noeuds) == 0L) {
    return(
      tibble::tibble(
        type = character(),
        id = character(),
        noeud = character(),
        contenu = character(),
        x = character(),
        y = character(),
        width = character(),
        height = character()
      )
    )
  }

  ids <- xml2::xml_attr(noeuds, "id")

  est_texte <- startsWith(
    ids,
    prefixe_texte
  )

  est_plot <- startsWith(
    ids,
    prefixe_plot
  )

  noeuds <- noeuds[est_texte | est_plot]
  ids <- ids[est_texte | est_plot]
  est_texte <- est_texte[est_texte | est_plot]

  # Aucun identifiant correspondant aux préfixes
  if (length(noeuds) == 0L) {
    return(
      tibble::tibble(
        type = character(),
        id = character(),
        noeud = character(),
        contenu = character(),
        x = character(),
        y = character(),
        width = character(),
        height = character()
      )
    )
  }

  resultat <- tibble::tibble(
    type = ifelse(
      est_texte,
      "texte",
      "plot"
    ),
    id = ids,
    noeud = vapply(
      noeuds,
      xml2::xml_name,
      FUN.VALUE = character(1)
    ),
    contenu = trimws(
      vapply(
        noeuds,
        xml2::xml_text,
        FUN.VALUE = character(1)
      )
    ),
    x = xml2::xml_attr(noeuds, "x"),
    y = xml2::xml_attr(noeuds, "y"),
    width = xml2::xml_attr(noeuds, "width"),
    height = xml2::xml_attr(noeuds, "height")
  )

  # Classement : textes, graphiques, puis identifiants
  return(resultat[
    order(
      match(resultat$type, c("texte", "plot")),
      resultat$id
    ),
  ])
}






