#' Plot des délais entre points temporels
#'
#' @description
#' Génère un diagramme représentant les délais entre paires ordonnées de points
#' temporels présents dans `base`. Les “points” (événements) sont positionnés
#' sur l’axe des abscisses selon l’ordre de `time_points`. Chaque délai est
#' tracé sous forme de segment fléché entre deux points, avec un libellé et une
#' organisation verticale (pistes) pour éviter les chevauchements.
#'
#' @param base Un `data.frame` / `tibble` contenant les variables de date/heure
#'   (POSIXct) utilisées pour calculer les délais.
#' @param time_points Vecteur **nommé** (`named character`) où les **valeurs**
#'   sont les noms de colonnes de `base` (ex. `"t0"`, `"t1"`, …) et les **noms**
#'   (`names(time_points)`) sont les libellés à afficher (ex. `"Admission"`,
#'   `"1ère PEC"`, …). L'ordre de ce vecteur définit l'ordre horizontal.
#' @param tab_delay Par défaut `NULL`. Sinon, un objet à **2 colonnes**
#'   (`data.frame` / `tibble` / `matrix`) indiquant, par ligne, une paire
#'   `(d1, d2)` de variables pour lesquelles calculer/afficher le délai.
#'   Les valeurs de `d1` et `d2` doivent correspondre aux **valeurs** de
#'   `time_points` (c.-à-d. aux noms de colonnes dans `base`), pas aux libellés.
#' @param lower_bound,upper_bound Bornes numériques passées à
#'   `fct_calc_delay()` pour contraindre/tronquer le délai (par ex. exclure les
#'   valeurs hors bornes). Par défaut `-Inf` et `Inf`.
#' @param min_display Le nombre minimal de patient de délai valide pour afficher
#' la médiane et l'interquartile. Remplacé par "X" sinon.
#'
#' @details
#' - Si `tab_delay = NULL`, la fonction considère **toutes** les paires
#'   ordonnées \eqn{(d1, d2)} telles que `d1` précède `d2` dans l'ordre de
#'   `time_points`.
#' - La position verticale (piste `y`) des délais est calculée par
#'   `fct_assign_y_tracks()` pour limiter les recouvrements de segments.
#' - Le calcul des délais et la génération des libellés sont délégués à
#'   `fct_calc_delay()`. Cette fonction doit retourner au moins une colonne
#'   `lab_del` (libellé) et les éventuelles valeurs numériques nécessaires.
#' - Les étiquettes en haut de la grille verticale affichent le libellé
#'   (`names(time_points)`) et `n`, le nombre de valeurs non manquantes dans
#'   `base` pour chaque variable.
#' - Les fonctions utilitaires `fct_assign_y_tracks()` et `fct_calc_delay()` doivent
#'   être disponibles dans l'environnement.
#'
#' @return Un objet [`ggplot2::ggplot`] représentant le diagramme des délais.
#'
#' @export
#'
#' @import ggplot2
#' @import dplyr
#' @importFrom purrr map2 map_dbl
#' @importFrom tidyr unnest_wider
#' @importFrom grid unit arrow
#' @importFrom tibble is_tibble
#'
#' @examples
#' # --- Données jouets
#' set.seed(1)
#' base <- tibble::tibble(
#'   t0 = as.POSIXct("2024-01-01 08:00:00", tz = "UTC") + runif(50, 0, 2*3600),
#'   t1 = t0 + runif(50, 10, 60) * 60,  # +10 à +60 minutes
#'   t2 = t1 + runif(50,  5, 45) * 60   # +5 à +45 minutes
#' )
#'
#' # time_points : valeurs = noms de colonnes ; noms = libellés
#' time_pts <- c("Admission" = "t0", "1ère PEC" = "t1", "Sortie" = "t2")
#'
#' # 1) Plot de toutes les paires (par défaut)
#' p1 <- plot_delais_intervals(base, time_pts)
#' p1
#'
#' # 2) Sous-ensemble de paires
#' td <- data.frame(d1 = c("t0","t1"), d2 = c("t1","t2"))
#' p2 <- plot_delais_intervals(base, time_pts, tab_delay = td)
#' p2
#'
#' # 3) Bornes des délais (exemple)
#' p3 <- plot_delais_intervals(base, time_pts, lower_bound = 0, upper_bound = Inf)
#' p3

plot_delais_intervals = function(base, time_points, tab_delay = NULL,
                                 lower_bound = -Inf, upper_bound = Inf,
                                 min_display = 5){
  #checks
  if(!all(time_points %in% names(base))) stop("Tous les time_points doivent \u00eatre dans base")
  if(!is.null(tab_delay)){
    if(!is_tibble(tab_delay) & !is.data.frame(tab_delay) & !is.matrix(tab_delay)) stop("tab_delay doit \u00eatre un data.frame, tibble ou matrice")
    if(ncol(tab_delay) != 2) stop("tab_delay doit \u00eatre null ou contenir exactement 2 colonnes")
    if(any(!c(tab_delay[,1], tab_delay[,2]) %in% time_points)) stop("tab_delay ne doit contenir que des d\u00e9lais pr\u00e9sents dans time_points")
  }
  if (is.null(names(time_points)) || any(is.na(names(time_points))) || any(!nzchar(names(time_points)))) {
    stop("Chaque valeur de \'time_points\' doit avoir un nom (libell\u00e9) non vide.")
  }
  if (!is.numeric(lower_bound) || length(lower_bound) != 1) stop("\'lower_bound\' doit \u00eatre un num\u00e9rique de longueur 1.")
  if (!is.numeric(upper_bound) || length(upper_bound) != 1) stop("\'upper_bound\' doit \u00eatre un num\u00e9rique de longueur 1.")



  #Gestion de tab_delay null en utilisant tous les délais + fixer nom colonnes
  if(is.null(tab_delay)) tab_delay = expand.grid(d1 = time_points, d2 = time_points)
  names(tab_delay) <- c("d1", "d2")#fixe le nom des colonnes

  #Suppression des cas où d1 est après dans l'ordre des time_points
  tab_delay = tab_delay %>%
    mutate(
      d1 = as.character(.data$d1),
      d2 = as.character(.data$d2),

      d1_rank = match(d1, time_points),
      d2_rank = match(d2, time_points)
    ) %>%
    filter(d1_rank < d2_rank)

  #Calcul de y "optimal" par un algo de partitionnement d'interval
  tab_delay = fct_assign_y_tracks(tab_delay, d1 = "d1_rank", d2 = "d2_rank")

  #Calcul des délais
  tab_delay <- tab_delay %>%
    mutate(
      res = map2(
        as.character(d1), as.character(d2),
        ~ fct_calc_delay(
          base,
          d1 = .x, d2 = .y,
          lower_bound = lower_bound, upper_bound = upper_bound,
          min_display = min_display
        )
      )
    ) %>%
    # Éclater la liste de 4 valeurs en 4 colonnes
    unnest_wider(res)

  #Création de la table des coordonnées
  y_max = max(tab_delay$y)
  tab_vertical_grid = tibble(
    var = time_points,
    label_var = names(time_points),
    x = seq_len(length(time_points)),
    y_max = y_max,
    n = map_dbl(var, ~sum(!is.na(base[[.x]]))),
    label = paste0(label_var, "\nn = ", n)
  )


  #Création du plot
  plot_res = ggplot() +
    #Création de la grille verticale + labels
    geom_segment(aes(x = x, y = 0,
                     xend = x, yend = y_max), data = tab_vertical_grid, colour = "grey", linetype = 2) +
    geom_text(aes(label = label,
                  x = x, y = y_max + (y_max*0.2)), vjust = 1, data = tab_vertical_grid, fontface = "bold") +
    #Création de la grille horizontale + labels
    geom_segment(aes(x = d1_rank + 0.05, y = y,
                     xend = d2_rank - 0.05, yend = y), data = tab_delay, arrow = arrow(length = unit(0.03, "npc"))) +
    geom_text(aes(label = lab_del,
                  x = (d1_rank + d2_rank)/2, y = y), data = tab_delay, vjust = 1.1) +
    #Theme
    coord_cartesian(xlim = range(tab_vertical_grid$x), ylim = c(0.8, y_max + (y_max*0.2))) +
    theme_void()

  return(plot_res)
}


#' fct_calc_delay
#'
#' @description
#' Calcul les délais entre deux dates/heures dans une base et supprime les valeurs hors délais
#'
#' @param base Table contenant les date/heure
#' @param d1 Nom de premier date/heure
#' @param d2 Nom de deuxieme date/heure
#' @param lower_bound Borne minimale du délais. Les valeurs inférieurs sont supprimées
#' @param upper_bound Borne maximale du délais. Les valeurs supérieurs sont supprimées
#' @param min_display Le nombre minimal de patient de délai valide pour afficher
#' la médiane et l'interquartile. Remplacé par "X" sinon.
#'
#' @import dplyr
#' @importFrom lubridate is.POSIXct
#' @importFrom stats quantile
#' @returns Une liste de 4 valeurs (lab_del/Q1_del/med_del/Q3_del)
#'
fct_calc_delay <- function(base, d1, d2, lower_bound, upper_bound, min_display){
  #check
  if(!is.POSIXct(base[[d1]])) stop(paste0(d1, " n\'est pas de type POSIXct"))
  if(!is.POSIXct(base[[d2]])) stop(paste0(d2, " n\'est pas de type POSIXct"))
  #Calc du délais en minutes
  del = as.numeric(difftime(base[[d2]], base[[d1]], units = "mins"))

  #Suppression des délais en dehors de lower/upper bound
  del = if_else(!between(del, lower_bound, upper_bound), NA_real_, del)

  #Calcul des quantiles et nombre de délais calculables
  quantiles_del = round(quantile(del, probs = c(0.25, 0.5, 0.75), na.rm = TRUE))
  n_noNA = sum(!is.na(del))
  #Nettoyage du label
  quantiles_del_clean = quantiles_del
  if(all(quantiles_del_clean > 60, na.rm = TRUE) & any(!is.na(quantiles_del_clean))){#Passage en format 00h00 quand pertienent
    quantiles_del_clean = fct_convert_time_labels(quantiles_del_clean)
  }

  #Création du label
  lab_del = if_else(
    n_noNA < min_display,
    paste0("X - n = ", fct_f_big(n_noNA)),
    paste0(quantiles_del_clean[2],
           " [", quantiles_del_clean[1], ";", quantiles_del_clean[3],
           "] - n = ", fct_f_big(n_noNA)
    ))

  return(
    list(lab_del = lab_del,
         Q1_del = quantiles_del[1],
         med_del = quantiles_del[2],
         Q3_del = quantiles_del[3])
  )
}





#FONCTION ET ROXYGEN COPILOT
#' Binning d'intervalles en pistes (touching autorisé)
#'
#' Fonction interne : assigne un entier \code{y} (piste) à chaque segment en
#' supposant \code{df[[d1]] <= df[[d2]]}. Deux segments qui se touchent aux
#' extrémités peuvent partager la même piste (règle \code{end <= start}).
#'
#' @param df data.frame/tibble contenant \code{d1} et \code{d2}.
#' @param d1 Nom de la colonne début (défaut \code{"d1_rank"}).
#' @param d2 Nom de la colonne fin (défaut \code{"d2_rank"}).
#'
#' @return \code{df} avec une colonne entière \code{y}.
#' @keywords internal
#' @noRd
fct_assign_y_tracks <- function(df, d1, d2) {
  stopifnot(all(c(d1, d2) %in% names(df)))
  start <- df[[d1]]
  end   <- df[[d2]]
  n <- NROW(df)

  # Tri par début puis fin
  ord <- order(start, end)
  start_o <- start[ord]
  end_o   <- end[ord]

  # Binning glouton : "touching" autorisé => end <= start
  y_o <- integer(n)
  track_end <- numeric(0)

  for (i in seq_len(n)) {
    s <- start_o[i]; e <- end_o[i]

    if (length(track_end) == 0L) {
      y_o[i] <- 1L
      track_end <- e
    } else {
      available <- which(track_end <= s)   # pour "touching = chevauchement", remplacer par `< s`
      if (length(available)) {
        k <- available[which.min(track_end[available])]
        y_o[i] <- k
        track_end[k] <- e
      } else {
        y_o[i] <- length(track_end) + 1L
        track_end <- c(track_end, e)
      }
    }
  }

  # Restaure l'ordre d'origine
  y <- integer(n)
  y[ord] <- y_o
  df$y <- y
  return(df)
}


