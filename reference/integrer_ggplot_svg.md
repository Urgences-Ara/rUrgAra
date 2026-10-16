# Intégrer un graphique ggplot dans un document SVG

Intègre un graphique `ggplot` dans une zone réservée d'un document SVG.
La zone est identifiée par son attribut `id` et doit posséder les
attributs `x`, `y`, `width` et `height`.

## Usage

``` r
integrer_ggplot_svg(
  page_svg,
  plot,
  zone_id,
  graphique_id = paste0("graph_", zone_id)
)
```

## Arguments

- page_svg:

  Document SVG lu avec
  [`xml2::read_xml()`](http://xml2.r-lib.org/reference/read_xml.md).

- plot:

  Objet graphique héritant de la classe `ggplot`.

- zone_id:

  Chaîne de caractères correspondant à l'attribut `id` de la zone
  réservée au graphique dans le gabarit SVG.

  Cette zone est généralement représentée par un rectangle créé dans
  Adobe Illustrator.

- graphique_id:

  Identifiant attribué au nouvel élément SVG contenant le graphique. Par
  défaut, cet identifiant est construit en ajoutant le préfixe
  `"graph_"` à `zone_id`.

## Value

Le document SVG modifié, sous la forme d'un objet XML.

## Details

ATTENTION : La fonction modifie directement l'arbre xml de "svg".
L'objet est modifié même sans réatribution. La fonction est utilisée
pour son effet de bord pas son retour.

Le graphique est enregistré temporairement au format SVG avec svglite,
puis son contenu vectoriel est copié dans le document SVG principal.

La fonction réalise les opérations suivantes :

1.  recherche de la zone réservée grâce à son identifiant ;

2.  lecture de sa position et de ses dimensions ;

3.  génération temporaire du graphique au format SVG ;

4.  création d'un élément SVG imbriqué dans le document principal ;

5.  copie du contenu vectoriel du graphique ;

6.  suppression de la zone réservée initiale.

La zone réservée doit posséder les quatre attributs suivants :

- `x` ;

- `y` ;

- `width` ;

- `height`.

Les dimensions de la zone sont utilisées en millimètres lors de la
génération du graphique avec
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html).

L'attribut SVG `preserveAspectRatio` est fixé à `"none"`. Le graphique
occupe donc exactement la largeur et la hauteur de la zone, au prix
d'une éventuelle déformation si son ratio initial diffère de celui de la
zone.

La fonction ne crée pas directement de fichier de sortie. Le document
retourné doit être enregistré avec
[`xml2::write_xml()`](http://xml2.r-lib.org/reference/write_xml.md).

## See also

[`svg_remplacer_texte()`](svg_remplacer_texte.md),
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html),
[`xml2::read_xml()`](http://xml2.r-lib.org/reference/read_xml.md),
[`xml2::write_xml()`](http://xml2.r-lib.org/reference/write_xml.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)

page_svg <- xml2::read_xml("gabarit.svg")

graphique <- ggplot(
  data.frame(
    periode = c("Q1 2025", "Q1 2026"),
    passages = c(5100, 5490)
  ),
  aes(
    x = periode,
    y = passages
  )
) +
  geom_col(fill = "#C8294A") +
  theme_minimal()

page_svg <- integrer_ggplot_svg(
  page_svg = page_svg,
  plot = graphique,
  zone_id = "zone_graphique_activite"
)

xml2::write_xml(
  page_svg,
  file = "rapport_CH_BELLEY.svg"
)
} # }
```
