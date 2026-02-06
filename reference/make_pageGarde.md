# Page de garde UrgAra

Facilite l'insertion d'une page de garde au format UrgAra dans un
rapport Rmarkdown. ATTENTION : La police utilisée ne fonctionne que dans
un environnement utilisant showtext::showtext_auto

## Usage

``` r
make_pageGarde(img_path, tab_labels, activate_showtext_auto = FALSE)
```

## Arguments

- img_path:

  character : chemin vers la page de garde au format png ou jpg

- tab_labels:

  data.frame ou tibble : Tableau contenant une ligne par ligne de texte
  à afficher sur la page de garde et au minimum une colonnes "labels".
  Les colonnes "x", "y", "color", "fontfamily", "fontface" et "size"
  pouvent être définies mais disposent de valeurs pas défaut si omises

- activate_showtext_auto:

  Booléen : Utilisation de showtext::showtext_auto pour afficher des
  polices personnalisées. Attention si oui, l'environnement global du
  projet sera modifié.

## Value

un plot

## Details

Les paramètres de la page de garde sont anticipés pour une insertion
dans un Rmarkdown sur une page sans marge en A4 (`fig.width = 8.3`,
`fig.height = 11.7`). Les valeurs par défaut des colonnes de tab labels
sont :

- `x` : 102 (le bord droit du texte)

- `y` : Espacement égal allant de y = 25 à y = 5

- `color` : white

- `fontface` : bold

- `fontfamily` : CO_bold (cocogoose). Cette valeur nécessite d'utiliser
  activate_showtext_auto pour s'afficher correctement

- `size` : 15

Ces valeurs sont projetés sur une fenetre graphique allant de 0 à 100
sur les deux axes

## Examples

``` r
library(rUrgAra)
tab_labels = tibble::tibble(
labels = c("Rapports TRAUMA", "Quadrimestriel", "Q1 2025",
           stringr::str_wrap("Hopital de Chambery Urgences Pédiatriques", width = 30)),
color = c("white", "white", "white", "blue"),
size  = c(25, 22, 22, 18)
)
img_path = system.file("img/exemple_page_garde.png", package = "rUrgAra")
make_pageGarde(img_path = img_path, tab_labels = tab_labels, activate_showtext_auto = TRUE)
#> Warning: libpng warning: iCCP: known incorrect sRGB profile

```
