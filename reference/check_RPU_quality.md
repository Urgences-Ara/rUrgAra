# Vérification de la qualité du RPU

Calcule par NOM_ETAB et COD_FIN le taux de remplissage et d'autres
informations de diagnostic de la qualité

## Usage

``` r
check_RPU_quality(
  tab,
  var_hospit = NULL,
  var_duree_passage = NULL,
  var_age = NULL
)
```

## Arguments

- tab:

  Un data.frame ou tibble contenant au minimum "NOM_ETAB" et "COD_FIN".

- var_hospit:

  Char. Nom de la variable contenant l'hospitalisation. La variable doit
  être logical

- var_duree_passage:

  Char. Nom de la variable contenant la durée du passage. La variable
  doit être numeric

- var_age:

  Char. Nom de la variable contenant l'age. La variable doit être
  numeric

## Value

liste d'information diagnostic

## Details

La fonction explore juste le taux de remplissage d'un tableau par
NOM_ETAB/COD_FIN. Le nettoyage de la base (valeurs autorisées) et le
calcul de variables composites est à réaliser en amont

## Examples

``` r
if (FALSE) { # \dontrun{
#quality_list = check_RPU_quality(RPU, var_hospit = "hospit",
#                                 var_duree_passage = "duree_passage",
#                                 var_age = "age")
#quality_list$n_etab#Nombre d'établissement dans l'export
#quality_list$tab_remplissage#taux de remplissage par variable par établissement
#quality_list$plot_hospit#Taux d'hospitalisation par établissement
#quality_list$plot_duree_passage#boxplot durée de passage par établissement
#quality_list$plot_age#boxplot age par établissement
} # }
```
