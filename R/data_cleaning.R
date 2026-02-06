#' Merge complementary variables
#'
#' @description
#' Merges multiple variables that are mutually exclusive into a single variables. Use either a complete list of variables to merge or the prefix of variables to merge or both.
#'
#' @param data A data.frame or tibble containing variables to merge
#' @param var char vector containing the name of variables to merge in data
#' @param prefix char vector containing the prefix. Every column in data starting with the prefix will be merged
#' @param exclude char vector of variables to exclude from the merge
#' @param info Boolean to print or not the merged variables and number of NA in the console
#'
#' @return A variable containing merged values from each column
#' @export
#'
#' @importFrom dplyr select starts_with all_of any_of
#' @importFrom stats na.omit
#'
#' @examples
#' \dontrun{
#' library(rUrgAra)
#' data = data.frame(
#' ID = 1:40,
#' nom_etab01 = c(rep(NA, 30), sample(LETTERS[1:10], 10, replace = TRUE)),
#' nom_etab03 = c(rep(NA, 20), sample(LETTERS[1:10], 10, replace = TRUE), rep(NA, 10)),
#' nom_etab_dechocage = c(rep(NA, 10), sample(LETTERS[1:10], 10, replace = TRUE), rep(NA, 20)),
#' nom_des_etab_du38 =  c(sample(LETTERS[1:10], 10, replace = TRUE), rep(NA, 30)),
#' age =  sample(75:95, 40, replace = T)
#' )
#'
#' data$etab = merge_complementary_variables(data, prefix = "nom_etab", var = "nom_des_etab_du38",
#'                                           exclude = "nom_etab_dechocage", info = TRUE)
#' data
#' }
#'
merge_complementary_variables <- function(data, var = NULL, prefix = NULL, exclude = NULL, info = TRUE){
  #Selection variables matching on prefix
  if(!is.null(prefix)){#starts_with ne fonctionne pas avec NULL => Création d'un vec pour utiliser all_of
    list_var_prefix = grep(paste0("^", prefix), names(data),
                           value = T)} else {list_var_prefix = NULL}

  #selecting the table to merge
  merge_table = data %>%
    select(all_of(list_var_prefix), all_of(var)) %>%
    select(-any_of(exclude))

  #check whether the variables are complementary
  nb_noNA = apply(merge_table, 1, function(row){sum(!is.na(row))})
  if(any(nb_noNA > 1)){
    stop(paste0("Multiple values are filled for selected variables on rows : ", paste(which(nb_noNA > 1), collapse = " ")))
  }

  #user information
  if(info){message("The following variables will be merged : ", paste(names(merge_table), collapse = " "))}

  #merge
  merged_var = apply(merge_table, 1, function(row){
    if(all(is.na(row))){
      return(NA)
    } else {
      return(na.omit(row))
    }
  })

  n_NA = sum(is.na(merged_var))

  if(info){message("The merged variable contains ", n_NA, " missing value(s)")}

  return(merged_var)
}






#' Controle values in a variable
#'
#' @param var Variable to check
#' @param val_autor Vector of authorized values
#' @param lab The name of the variable (only used to print the number of removed values)
#' @param replacement Value to replace "Non conform" modalities with. "NC" is used by default.
#'
#' @return A vector with NA left as NA and values outside of "val_autor" transformed into "NC" (Not conform)
#' @export
#'
#' @examples
#' var = c(NA, LETTERS[1:5])
#' fct_format_control(var, val_autor = c("A", "C", "F"), lab = "lettres")
#'
fct_format_control <- function(var, val_autor, lab, replacement = "NC"){
  n_NA_before = sum(is.na(var))
  var_ok = ifelse(is.na(var), NA,
                  ifelse(!var %in% val_autor, replacement, var))
  n_corrige = sum(var_ok %in% replacement)
  if(is.na(replacement)){n_corrige = n_corrige - n_NA_before}
  if(n_corrige != 0){warning(paste(n_corrige, "formats corrig\u00e9s pour la variable", lab))}
  return(var_ok)
}




#' Vérification de la qualité du RPU
#'
#' @description
#' Calcule par NOM_ETAB et COD_FIN le taux de remplissage et d'autres informations de diagnostic de la qualité
#'
#'
#' @param tab Un data.frame ou tibble contenant au minimum "NOM_ETAB" et "COD_FIN".
#' @param var_hospit Char. Nom de la variable contenant l'hospitalisation. La variable doit être logical
#' @param var_duree_passage Char. Nom de la variable contenant la durée du passage. La variable doit être numeric
#' @param var_age Char. Nom de la variable contenant l'age. La variable doit être numeric
#'
#' @details
#' La fonction explore juste le taux de remplissage d'un tableau par NOM_ETAB/COD_FIN.
#' Le nettoyage de la base (valeurs autorisées) et le calcul de variables composites est à réaliser en amont
#'
#'
#' @return liste d'information diagnostic
#' @export
#'
#' @importFrom ggplot2 ggplot theme element_text geom_crossbar aes geom_errorbar geom_col
#' @importFrom stats quantile sd
#' @importFrom forcats fct_reorder
#' @importFrom purrr iwalk
#' @importFrom dplyr group_by ungroup summarise mutate across n
#'
#' @examples
#' \dontrun{
#' #quality_list = check_RPU_quality(RPU, var_hospit = "hospit",
#' #                                 var_duree_passage = "duree_passage",
#' #                                 var_age = "age")
#' #quality_list$n_etab#Nombre d'établissement dans l'export
#' #quality_list$tab_remplissage#taux de remplissage par variable par établissement
#' #quality_list$plot_hospit#Taux d'hospitalisation par établissement
#' #quality_list$plot_duree_passage#boxplot durée de passage par établissement
#' #quality_list$plot_age#boxplot age par établissement
#' }
check_RPU_quality <- function(tab, var_hospit = NULL, var_duree_passage = NULL, var_age = NULL){
  if(any(!c("NOM_ETAB", "COD_FIN") %in% names(tab))){
    stop("NOM_ETAB et COD_FIN attendus comme variables")}

  #Nombre d'établissements
  n_etab = length(unique(tab$NOM_ETAB))

  #Taux de remplissage par variable par établissement
  ##table
  tab_remplissage = tab %>%
    group_by(COD_FIN, NOM_ETAB) %>%
    summarise(
      N = n(),
      across(c(-N), function(col){
        mean(!is.na(col))
        })
    ) %>%
    ungroup()

  ##Warnings automatiques
  tab_remplissage %>%
    select(-COD_FIN, -NOM_ETAB) %>%
    iwalk(function(col, name_col){
      mean_col = mean(col)
      sd_col = sd(col)
      outlier_col = which(col < (mean_col - 3*sd_col))
      if(length(outlier_col) > 0){
        warning(paste0("Une valeur anormalement basse est observ\u00e9e en ligne(s) ",
                       paste(outlier_col, collapse = " ") , " sur la variable ", name_col))
      }
    })


  #Taux d'hospitalisation
  if(!is.null(var_hospit)){
    if(!var_hospit %in% names(tab)){
      stop(paste0("La variable ", var_hospit, " n\'existe pas dans les donn\u00e9es"))
    }
    if(!is.logical(tab[[var_hospit]])){
      stop("La variable hospitalisation doit \u00eatre logical")
    }

    plot_hospit = tab %>%
      group_by(COD_FIN) %>%
      summarise(
        tx_hospit = mean(.data[[var_hospit]], na.rm = TRUE)
      ) %>%
      mutate(COD_FIN = fct_reorder(COD_FIN, tx_hospit)) %>%
      ggplot(aes(x = COD_FIN, y = tx_hospit)) +
      geom_col() +
      theme(axis.text.x = element_text(angle = 90))
  } else {
    plot_hospit = NULL
  }

  #Durée de passage
  if(!is.null(var_duree_passage)){
    if(!var_duree_passage %in% names(tab)){
      stop(paste0("La variable ", var_duree_passage, " n\'existe pas dans les donn\u00e9es"))
    }
    if(!(is.numeric(tab[[var_duree_passage]]))){
      stop("La variable dur\u00e9e de passage doit \u00eatre numeric ou difftime")
    }

    plot_duree_passage = tab %>%
      group_by(COD_FIN) %>%
      summarise(
        Q01 = quantile(.data[[var_duree_passage]], probs = 0.01, na.rm = T),
        Q25 = quantile(.data[[var_duree_passage]], probs = 0.25, na.rm = T),
        Q50 = quantile(.data[[var_duree_passage]], probs = 0.50, na.rm = T),
        Q75 = quantile(.data[[var_duree_passage]], probs = 0.75, na.rm = T),
        Q99 = quantile(.data[[var_duree_passage]], probs = 0.99, na.rm = T)
      ) %>%
      mutate(
        COD_FIN = fct_reorder(COD_FIN, Q50)
      ) %>%
      ggplot(aes(x = COD_FIN)) +
      geom_errorbar(aes(ymin = Q01, ymax = Q99)) +
      geom_crossbar(aes(ymin = Q25, ymax = Q75, y = Q50)) +
      theme(axis.text.x = element_text(angle = 90))

  } else {
    plot_duree_passage = NULL
  }

  #age
  if(!is.null(var_age)){
    if(!var_age %in% names(tab)){
      stop(paste0("La variable ", var_age, " n\'existe pas dans les donn\u00e9es"))
    }
    if(!(is.numeric(tab[[var_age]]))){
      stop("La variable age doit \u00eatre numeric")
    }

    plot_age = tab %>%
      group_by(COD_FIN) %>%
      summarise(
        Q01 = quantile(.data[[var_duree_passage]], probs = 0.01, na.rm = T),
        Q25 = quantile(.data[[var_duree_passage]], probs = 0.25, na.rm = T),
        Q50 = quantile(.data[[var_duree_passage]], probs = 0.50, na.rm = T),
        Q75 = quantile(.data[[var_duree_passage]], probs = 0.75, na.rm = T),
        Q99 = quantile(.data[[var_duree_passage]], probs = 0.99, na.rm = T)
      ) %>%
      mutate(
        COD_FIN = fct_reorder(COD_FIN, Q50)
      ) %>%
      ggplot(aes(x = COD_FIN)) +
      geom_errorbar(aes(ymin = Q01, ymax = Q99)) +
      geom_crossbar(aes(ymin = Q25, ymax = Q75, y = Q50)) +
      theme(axis.text.x = element_text(angle = 90))

  } else {
    plot_age = NULL
  }

  #return
  return(list(
    n_etab = n_etab,
    tab_remplissage = tab_remplissage,
    plot_hospit = plot_hospit,
    plot_duree_passage = plot_duree_passage,
    plot_age = plot_age
  ))
}


