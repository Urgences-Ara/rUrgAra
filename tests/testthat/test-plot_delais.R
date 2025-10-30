make_base_toy <- function(n = 10, tz = "UTC") {
  set.seed(42)
  t0 <- as.POSIXct("2024-01-01 08:00:00", tz = tz) + runif(n, 0, 2*3600)
  t1 <- t0 + runif(n, 10, 60) * 60             # +10 à +60 min
  t2 <- t1 + runif(n,  5, 45) * 60             # +5 à +45 min
  tibble::tibble(t0 = t0, t1 = t1, t2 = t2)
}

time_pts_toy <- c("Admission" = "t0", "1ère PEC" = "t1", "Sortie" = "t2")


test_that("erreurs d'arguments claires et précises", {
  base <- make_base_toy()
  tp   <- time_pts_toy

  # time_points doivent être des colonnes de base
  expect_error(
    plot_delais_intervals(base, c("Admission" = "badcol")),
    "Tous les time_points doivent être dans base",
    fixed = TRUE
  )

  # time_points doivent avoir des noms (libellés) non vides
  bad_tp <- unname(tp)
  expect_error(
    plot_delais_intervals(base, bad_tp),
    "Chaque valeur de 'time_points' doit avoir un nom (libellé) non vide.",
    fixed = TRUE
  )
  bad_tp2 <- tp
  names(bad_tp2)[2] <- ""  # libellé vide
  expect_error(
    plot_delais_intervals(base, bad_tp2),
    "Chaque valeur de 'time_points' doit avoir un nom (libellé) non vide.",
    fixed = TRUE
  )

  # tab_delay doit être df/tibble/matrix à 2 colonnes
  expect_error(
    plot_delais_intervals(base, tp, tab_delay = 1L),
    "tab_delay doit être un data.frame, tibble ou matrice",
    fixed = TRUE
  )
  expect_error(
    plot_delais_intervals(base, tp, tab_delay = data.frame(a = 1)),
    "tab_delay doit être null ou contenir exactement 2 colonnes",
    fixed = TRUE
  )

  # tab_delay doit contenir des valeurs présentes dans time_points (valeurs !)
  td_bad <- data.frame(d1 = "t0", d2 = "bad")
  expect_error(
    plot_delais_intervals(base, tp, tab_delay = td_bad),
    "tab_delay ne doit contenir que des délais présents dans time_points",
    fixed = TRUE
  )

  # lower/upper bound doivent être numériques scalaires
  expect_error(
    plot_delais_intervals(base, tp, lower_bound = c(0, 1)),
    "'lower_bound' doit être un numérique de longueur 1.",
    fixed = TRUE
  )
})
