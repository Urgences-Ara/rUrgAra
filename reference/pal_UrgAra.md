# UrgAra color palette

Returns a vector of colors of length n from UrgAra's color palette.

## Usage

``` r
pal_UrgAra(n = NULL, palette = "main")
```

## Arguments

- n:

  the number of colors to return

- palette:

  The name of the palette. For more information
  rUrgAra:::UrgAra_palettes

## Value

a vector

## Examples

``` r
library(rUrgAra)
library(ggplot2)
ggplot(mtcars, aes(mpg, wt)) +
  geom_point(aes(colour = factor(cyl))) +
  scale_colour_manual(values = pal_UrgAra())

```
