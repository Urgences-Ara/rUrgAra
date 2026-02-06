# FINESS code cleaning

Adds the leading "0" to FINESS codes if it contains only 8 caracters
instead of 9.

## Usage

``` r
clean_FINESS(char)
```

## Arguments

- char:

  A character vector containing FINESS codes with missing leading "0".
  Each code should be 8 or 9 characters.

## Value

A character vector containing the FINESS code with a leading "0" when
needed

## Examples

``` r
library(rUrgAra)
clean_FINESS(c("10784320", "380000174"))
#> [1] "010784320" "380000174"
```
