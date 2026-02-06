# format_p_value

Mets en forme une p-value en format texte.

## Usage

``` r
format_p_value(p, digits = 3, decimal.mark = ".")
```

## Arguments

- p:

  numeric ou vecteur de numeric contenant des p-valeur (0 à 1)

- digits:

  numeric : Nombre de chiffres après la vircule

- decimal.mark:

  character : Séparateur des décimales

## Value

character ou vecteur de characters

## Examples

``` r
library(rUrgAra)
format_p_value(NA_real_)
#> [1] "p = NA"
format_p_value(1)
#> [1] "p = 1"
format_p_value(0.52, decimal.mark = ",")
#> [1] "p = 0,52"
format_p_value(0.01)
#> [1] "p = 0.01"
format_p_value(0.001)
#> [1] "p = 0.001"
format_p_value(0.0001)
#> [1] "p < 0.001"
format_p_value(0.0001, digits = 4)
#> [1] "p = 0.0001"
format_p_value(0.00001)
#> [1] "p < 0.001"
format_p_value(0)
#> [1] "p < 0.001"
format_p_value(c(seq(0, 0.1, by = 0.005), 0.5, 1, NA))
#>  [1] "p < 0.001" "p = 0.005" "p = 0.010" "p = 0.015" "p = 0.020" "p = 0.025"
#>  [7] "p = 0.030" "p = 0.035" "p = 0.040" "p = 0.045" "p = 0.050" "p = 0.055"
#> [13] "p = 0.060" "p = 0.065" "p = 0.070" "p = 0.075" "p = 0.080" "p = 0.085"
#> [19] "p = 0.090" "p = 0.095" "p = 0.100" "p = 0.50"  "p = 1"     "p = NA"   
format_p_value(c(seq(0, 0.1, by = 0.005), 0.5, 1, NA), digits = 2)
#>  [1] "p < 0.01" "p < 0.01" "p = 0.01" "p = 0.01" "p = 0.02" "p = 0.03"
#>  [7] "p = 0.03" "p = 0.04" "p = 0.04" "p = 0.04" "p = 0.05" "p = 0.06"
#> [13] "p = 0.06" "p = 0.06" "p = 0.07" "p = 0.07" "p = 0.08" "p = 0.09"
#> [19] "p = 0.09" "p = 0.10" "p = 0.10" "p = 0.50" "p = 1"    "p = NA"  
format_p_value(c(seq(0, 0.1, by = 0.005), 0.5, 1, NA), digits = 4)
#>  [1] "p < 0.0001" "p = 0.005"  "p = 0.010"  "p = 0.015"  "p = 0.020" 
#>  [6] "p = 0.025"  "p = 0.030"  "p = 0.035"  "p = 0.040"  "p = 0.045" 
#> [11] "p = 0.050"  "p = 0.055"  "p = 0.060"  "p = 0.065"  "p = 0.070" 
#> [16] "p = 0.075"  "p = 0.080"  "p = 0.085"  "p = 0.090"  "p = 0.095" 
#> [21] "p = 0.100"  "p = 0.50"   "p = 1"      "p = NA"    
```
