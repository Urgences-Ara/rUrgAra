# Lister les zones dynamiques d'un gabarit SVG

Recherche dans un document SVG les éléments dont l'identifiant commence
par un préfixe associé aux zones de texte ou aux zones graphiques.

## Usage

``` r
svg_lister_zones(svg, prefixe_texte = "txt_", prefixe_plot = "plot_")
```

## Arguments

- svg:

  Document SVG lu avec
  [`xml2::read_xml()`](http://xml2.r-lib.org/reference/read_xml.md).

- prefixe_texte:

  Chaîne de caractères correspondant au préfixe utilisé pour identifier
  les zones de texte. La valeur par défaut est `"txt_"`.

- prefixe_plot:

  Chaîne de caractères correspondant au préfixe utilisé pour identifier
  les zones réservées aux graphiques. La valeur par défaut est
  `"plot_"`.

## Value

Un tibble comportant une ligne par zone trouvée et les colonnes
suivantes :

- `type`:

  Type de zone : `"texte"` ou `"plot"`.

- `id`:

  Identifiant SVG de la zone.

- `noeud`:

  Nom du nœud SVG, par exemple `"text"`, `"rect"` ou `"g"`.

- `contenu`:

  Contenu textuel de l'élément. Cette colonne est principalement utile
  pour les zones de texte.

- `x`:

  Coordonnée horizontale de l'élément, si disponible.

- `y`:

  Coordonnée verticale de l'élément, si disponible.

- `width`:

  Largeur de l'élément, si disponible.

- `height`:

  Hauteur de l'élément, si disponible.

## Details

Cette fonction permet notamment de vérifier rapidement les identifiants
disponibles dans un gabarit SVG avant de remplacer les textes avec
[`svg_remplacer_texte()`](svg_remplacer_texte.md) ou d'intégrer des
graphiques avec [`svg_integrer_ggplot()`](svg_integrer_ggplot.md).

La recherche porte sur tous les éléments possédant un attribut `id`. Le
type de zone est déterminé uniquement à partir du préfixe de cet
identifiant.

Par exemple :

- `txt_nb_passages` est classé comme zone de texte ;

- `plot_diagramme_charge` est classé comme zone graphique.

Les colonnes de coordonnées correspondent aux attributs directement
présents sur l'élément identifié. Si l'identifiant est porté par un
groupe `<g>` plutôt que par le rectangle ou le texte lui-même, ces
coordonnées peuvent être absentes.

## See also

[`svg_remplacer_texte()`](svg_remplacer_texte.md),
[`svg_integrer_ggplot()`](svg_integrer_ggplot.md),
[`xml2::read_xml()`](http://xml2.r-lib.org/reference/read_xml.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# À partir d'un fichier SVG
zones <- svg_lister_zones(
  svg = "gabarit.svg"
)

zones

# À partir d'un objet XML déjà chargé
page_svg <- xml2::read_xml("gabarit.svg")

zones <- svg_lister_zones(
  svg = page_svg,
  prefixe_texte = "label_",
  prefixe_plot = "graphique_"
)

# Lister uniquement les identifiants des textes
zones$id[zones$type == "texte"]

# Lister uniquement les zones graphiques
subset(zones, type == "plot")
} # }
```
