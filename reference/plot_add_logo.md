# Add company logo to a plot

Adds a company logo (by default Urg'Ara) to a plot. A custom logo can be
used by specifying a path to the logo. Optionally a data quality
indicator can also be added

## Usage

``` r
plot_add_logo(
  plot,
  logo = NULL,
  height = 0.1,
  width = 0.2,
  height_qual = height * 3/4,
  width_qual = width * 3/4,
  position = c("bottom right", "bottom", "bottom left", "top right", "top", "top left"),
  remove.margin = TRUE,
  add_quality = FALSE,
  quality_lvl = NULL,
  geometry_logo = "200x"
)
```

## Arguments

- plot:

  A ggplot object

- logo:

  The path to an image file. If NULL, the Urg'Ara logo will be used
  instead

- height:

  The height of the logo in proportion of the graph (default 0.1)

- width:

  The width of the logo in proportion of the graph (default 0.2)

- height_qual:

  The height of the logo deplaying data quality in proportion of the
  graph (height/1.33)

- width_qual:

  The width of the logo in proportion of the graph (width/1.33)

- position:

  The position of the logo. Possible values are "bottom right",
  "bottom", "bottom left", "top right", "top", "top left".

- remove.margin:

  Should the margin of the plot be removed on the side of the logo for a
  more precise fit

- add_quality:

  Boolean : Should a data quality indicator be added to the plot ? The
  position is determined automatically

- quality_lvl:

  numeric : Exhaustivity of the data used in percent (between 0 and 100)

- geometry_logo:

  char : Argument geometry utilisé dans magick::image_resize. geometry =
  "200x" par défaut

## Value

a ggplot2 object

## Examples

``` r
library(rUrgAra)
library(ggplot2)
plot_cars = ggplot(cars, ggplot2::aes(x = speed, y = dist)) +
  geom_point() +
  ggpubr::theme_pubclean()

plot_add_logo(plot_cars)#default

plot_add_logo(plot_cars, position = "top left")#logo at the top

plot_add_logo(plot_cars, width = 0.4)#wider logo

plot_add_logo(plot_cars, add_quality = TRUE, quality_lvl = 75)#information on data quality
```
