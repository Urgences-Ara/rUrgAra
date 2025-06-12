#' format_p_value
#'
#' Mets en forme une p-value en format texte.
#'
#' @param p numeric ou vecteur de numeric contenant des p-valeur (0 à 1)
#' @param digits numeric : Nombre de chiffres après la vircule
#' @param decimal.mark character : Séparateur des décimales
#'
#' @returns character ou vecteur de characters
#' @export
#'
#' @importFrom dplyr if_else
#'
#' @examples
#' library(rUrgAra)
#' format_p_value(NA_real_)
#' format_p_value(1)
#' format_p_value(0.52, decimal.mark = ",")
#' format_p_value(0.01)
#' format_p_value(0.001)
#' format_p_value(0.0001)
#' format_p_value(0.0001, digits = 4)
#' format_p_value(0.00001)
#' format_p_value(0)
#' format_p_value(c(seq(0, 0.1, by = 0.005), 0.5, 1, NA))
#' format_p_value(c(seq(0, 0.1, by = 0.005), 0.5, 1, NA), digits = 2)
#' format_p_value(c(seq(0, 0.1, by = 0.005), 0.5, 1, NA), digits = 4)
#'
format_p_value <- function(p, digits = 3, decimal.mark = ".") {
  #tests validité
  if (!is.numeric(p)) {
    stop("L\'argument \'p\' doit num\u00e9rique.")
  }

  if (any(!is.na(p) & (p < 0 | p > 1))) {
    stop("Toutes les valeurs non-NA de \'p\' doivent \u00eatre comprises entre 0 et 1.")
  }

  #Mise en forme
  p_round <- if_else(p > 0.1 & p < 1,
                     format(round(p, digits = 2), nsmall = 2, decimal.mark = decimal.mark),#2 chiffres + trailing 0 si entre 0.1 et 0.99
                     format(round(p, digits = digits), scientific = FALSE, decimal.mark = decimal.mark))#Arrondi sinon

  p_clean = if_else(grepl("^0.?0*$", p_round),#0 ou 0.00...0
                    paste0("p < 0.", paste(rep("0", digits - 1), collapse = ""), "1"),
                    paste0("p = ", p_round))

  p_clean = if_else(p == 1,#gestion du cas particulier p = 1 et p = NA
                    "p = 1", p_clean,
                    missing = "p = NA")

  return(p_clean)
}
