# fct_calc_delay

Calcul les délais entre deux dates/heures dans une base et supprime les
valeurs hors délais

## Usage

``` r
fct_calc_delay(base, d1, d2, lower_bound, upper_bound, min_display)
```

## Arguments

- base:

  Table contenant les date/heure

- d1:

  Nom de premier date/heure

- d2:

  Nom de deuxieme date/heure

- lower_bound:

  Borne minimale du délais. Les valeurs inférieurs sont supprimées

- upper_bound:

  Borne maximale du délais. Les valeurs supérieurs sont supprimées

- min_display:

  Le nombre minimal de patient de délai valide pour afficher la médiane
  et l'interquartile. Remplacé par "X" sinon.

## Value

Une liste de 4 valeurs (lab_del/Q1_del/med_del/Q3_del)
