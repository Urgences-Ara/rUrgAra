#' FINESS code cleaning
#'
#' @description
#' Adds the leading "0" to FINESS codes if it contains only 8 caracters instead of 9.
#'
#' @param char A character vector containing FINESS codes with missing leading "0". Each code should be 8 or 9 characters.
#'
#' @return A character vector containing the FINESS code with a leading "0" when needed
#' @export
#'
#' @importFrom dplyr if_else
#'
#' @examples
#' library(rUrgAra)
#' clean_FINESS(c("10784320", "380000174"))
clean_FINESS <- function(char){
  if(!is.character(char)){stop("char must be a character vector.")}
  if(any(!nchar(char) %in% c(8, 9))){stop("FINESS should be 9 or 8 characters. Some occurences are different.")}
  char = if_else(nchar(char) == 8, paste0("0", char), as.character(char))
  return(char)
}
