# Convertir une durée (en minutes) en étiquette lisible (jours/heures/minutes)

Formate un vecteur de durées en minutes en libellés lisibles à la
française, avec une précision au choix : jours seuls, jours+heures
(heures arrondies), ou heures:minutes (zéro‑remplies).

## Usage

``` r
fct_convert_time_labels(
  d_min,
  precision = "mins",
  sep_j = "j",
  sep_h = "h",
  sep_min = "",
  silent = FALSE,
  rounding = "round"
)
```

## Arguments

- d_min:

  `numeric` ou `integer` (vectorisé). Durée(s) en minutes à convertir.
  Doit être **finie** (pas de `NA`, `Inf`).

- precision:

  `character(1)` ; l'une de `"mins"` (défaut), `"hours"`, `"days"`.

- sep_j:

  `character(1)` ; séparateur/suffixe pour les jours (défaut `"j"`).

- sep_h:

  `character(1)` ; séparateur/suffixe pour les heures (défaut `"h"`).

- sep_min:

  `character(1)` ; séparateur/suffixe pour les minutes (défaut `""`).

- silent:

  `logical(1)` ; Permet de contrôler l'émission d'un avertissement lors
  de la conversion des valeurs négatives en `NA`.

- rounding:

  `character(1)` ; stratégie d'arrondi pour les modes `"days"` et
  `"hours"`. L'une de `"round"` (défaut), `"floor"`, `"ceiling"`.

## Value

Un vecteur `character` de même longueur que `d_min` contenant les
étiquettes formatées.

## Details

- **Validation** : `d_min` doit être numérique et **fini** (`NA`/`Inf`
  non autorisés).

- **Négatifs** : les valeurs **négatives** sont converties en `NA` (sans
  avertissement à ce jour).

- **Précision** :

  - `precision = "days"` : renvoie uniquement le nombre de jours selon
    `rounding`, concaténé à `sep_j`.

  - `precision = "hours"` : renvoie le nombre de jours (si \> 0) suivi
    des **heures arrondies** selon `rounding` et `sep_h`.

  - `precision = "mins"` (défaut) : renvoie `HHhMM` avec
    **zéro‑remplissage** (`sprintf("%02d")`), précédé du nombre de jours
    si \> 0.

Les séparateurs `sep_j`, `sep_h` et `sep_min` permettent de
personnaliser le rendu (par ex. `" j "`, `" h "`, `" min"`).

## Comportements notables

- La fonction est vectorisée sur `d_min`.

- En mode `"hours"`, **les heures** issues du reliquat de minutes sont
  arrondies via `rounding`; en mode `"mins"`, on **zéro‑remplit** `HH`
  et `MM` sans arrondir les minutes.

- Les valeurs négatives deviennent `NA` dans la sortie.

## See also

sprintf(), base::ifelse(), round(), floor(), ceiling()

## Examples

``` r
# Heures:minutes (zéro-remplissage), avec jours si nécessaire
fct_convert_time_labels(c(65764, NA, 138, 28, 1440, 654), "mins")          # "00h00"
#> [1] "45j16h04" NA         "02h18"    "00h28"    "1j00h00"  "10h54"   

# Jours + heures (arrondies) selon la stratégie
fct_convert_time_labels(c(65764, NA, 138, 28, 1440, 654), "hours", rounding = "round")   # "2h"
#> [1] "45j16h" NA       "2h"     "0h"     "1j0h"   "11h"   
fct_convert_time_labels(c(65764, NA, 138, 28, 1440, 654), "hours", rounding = "floor")   # "1h"
#> [1] "45j16h" NA       "2h"     "0h"     "1j0h"   "10h"   
fct_convert_time_labels(c(65764, NA, 138, 28, 1440, 654), "hours", rounding = "ceiling") # "2h"
#> [1] "45j17h" NA       "3h"     "1h"     "1j0h"   "11h"   

# Négatifs -> NA
fct_convert_time_labels(c(45, -1, 61), "mins")
#> Warning: 1 délais sont négatifs et ont été supprimés
#> [1] "00h45" NA      "01h01"
```
