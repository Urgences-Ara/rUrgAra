create_project <- function(path, ...){
  # Collecting inputs from "..."
  dots = list(...)
  # ensure path exists
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

  # Create project directory skeleton
  dir.create(paste0(path, "/documents"), recursive = FALSE, showWarnings = FALSE)
  dir.create(paste0(path, "/img"), recursive = FALSE, showWarnings = FALSE)
  dir.create(paste0(path, "/src"), recursive = FALSE, showWarnings = FALSE)
  dir.create(paste0(path, "/resultats"), recursive = FALSE, showWarnings = FALSE)
  dir.create(paste0(path, "/donnees"), recursive = FALSE, showWarnings = FALSE)

  if(dots$project_type == "Report"){
    file.copy(from = paste0(path.package("rUrgAra"), "/rstudio/templates/files/preamble_tex.tex"),
              to = paste0(path, "/src/preamble_tex.tex"))
    file.copy(from = paste0(path.package("rUrgAra"), "/rstudio/templates/files/empty_report.rmd"),
              to = paste0(path, "/src/report.rmd"))
    file.copy(from = paste0(path.package("rUrgAra"), "/rstudio/templates/files/logo_urgara_minimal.jpg"),
              to = paste0(path, "/img/logo_urgara_minimal.jpg"))
  }

}
