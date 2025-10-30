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







#' Convertir une durée (en minutes) en étiquette lisible (jours/heures/minutes)
#'
#' @description
#' Formate un vecteur de durées en minutes en libellés lisibles à la française,
#' avec une précision au choix : jours seuls, jours+heures (heures arrondies),
#' ou heures:minutes (zéro‑remplies).
#'
#' @details
#' - **Validation** : `d_min` doit être numérique et **fini** (`NA`/`Inf` non autorisés).
#' - **Négatifs** : les valeurs **négatives** sont converties en `NA` (sans avertissement à ce jour).
#' - **Précision** :
#'   - `precision = "days"` : renvoie uniquement le nombre de jours selon `rounding`,
#'     concaténé à `sep_j`.
#'   - `precision = "hours"` : renvoie le nombre de jours (si > 0) suivi des **heures arrondies**
#'     selon `rounding` et `sep_h`.
#'   - `precision = "mins"` (défaut) : renvoie `HHhMM` avec **zéro‑remplissage** (`sprintf("%02d")`),
#'     précédé du nombre de jours si > 0.
#'
#' Les séparateurs `sep_j`, `sep_h` et `sep_min` permettent de personnaliser le rendu (par ex. `" j "`,
#' `" h "`, `" min"`).
#'
#' @param d_min `numeric` ou `integer` (vectorisé).
#'   Durée(s) en minutes à convertir. Doit être **finie** (pas de `NA`, `Inf`).
#' @param precision `character(1)` ; l'une de `"mins"` (défaut), `"hours"`, `"days"`.
#' @param sep_j `character(1)` ; séparateur/suffixe pour les jours (défaut `"j"`).
#' @param sep_h `character(1)` ; séparateur/suffixe pour les heures (défaut `"h"`).
#' @param sep_min `character(1)` ; séparateur/suffixe pour les minutes (défaut `""`).
#' @param silent `logical(1)` ; Permet de contrôler l'émission d'un avertissement lors
#' de la conversion des valeurs négatives en `NA`.
#' @param rounding `character(1)` ; stratégie d'arrondi pour les modes `"days"` et `"hours"`.
#'   L'une de `"round"` (défaut), `"floor"`, `"ceiling"`.
#'
#' @return Un vecteur `character` de même longueur que `d_min` contenant les étiquettes formatées.
#'
#' @section Comportements notables :
#' - La fonction est vectorisée sur `d_min`.
#' - En mode `"hours"`, **les heures** issues du reliquat de minutes sont arrondies via `rounding`;
#'   en mode `"mins"`, on **zéro‑remplit** `HH` et `MM` sans arrondir les minutes.
#' - Les valeurs négatives deviennent `NA` dans la sortie.
#'
#' @examples
#' # Heures:minutes (zéro-remplissage), avec jours si nécessaire
#' fct_convert_time_labels(c(65764, NA, 138, 28, 1440, 654), "mins")          # "00h00"
#'
#' # Jours + heures (arrondies) selon la stratégie
#' fct_convert_time_labels(c(65764, NA, 138, 28, 1440, 654), "hours", rounding = "round")   # "2h"
#' fct_convert_time_labels(c(65764, NA, 138, 28, 1440, 654), "hours", rounding = "floor")   # "1h"
#' fct_convert_time_labels(c(65764, NA, 138, 28, 1440, 654), "hours", rounding = "ceiling") # "2h"
#'
#' # Négatifs -> NA
#' fct_convert_time_labels(c(45, -1, 61), "mins")
#'
#' @seealso sprintf(), base::ifelse(), round(), floor(), ceiling()
#' @export
fct_convert_time_labels <- function(d_min, precision = "mins",
                                    sep_j = "j", sep_h = "h", sep_min = "",
                                    silent = FALSE, rounding = "round"){
  #checks
  precision <- match.arg(precision, c("mins", "hours", "days"))
  if (!is.numeric(d_min)) stop("`d_min` doit \u00eatre num\u00e9rique.")
  if (any(is.infinite(d_min))) stop("`d_min` doit \u00eatre fini")
  rounding <- match.arg(rounding, c("round","floor","ceiling"))
  #gestion de round, floor ou ceiling
  rfun <- switch(rounding, round = round, floor = floor, ceiling = ceiling)

  #Suppression avec warning des données négatives
  if(any(d_min < 0, na.rm = T) & !silent){
    warning(paste0(sum(d_min < 0), " d\u00e9lais sont n\u00e9gatifs et ont \u00e9t\u00e9 supprim\u00e9s"))
  }
  d_min = ifelse(d_min < 0, NA_real_, d_min)

  #Cas où aucune précision demandée (jours)
  if(precision %in% "days"){
    lab_time = paste0(rfun(d_min/1440), sep_j)
    return(lab_time)
  }

  #convertion en jours
  days = d_min%/%1440
  d_min_left = d_min%%1440

  #Convertion en heures des minutes restantes
  if(precision == "hours"){
    hour = rfun(d_min_left/60)
    lab_time = ifelse(
      days > 0,
      paste0(days, sep_j, hour, sep_h),
      paste0(hour, sep_h)
    )
    return(lab_time)
  } else {
    hour = d_min_left%/%60
    hour = sprintf("%02d", hour)
  }

  #Extraction du nombre de minutes restantes
  minute = d_min_left%%60
  minute = sprintf("%02d", minute)
  #lab time
  lab_time = ifelse(
    days > 0,
    paste0(days, sep_j, hour, sep_h, minute, sep_min),
    paste0(hour, sep_h, minute, sep_min)
  )
  return(lab_time)
}


#' Format grand nombres
#'
#' @param val Numeric
#'
#' @returns Une chaine de caractère contenant le nombre donné en entrée avec un espace en séparateur des milliers
#'
fct_f_big <- function(val){#format for big numbers (inserts a big mark)
  val_ok <- format(val, big.mark = " ")
  return(val_ok)
}
