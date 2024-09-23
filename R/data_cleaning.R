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
#' @importFrom dplyr select starts_with all_of
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
#' data$etab = merge_complementary_variables(data,prefix = "nom_etab", var = "nom_des_etab_du38", exclude = "nom_etab_dechocage",
#'                                           info = TRUE)
#' data
#' }
#'
merge_complementary_variables <- function(data, var = NULL, prefix = NULL, exclude = NULL, info = TRUE){
  #selecting the table to merge
  merge_table = data |>
    select(starts_with(prefix), all_of(var)) |>
    select(-all_of(exclude))

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
#'
#' @return A vector with NA left as NA and values outside of "val_autor" transformed into "NC" (Not conform)
#' @export
#'
#' @examples
#' var = c(NA, LETTERS[1:5]]
#' fct_format_control(var, val_autor = c("A", "C", "F"), lab = "lettres")
#'
fct_format_control <- function(var, val_autor, lab){
  var_ok = ifelse(is.na(var), NA,
                  ifelse(!var %in% val_autor, "NC", var))
  n_corrige = sum(var_ok %in% "NC")
  if(n_corrige != 0){warning(paste(n_corrige, "formats corrig\u00e9s pour la variable", lab))}
  return(var_ok)
}
