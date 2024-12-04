#' plot charge diagram
#'
#' plot a charge diagram from the "tab_charge" object created by plot_diag_charge()
#'
#' @param data data passed from plot_diag_charge
#' @param tab_charge table created by fct_tab_charge
#' @inheritParams plot_diag_charge
#'
#' @return a ggplot
#' @noRd
fct_plot_charge <- function(data, tab_charge, max_LOS, show_lines){
  #Creation of a color palet
  pal1 <- RColorBrewer::brewer.pal(8, "Accent")
  pal2 <- RColorBrewer::brewer.pal(8, "Dark2")
  pal3 <- RColorBrewer::brewer.pal(8, "Set2")
  pal <- c("black", pal1, pal2, pal3)

  #plot rendering
  plot <- ggplot2::ggplot(tab_charge, ggplot2::aes()) +
    ggplot2::geom_density(ggplot2::aes(y = .data$n_avg, x = as.numeric(.data$Hour), fill = factor(.data$H_entry, levels = c("-1", 0:23))),
                          stat = "identity",  position = "stack", color = NA) +
    ggplot2::scale_fill_manual(values = pal) +
    ggplot2::scale_x_continuous(name = "", breaks = seq(1,24, by = 1),
                                labels = paste0("< ", seq(1,24, by = 1), "h")) +
    ggplot2::scale_y_continuous(name = "Nombre moyen de patients", breaks = scales::pretty_breaks(10)) +
    ggplot2::coord_cartesian(xlim = c(1,24), ylim = c(0,NA)) +
    ggpubr::theme_pubclean() +
    ggplot2::guides(fill = "none") +
    ggplot2::theme(text=ggplot2::element_text(family="serif", size=15)) +
    ggplot2::theme(legend.position = "bottom",
                   legend.key = ggplot2::element_blank(),
                   axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))

  if(show_lines){
    #computation of the number of entry/exit per hour
    tab_entry <- data %>%
      dplyr::filter(.data$LOS < max_LOS) %>%
      dplyr::mutate(Hour = lubridate::hour(.data$dh_entry) + 1,
                    Hour = factor(.data$Hour, levels = c(1:24))) %>%
      dplyr::group_by(.data$Hour, .drop = F) %>%
      dplyr::count() %>%
      dplyr::mutate(Hour = as.numeric(as.character(.data$Hour)),
                    n_days = dplyr::first(tab_charge$n_days),
                    n_strata = dplyr::first(tab_charge$n_strata),
                    n_avg = .data$n/(.data$n_days*.data$n_strata)) %>%
      dplyr::ungroup()

    tab_exit <- data %>%
      dplyr::filter(.data$LOS < max_LOS) %>%
      dplyr::mutate(Hour = lubridate::hour(.data$dh_exit) + 1,
                    Hour = factor(.data$Hour, levels = c(1:24))) %>%
      dplyr::group_by(.data$Hour, .drop = F) %>%
      dplyr::count() %>%
      dplyr::mutate(Hour = as.numeric(as.character(.data$Hour)),
                    n_days = dplyr::first(tab_charge$n_days),
                    n_strata = dplyr::first(tab_charge$n_strata),
                    n_avg = .data$n/(.data$n_days*.data$n_strata)) %>%
      dplyr::ungroup()

    plot <- plot +
      ggplot2::geom_line(ggplot2::aes(y = .data$n_avg, x = .data$Hour, color = "Nombre d'entr\u00E9es"), data = tab_entry, linewidth = 1.2) +
      ggplot2::geom_line(ggplot2::aes(y = .data$n_avg, x = .data$Hour, color = "Nombre de sorties"), data = tab_exit, linewidth = 1.2) +
      ggplot2::scale_color_manual(name = "", values = c("Nombre d'entr\u00E9es" = "darkgreen", "Nombre de sorties" = "darkred"))
  }

    return(plot)
}

#' Charge table
#'
#' Internal function. Makes a charge table with one line per hour of the day (entry) per hour of the day (exit) and returns a charge table used to plot a charge diagram
#'
#' @param data tibble with two columns, dh_entry and dh_exit
#' @inheritParams plot_diag_charge
#'
#' @return a tibble
#'
#' @noRd
fct_tab_charge <- function(data, from, to, max_LOS){
  #denominator
  n_days <- as.numeric(1 + difftime(to, from, units = "days"))
  if("strata" %in% names(data)){
    n_strata <- length(unique(data$strata))
  } else{n_strata = 1}

  #winsorisation of entry and exit to from and to
  data$entry_corrected_fact = lubridate::date(data$dh_entry) < from
  data$dh_entry_corrected = dplyr::if_else(data$entry_corrected_fact,
                                           lubridate::ymd_hms(paste(from, "00:00:00")),
                                           data$dh_entry)

  data$exit_corrected_fact = lubridate::date(data$dh_exit) > to
  data$dh_exit_corrected = dplyr::if_else(data$exit_corrected_fact,
                                          lubridate::ymd_hms(paste(to, "23:59:59")),
                                          data$dh_exit)

  #Computation of intermediary variables
  data_interm <- data %>%
    dplyr::mutate(#recomputation LOS and entry times after winsorization
      LOS = as.numeric(difftime(.data$dh_exit_corrected, .data$dh_entry_corrected, units = "mins")),
      H_entry = lubridate::hour(.data$dh_entry_corrected),
      H_exit = lubridate::hour(.data$dh_exit_corrected),
      entry_minute = .data$H_entry*60 + lubridate::minute(.data$dh_entry_corrected),#entry time in minutes since midnight
      d_entry_corrected = lubridate::date(.data$dh_entry_corrected),
      d_exit_corrected = lubridate::date(.data$dh_exit_corrected)
    ) %>%
    dplyr::select("entry_minute", "LOS", "entry_corrected_fact", "H_entry",
                  "H_exit", "d_entry_corrected", "d_exit_corrected") %>%
    dplyr::mutate(exit_minute = .data$entry_minute + .data$LOS,
                  H_exit_comp = .data$exit_minute %/% 60,#hour of exit with 00h of entry day (can be over 23h59)
                  H_exit_corrected = dplyr::if_else(.data$d_entry_corrected < .data$d_exit_corrected, 23, as.numeric(.data$H_exit)),#winsorizing it to 23hxx
                  exit_corrected_fact = as.numeric(.data$d_entry_corrected < .data$d_exit_corrected),
                  nb_cycles = .data$H_exit_comp %/% 24,#number of times 24h fit in the LOS
                  nb_cycles = dplyr::if_else(.data$nb_cycles == 0 & .data$d_entry_corrected < .data$d_exit_corrected,
                                             1, .data$nb_cycles),#correct an edge case
                  H_exit_last_cycle = .data$H_exit,
                  H_entry = dplyr::if_else(.data$entry_corrected_fact, -1, as.numeric(.data$H_entry)))

  #Number of "full cycles" to add (patient present from 00h01 to 23h59)
  nb_H24_add = data_interm  %>%
    dplyr::filter(.data$nb_cycles > 0) %>%
    dplyr::summarise(nb_cycle_tot = sum(.data$nb_cycles - 1)) %>%
    dplyr::pull(.data$nb_cycle_tot)

  #table of "full cycles"
  tab_full_day_supp <- tibble::tibble(
    H_entry = rep(-1, nb_H24_add),
    H_exit = rep(23, nb_H24_add),
    exit_corrected_fact = 1
  ) %>%
    dplyr::mutate_all(as.numeric)

  #table of "half cycles" to add (patient arrived the day before and leaves this day)
  tab_final_day <- tibble::tibble(#ajout de x lignes correpsond à des passages -1 à "heure de sortie dernier cycle)
    H_entry = -1,
    H_exit = data_interm %>% dplyr::filter(.data$nb_cycles > 0) %>% dplyr::pull(.data$H_exit_last_cycle),
    exit_corrected_fact = 0
  ) %>%
    dplyr::mutate_all(as.numeric)

  #merge of full cycles, half cycles and first days
  data_calc_charge = dplyr::bind_rows(data_interm %>% dplyr::select("H_entry", "H_exit" = "H_exit_corrected", "exit_corrected_fact"),
                                      tab_full_day_supp,
                                      tab_final_day)

  #Speed up following computation by merging indentical rows
  data_calc_charge_agreg = data_calc_charge %>%
    dplyr::group_by(.data$H_entry, .data$H_exit, .data$exit_corrected_fact) %>%
    dplyr::count()

  #For each hour of the day, count the number of patient present from wich time of arrival (-1 = day before)
  tab_n = lapply(seq(1, 24, by = 1), function(H){
    data_calc_charge_agreg %>%
      dplyr::filter((.data$H_entry < H & .data$H_exit >= H) |
                      (.data$H_entry == H -1 & .data$H_exit == H - 1 & .data$exit_corrected_fact == 0) |
                      (H == 1 & .data$H_entry == "-1" & .data$H_exit == 0) |#special case first hour
                      (H == 24 & .data$exit_corrected_fact == 1)#special case last hour
                    ) %>%
      dplyr::group_by(.data$H_entry) %>%
      dplyr::summarise(n = sum(.data$n)) %>%
      dplyr::mutate(Hour = H) %>%
      dplyr::ungroup()
  }) %>%
    dplyr::bind_rows() %>%
    dplyr::mutate(H_entry = factor(.data$H_entry, levels = c("-1", 0:23)),#ensure every time is present after the next "complete"
                  Hour = factor(.data$Hour, levels = c(1:24))) %>%
    tidyr::complete(.data$H_entry,
                    .data$Hour,
                    fill = list(n = 0)) %>%
    dplyr::mutate(H_entry = as.numeric(as.character(.data$H_entry)),#revert to the numeric type
                  Hour = as.numeric(as.character(.data$Hour)))

  tab_n$n_strata = n_strata
  tab_n$n_days = n_days

  tab_n$n_avg = tab_n$n/(n_days*n_strata)

  return(tab_n)
  }

#' Plot a charge diagram
#'
#' @description Plot a charge diagram from a table with an entre datetime and exit datetime. A charge diagram shows the number of individuals and their time of arrival for each hour/half hour of a day.
#'
#' @param data A data frame or tibble.
#' @param entry The name of the column containing the datetime of entry. The colmum must be of class POSIXct or character in the format DD/MM/YYYY HH:MM:SS.
#' @param exit The name of the column containing the datetime of exit. The colmum must be of class POSIXct or character in the format DD/MM/YYYY HH:MM:SS.
#' @param strata The name of the colum(s) containing statas (e.g. structures) to average the charge over.
#' @param from The start of the time frame to consider (dmy). Number of patients will be averaged over the number of days between "from" and "to" and entry date/times will be truncated at "from". Default value is the minimum date in the entry column.
#' @param to The end of the time frame to consider (dmy). Number of patients will be averaged over the number of days between "from" and "to" and exit date/times will be truncated at "to". Default value is the maximum date in the exit column.
#' @param max_LOS Maximum length of stay for patients in minutes. Patients with durations longer than max_LOS will be considered as having missing length of stay.
#' @param show_lines Should the number of entry/exit be plotted ? Default is TRUE.
#'
#' @return A list. tab contains the table used to make the charge diagram. H_entry = "-1" for patients entered the day before. plot contains the charge diagram.
#'
#' @export
#'
#' @examples
#' library(rUrgAra)
#' #Table of entry/exit times
#' head(df_ex_charge)
#' #Charge diagram with exclusion of patients staying more than 3 days (72*60 = 4320 minutes)
#' # not taking into account strata
#' list_charge = plot_diag_charge(data = df_ex_charge, entry = "ENTREE",
#'                                exit = "SORTIE", max_LOS = 72*60)
#' #plot_diag_charge return two objects, a table showing for each hour of
#' # the day how many patient came from what hour (-1 = day before)
#' head(list_charge$tab)
#' #a charge diagram
#' list_charge$plot
#'
#' #adding a strata to take into account that data are coming from two hospitals
#' list_charge_stratified = plot_diag_charge(data = df_ex_charge, entry = "ENTREE",
#'                                           exit = "SORTIE", strata = "Etablissement",
#'                                           max_LOS = 72*60)
#' #plot_diag_charge return two objects, a table showing for each hour of
#' # the day how many patient came from what hour (-1 = day before)
#' head(list_charge_stratified$tab)
#' #a charge diagram
#' list_charge_stratified$plot
#'
plot_diag_charge <- function(data, entry, exit, strata = NULL,
                             from = NULL, to = NULL, max_LOS = Inf,
                             show_lines = TRUE){
  #type check
  type_entry = dplyr::pull(data, entry) %>% class
  type_exit = dplyr::pull(data, exit) %>% class
  if(any(type_entry != type_exit))stop("entry and exit must have the same type")
  format_to_from_ok = function(x){#testing format param from and to
    if(is.null(x)) return(TRUE)
    if(length(x) > 1 | !is.character(x)) return(FALSE)
    if(!is.na(lubridate::dmy(x))) return(TRUE)
    return(FALSE)
  }
  if(!format_to_from_ok(from)){stop("from must be NULL or a character string containing a date in the DMY format")}
  if(!format_to_from_ok(to)){stop("to must be NULL or a character string containing a date in the DMY format")}
  if(!is.numeric(max_LOS) | max_LOS <= 0){stop("max_LOS must be numeric and positive")}
  if(!is.logical(show_lines) | length(show_lines) > 1){stop("show_lines should be a length 1 logical")}

  #rename entry/exit/strata column
  data <- data %>%
    dplyr::select(dh_entry = {entry}, dh_exit = {exit}, strata = {strata})

  #convertion to dmy_hms
  if(is.character(data$dh_entry)){
    data <- data %>%
      dplyr::mutate(dplyr::across(c("dh_entry", "dh_exit"), lubridate::dmy_hms))
  }

  #handling of default values for "from", "to"
  if(is.null(from)){from = min(lubridate::date(data$dh_entry), na.rm = T)} else {from = lubridate::dmy(from)}
  if(is.null(to)){to = max(lubridate::date(data$dh_exit), na.rm = T)} else {to = lubridate::dmy(to)}

  #Removing lines outside of "from" and "to"
  if(from > to){stop('"from" must be equal or earlier than "to"')}
  nrow_before = nrow(data)
  data <- data %>%
    dplyr::filter(dplyr::between(lubridate::date(.data$dh_entry),
                                 from, to) |#arrived between from and to
                    dplyr::between(lubridate::date(.data$dh_exit),
                                   from, to) |#left between from and to
                    (lubridate::date(.data$dh_entry) <= from &
                       lubridate::date(.data$dh_exit) >= to))#Arriver before from and left after to
  nrow_after = nrow(data)
  if(nrow_before != nrow_after){
    warning(paste0(nrow_before - nrow_after, " rows were removed because they were outside of the studied range."))
  }

  #Removing delays over max_LOS
  data$LOS = difftime(data$dh_exit, data$dh_entry, units = "mins")
  LOS_over = data$LOS > max_LOS
  if(sum(data$LOS > max_LOS, na.rm = T) > 0){
    warning(paste(sum(data$LOS > max_LOS, na.rm = T),
                  "delays have been removed because of length of stay superior to",
                  max_LOS, "minutes"))}
  data = data %>% dplyr::filter(!LOS_over)

  #computation of the table of charge
  tab_charge <- fct_tab_charge(data = data, from = from, to = to, max_LOS = max_LOS)

  #plotting of the charge diagram
  plot_charge <- fct_plot_charge(data = data, tab_charge = tab_charge, max_LOS = max_LOS,
                                 show_lines = show_lines)

  return(list(tab = tab_charge,
              plot = plot_charge))
}
