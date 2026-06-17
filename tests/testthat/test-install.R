test_that("fz_available returns logical", {
  skip_on_cran()
  result <- fz_available()
  expect_type(result, "logical")
  expect_length(result, 1)
})

test_that("fz_install has correct signature", {
  # Just check that the function exists and has expected parameters
  expect_true(is.function(fz_install))

  # Check function formals
  args <- names(formals(fz_install))
  expect_true("method" %in% args)
  expect_true("conda" %in% args)
  expect_true("pip" %in% args)
})
