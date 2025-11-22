test_that("fz function exists and is callable", {
  expect_true(is.function(fz))
})

test_that("fzi function exists and is callable", {
  expect_true(is.function(fzi))
})

test_that("fzc function exists and is callable", {
  expect_true(is.function(fzc))
})

test_that("fzo function exists and is callable", {
  expect_true(is.function(fzo))
})

test_that("fzd function exists and is callable", {
  expect_true(is.function(fzd))
})

test_that("core functions fail gracefully when fz not installed", {
  skip_if(fz_available(), "fz is installed, skipping unavailability test")

  expect_error(fz(), "fz.*not available")
  expect_error(fzi(), "fz.*not available")
  expect_error(fzc(), "fz.*not available")
  expect_error(fzo(), "fz.*not available")
  expect_error(fzd(), "fz.*not available")
})

# Integration tests - only run if fz is available
test_that("fz function can be called when fz is available", {
  skip_if_not(fz_available(), "fz Python package not available")

  # Test that the function can at least be called
  # Actual behavior depends on fz implementation
  expect_error(fz(), NA,
               info = "fz() should be callable without error when package is available")
})

test_that("fzi function can be called when fz is available", {
  skip_if_not(fz_available(), "fz Python package not available")

  expect_error(fzi(), NA,
               info = "fzi() should be callable without error when package is available")
})

test_that("fzc function can be called when fz is available", {
  skip_if_not(fz_available(), "fz Python package not available")

  expect_error(fzc(), NA,
               info = "fzc() should be callable without error when package is available")
})

test_that("fzo function can be called when fz is available", {
  skip_if_not(fz_available(), "fz Python package not available")

  expect_error(fzo(), NA,
               info = "fzo() should be callable without error when package is available")
})

test_that("fzd function can be called when fz is available", {
  skip_if_not(fz_available(), "fz Python package not available")

  expect_error(fzd(), NA,
               info = "fzd() should be callable without error when package is available")
})
