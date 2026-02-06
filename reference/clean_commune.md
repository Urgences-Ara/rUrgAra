# Clean French commune names

Clean a vector a character containing commune names in free text to
INSEE format

## Usage

``` r
clean_commune(commune, CP = NULL, info = TRUE)
```

## Arguments

- commune:

  char A character vector containing commune names.

- CP:

  char A character vector containing CP numbers

- info:

  Boolean to print or not the number of recoded values

## Value

A character vector containing the commune names in the INSEE format

## Examples

``` r
library(rUrgAra)
clean_commune(c("La tronche", "st-etienne", "Saint     Étienne", "Saint-étienne"))
#> 4 communes ont été recodées
#> [1] "LA TRONCHE"    "SAINT ETIENNE" "SAINT ETIENNE" "SAINT ETIENNE"
```
