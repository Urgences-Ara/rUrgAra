# Controle values in a variable

Controle values in a variable

## Usage

``` r
fct_format_control(var, val_autor, lab, replacement = "NC")
```

## Arguments

- var:

  Variable to check

- val_autor:

  Vector of authorized values

- lab:

  The name of the variable (only used to print the number of removed
  values)

- replacement:

  Value to replace "Non conform" modalities with. "NC" is used by
  default.

## Value

A vector with NA left as NA and values outside of "val_autor"
transformed into "NC" (Not conform)

## Examples

``` r
var = c(NA, LETTERS[1:5])
fct_format_control(var, val_autor = c("A", "C", "F"), lab = "lettres")
#> Warning: 3 formats corrigés pour la variable lettres
#> [1] NA   "A"  "NC" "C"  "NC" "NC"
```
