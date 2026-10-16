# Remplacer le texte d'un élément SVG

Remplace le contenu d'un élément texte SVG. Les valeurs multilignes sont
réparties dans plusieurs éléments `tspan`.

## Usage

``` r
svg_remplacer_texte(
  svg,
  id,
  valeur,
  interligne = "1.2em",
  id_zone_centrage = NULL
)
```

## Arguments

- svg:

  Document SVG lu avec
  [`xml2::read_xml()`](http://xml2.r-lib.org/reference/read_xml.md).

- id:

  Identifiant de l'élément texte à remplacer.

- valeur:

  Valeur à insérer. Un vecteur est interprété comme plusieurs lignes.
  Les retours à la ligne `"\n"` sont également traités.

- interligne:

  Décalage vertical entre deux lignes. La valeur par défaut, `"1.2em"`,
  correspond à 120 % de la taille de police.

- id_zone_centrage:

  Identifiant facultatif de l'objet sur lequel le texte doit être centré
  horizontalement. L'objet peut être un cercle, une ellipse ou un
  rectangle.

  Si `NULL`, la position horizontale existante est conservée.

## Value

Le document SVG modifié, retourné invisiblement. Le document fourni dans
`svg` est également modifié directement.

## Details

ATTENTION : La fonction modifie directement l'arbre xml de "svg".
L'objet est modifié même sans réatribution. La fonction est utilisée
pour son effet de bord pas son retour.

## Examples

``` r
if (FALSE) { # \dontrun{
svg_remplacer_texte(
  svg = page_svg,
  id = "txt_nb_passages_sous_pop",
  valeur = c("14 538", "(58,4 %)"),
  id_zone_centrage = "zone_txt_nb_passages_sous_pop"
)
} # }
```
