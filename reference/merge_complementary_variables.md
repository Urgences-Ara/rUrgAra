# Merge complementary variables

Merges multiple variables that are mutually exclusive into a single
variables. Use either a complete list of variables to merge or the
prefix of variables to merge or both.

## Usage

``` r
merge_complementary_variables(
  data,
  var = NULL,
  prefix = NULL,
  exclude = NULL,
  info = TRUE
)
```

## Arguments

- data:

  A data.frame or tibble containing variables to merge

- var:

  char vector containing the name of variables to merge in data

- prefix:

  char vector containing the prefix. Every column in data starting with
  the prefix will be merged

- exclude:

  char vector of variables to exclude from the merge

- info:

  Boolean to print or not the merged variables and number of NA in the
  console

## Value

A variable containing merged values from each column

## Examples

``` r
if (FALSE) { # \dontrun{
library(rUrgAra)
data = data.frame(
ID = 1:40,
nom_etab01 = c(rep(NA, 30), sample(LETTERS[1:10], 10, replace = TRUE)),
nom_etab03 = c(rep(NA, 20), sample(LETTERS[1:10], 10, replace = TRUE), rep(NA, 10)),
nom_etab_dechocage = c(rep(NA, 10), sample(LETTERS[1:10], 10, replace = TRUE), rep(NA, 20)),
nom_des_etab_du38 =  c(sample(LETTERS[1:10], 10, replace = TRUE), rep(NA, 30)),
age =  sample(75:95, 40, replace = T)
)

data$etab = merge_complementary_variables(data, prefix = "nom_etab", var = "nom_des_etab_du38",
                                          exclude = "nom_etab_dechocage", info = TRUE)
data
} # }
```
