# Extract template from rUrgAra

Extract template from rUrgAra

## Usage

``` r
get_template(template_name, folder = ".")
```

## Arguments

- template_name:

  The template to import. Possible values are : report

- folder:

  Folder were the files corresponding to the template should be written.

## Examples

``` r
#DO NOT RUN
library(rUrgAra)
get_template(template_name = "report", folder = "src")
#> Warning: cannot create file 'src/empty_report.Rmd', reason 'No such file or directory'
#> Warning: cannot create file 'src/preamble_tex.tex', reason 'No such file or directory'
#> Warning: cannot create file 'src/logo_urgara_minimal.jpg', reason 'No such file or directory'
#> [1] "empty_report.Rmd, preamble_tex.tex and logo_urgara_minimal.jpg have been written in src"
#> [1] "empty_report assumes that preamble_tex is in the same folder. preamble_tex assumes that logo_urgara_minimal is in ../img"
#> [1] "Please, be aware that you need to modify those files or setup your project accordingly."
```
