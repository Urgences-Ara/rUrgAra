# Remplacer le texte d'un élément SVG

Remplace le contenu textuel d'un élément d'un document SVG identifié par
son attribut `id`.

## Usage

``` r
svg_remplacer_texte(page_svg, id, valeur)
```

## Arguments

- page_svg:

  Document SVG lu avec
  [`xml2::read_xml()`](http://xml2.r-lib.org/reference/read_xml.md).

- id:

  Chaîne de caractères correspondant à l'attribut `id` de l'élément SVG
  dont le texte doit être remplacé.

- valeur:

  Valeur à insérer dans l'élément SVG. Elle est convertie en chaîne de
  caractères avec
  [`as.character()`](https://rdrr.io/r/base/character.html).

## Value

Le document SVG modifié, sous la forme d'un objet XML.

## Details

Cette fonction est destinée à renseigner dynamiquement un gabarit SVG,
par exemple avec le nom d'un établissement, une période ou la valeur
d'un indicateur.

L'élément est recherché avec une expression XPath portant sur son
attribut `id`.

Si aucun élément correspondant n'est trouvé, la fonction génère une
erreur.

La fonction modifie l'objet SVG puis le retourne. Elle n'écrit pas
automatiquement le résultat dans un fichier. Le document produit peut
être enregistré avec
[`xml2::write_xml()`](http://xml2.r-lib.org/reference/write_xml.md).

## See also

[`integrer_ggplot_svg()`](integrer_ggplot_svg.md),
[`xml2::read_xml()`](http://xml2.r-lib.org/reference/read_xml.md),
[`xml2::write_xml()`](http://xml2.r-lib.org/reference/write_xml.md)

## Examples

``` r
if (FALSE) { # \dontrun{
page_svg <- xml2::read_xml("gabarit.svg")

page_svg <- svg_remplacer_texte(
  page_svg = page_svg,
  id = "nom_etablissement",
  valeur = "CH BELLEY"
)

page_svg <- svg_remplacer_texte(
  page_svg = page_svg,
  id = "nombre_passages",
  valeur = 5490
)

xml2::write_xml(
  page_svg,
  file = "rapport_CH_BELLEY.svg"
)
} # }
```
