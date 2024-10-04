#' Clean French commune names
#'
#' @description
#' Clean a vector a character containing commune names in free text to INSEE format
#'
#' @param char A character vector containing commune names.
#' @param char A character vector containing CP numbers
#'
#' @return A character vector containing the commune names in the INSEE format
#' @export
#'
#' @importFrom stringr str_replace_all str_remove_all
#'
#' @examples
#' library(rUrgAra)
#' clean_commune(c("La tronche", "st-etienne", "Saint     Etienne", "Saint-étienne"))
clean_commune <- function(commune, CP = NULL){
  commune_propre = commune
  #Recodage général
  commune_propre = toupper(trimws(commune_propre))
  commune_propre = str_replace_all(commune_propre, "(?<![A-Z])ST[- ]", "SAINT ")
  commune_propre = str_replace_all(commune_propre, "(?<![A-Z])STE[- ]", "SAINTE ")
  commune_propre = str_replace_all(commune_propre, "(?<![A-Z])MT[- ]", "MONT ")
  commune_propre = str_replace_all(commune_propre, "\\/", " SUR ")
  commune_propre = str_replace_all(commune_propre, "S\\/", " SUR ")
  commune_propre = str_replace_all(commune_propre, "[\\'\\-\\`]", " ")
  commune_propre = str_replace_all(commune_propre, " {2,}", " ")
  commune_propre = str_remove_all(commune_propre, "[0-9]{3,}")
  commune_propre = str_remove_all(commune_propre, " CEDEX(?![A-Z])")
  commune_propre = str_replace_all(commune_propre,"[\u00c8\u00c9\u00ca\u00cb]", "E")
  commune_propre = str_replace_all(commune_propre,"[\u00d4\u00d6]", "O")
  commune_propre = str_replace_all(commune_propre,"[\u00c4\u00c2\u00c0]", "A")
  commune_propre = str_replace_all(commune_propre,"[\u00ce\u00cf]", "I")
  commune_propre = str_replace_all(commune_propre,"[\u00db\u00dc]", "U")
  commune_propre = str_replace_all(commune_propre,"[\u00c7]", "C")
  commune_propre = str_replace_all(commune_propre, "LYON0", "LYON 0")
  commune_propre = trimws(commune_propre)

  #Recodage à partir du CP
  if(!is.null(CP)){
    if(length(commune != length(CP))){stop("Commune et CP doivent faire la m\u00eame longueur")}
    commune_propre = if_else(CP %in% "69001", "LYON 01", commune_propre)
    commune_propre = if_else(CP %in% "69002", "LYON 02", commune_propre)
    commune_propre = if_else(CP %in% "69003", "LYON 03", commune_propre)
    commune_propre = if_else(CP %in% "69004", "LYON 04", commune_propre)
    commune_propre = if_else(CP %in% "69005", "LYON 05", commune_propre)
    commune_propre = if_else(CP %in% "69006", "LYON 06", commune_propre)
    commune_propre = if_else(CP %in% "69007", "LYON 07", commune_propre)
    commune_propre = if_else(CP %in% "69008", "LYON 08", commune_propre)
    commune_propre = if_else(CP %in% "69009", "LYON 09", commune_propre)
  }


  #Cas spécifiques
  commune_propre = str_replace_all(commune_propre, "LYON0$", "LYON")

  #return
  return(commune_propre)
}
