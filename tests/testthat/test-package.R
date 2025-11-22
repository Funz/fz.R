test_that("package loads successfully", {
  expect_true(require("fz", quietly = TRUE))
})

test_that("package has correct metadata", {
  desc <- packageDescription("fz")
  expect_equal(desc$Package, "fz")
  expect_true(!is.null(desc$Version))
  expect_true(!is.null(desc$Title))
})
