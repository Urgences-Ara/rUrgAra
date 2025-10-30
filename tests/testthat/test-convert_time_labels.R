
# Test de fct_convert_time_labels -----------------------------------------
test_that("validation des arguments : type et valeurs finies", {
  expect_error(fct_convert_time_labels("a"), "`d_min` doit être numérique")
  expect_error(fct_convert_time_labels(Inf), "doit être fini")

  expect_error(fct_convert_time_labels(60, precision = "foo"), "should be one of")
  expect_error(fct_convert_time_labels(60, rounding = "trunc"), "should be one of")
})

test_that("négatifs -> NA (sans erreur)", {
  x <- c(-5, 0, 5)
  out <- fct_convert_time_labels(x, "mins", silent = T)
  expect_true(is.na(out[1]))
  expect_identical(out[2], "00h00")
  expect_identical(out[3], "00h05")

  out_h <- fct_convert_time_labels(x, "hours", silent = T)
  expect_true(is.na(out_h[1]))
})

test_that("precision='days' respecte la stratégie d'arrondi", {
  # 1439 min ≈ 0.9993 j
  expect_identical(fct_convert_time_labels(1439, "days", rounding = "round"),   "1j")
  expect_identical(fct_convert_time_labels(1439, "days", rounding = "floor"),   "0j")
  expect_identical(fct_convert_time_labels(1439, "days", rounding = "ceiling"), "1j")

  # 2160 min = 1.5 j
  expect_identical(fct_convert_time_labels(2160, "days", rounding = "round"),   "2j")
  expect_identical(fct_convert_time_labels(2160, "days", rounding = "floor"),   "1j")
  expect_identical(fct_convert_time_labels(2160, "days", rounding = "ceiling"), "2j")
})

test_that("precision='hours' : heures arrondies selon 'rounding'", {
  # 90 min -> 1.5 h, jours = 0
  expect_identical(fct_convert_time_labels(90, "hours", rounding = "round"),   "2h")
  expect_identical(fct_convert_time_labels(90, "hours", rounding = "floor"),   "1h")
  expect_identical(fct_convert_time_labels(90, "hours", rounding = "ceiling"), "2h")

  # Avec jours : 1j + 31 min -> heures ~ 0.5167 h
  x <- 1440 + 31
  expect_identical(fct_convert_time_labels(x, "hours", rounding = "round"),   "1j1h")
  expect_identical(fct_convert_time_labels(x, "hours", rounding = "floor"),   "1j0h")
  expect_identical(fct_convert_time_labels(x, "hours", rounding = "ceiling"), "1j1h")

  # Frontière : pile une journée
  expect_identical(fct_convert_time_labels(1440, "hours"), "1j0h")
})

test_that("precision='mins' : format HHhMM (zéro-rempli), jours si > 0", {
  expect_identical(fct_convert_time_labels(0, "mins"), "00h00")
  expect_identical(fct_convert_time_labels(59, "mins"), "00h59")
  expect_identical(fct_convert_time_labels(60, "mins"), "01h00")
  expect_identical(fct_convert_time_labels(61, "mins"), "01h01")
  expect_identical(fct_convert_time_labels(1440 + 5, "mins"), "1j00h05")
  expect_identical(fct_convert_time_labels(2*1440 + 125, "mins"), "2j02h05")
})

test_that("séparateurs personnalisés", {
  out <- fct_convert_time_labels(1500, "mins", sep_j = " j ", sep_h = " h ", sep_min = " min")
  expect_identical(out, "1 j 01 h 00 min")

  out2 <- fct_convert_time_labels(1500, "hours", sep_j = " jours ", sep_h = " heures ")
  expect_identical(out2, "1 jours 1 heures ")
})

test_that("vectorisation et longueur de sortie", {
  x <- c(45, 60, 75, 1445)
  out_m <- fct_convert_time_labels(x, "mins")
  expect_type(out_m, "character")
  expect_length(out_m, length(x))
  expect_identical(out_m, c("00h45", "01h00", "01h15", "1j00h05"))

  out_h <- fct_convert_time_labels(x, "hours", rounding = "round")
  expect_identical(out_h, c("1h", "1h", "1h", "1j0h"))
})

test_that("cas frontières minutes et jours", {
  expect_identical(fct_convert_time_labels(1439, "mins"), "23h59")
  expect_identical(fct_convert_time_labels(1440, "mins"), "1j00h00")
  expect_identical(fct_convert_time_labels(1441, "mins"), "1j00h01")
})
