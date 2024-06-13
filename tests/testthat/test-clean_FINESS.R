test_that("clean_FINESS works", {
  expect_equal(clean_FINESS(c("10784320", "380000174")), c("010784320", "380000174"))
})

test_that("clean_FINESS error ok", {
  expect_error(clean_FINESS(c("10320", "380000174"), "FINESS should be 9 or 8 characters. Some occurences are different."))
  expect_error(clean_FINESS(c(380000174)), "char must be a character vector.")
})

