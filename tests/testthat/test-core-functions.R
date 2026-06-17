test_that("fzi function exists and is callable", {
  expect_true(is.function(fzi))
})

test_that("fzc function exists and is callable", {
  expect_true(is.function(fzc))
})

test_that("fzo function exists and is callable", {
  expect_true(is.function(fzo))
})

test_that("fzr function exists and is callable", {
  expect_true(is.function(fzr))
})

test_that("fzl function exists and is callable", {
  expect_true(is.function(fzl))
})

test_that("fzd function exists and is callable", {
  expect_true(is.function(fzd))
})

test_that("core functions fail gracefully when fz not installed", {
  skip_on_cran()
  skip_if(fz_available(), "fz is installed, skipping unavailability test")

  expect_error(fzl(), "fz.*not available")
  expect_error(fzi("f", list()), "fz.*not available")
})
