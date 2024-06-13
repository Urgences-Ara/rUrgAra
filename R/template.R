#' Extract template from rUrgAra
#'
#' @param template_name The template to import. Possible values are : report
#' @param folder Folder were the files corresponding to the template should be written.
#'
#' @return NULL
#' @export
#'
#' @examples
#' #DO NOT RUN
#' library(rUrgAra)
#' get_template(template_name = "report", folder = "src")
get_template <- function(template_name, folder = "."){
  if(template_name == "report"){
    file.copy(from = system.file("rstudio/templates/files/empty_report.Rmd", package = "rUrgAra"),
              to = paste0(folder, "/empty_report.Rmd"),
              overwrite = FALSE)
    file.copy(from = system.file("rstudio/templates/files/preamble_tex.tex", package = "rUrgAra"),
              to = paste0(folder, "/preamble_tex.tex"),
              overwrite = FALSE)
    file.copy(from = paste0(path.package("rUrgAra"), "/rstudio/templates/files/logo_urgara_minimal.jpg"),
              to = paste0(folder, "/logo_urgara_minimal.jpg"),
              overwrite = FALSE)
    print(paste0("empty_report.Rmd, preamble_tex.tex and logo_urgara_minimal.jpg have been written in ", folder))
    print("empty_report assumes that preamble_tex is in the same folder. preamble_tex assumes that logo_urgara_minimal is in ../img")
    print("Please, be aware that you need to modify those files or setup your project accordingly.")
    return(invisible(NULL))
  }
  stop("Unknown template name")
}
