test_that("the requirement follows the R package's major.minor", {
  expect_equal(fz_python_requirement("2.0.0"), "funz-fz>=2.0,<2.1")
  expect_equal(fz_python_requirement("2.0.3"), "funz-fz>=2.0,<2.1")
  expect_equal(fz_python_requirement("2.1.0"), "funz-fz>=2.1,<2.2")
  expect_equal(fz_python_requirement("3.9.1"), "funz-fz>=3.9,<3.10")
})

test_that("the default requirement matches the installed R package", {
  v <- unlist(utils::packageVersion("fz"))
  expect_match(
    fz_python_requirement(),
    sprintf("funz-fz>=%d.%d,", v[1], v[2]),
    fixed = TRUE
  )
})

test_that("fz_install() installs the matching version by default", {
  expect_identical(
    formals(fz_install)$packages,
    quote(fz_python_requirement())
  )
})

test_that("an installed funz-fz is in sync on the same major.minor only", {
  expect_true(fz_python_in_sync("2.0", "2.0.0"))
  expect_true(fz_python_in_sync("2.0.1", "2.0.0"))
  expect_true(fz_python_in_sync("2.0", "2.0.5"))
  expect_true(fz_python_in_sync("2.0.dev1", "2.0.0"))
  expect_false(fz_python_in_sync("1.2", "2.0.0"))
  expect_false(fz_python_in_sync("2.1", "2.0.0"))
  expect_false(fz_python_in_sync("3.0", "2.0.0"))
  expect_false(fz_python_in_sync("unknown", "2.0.0"))
})

test_that("nothing is declared nor checked under R CMD check", {
  saved <- Sys.getenv("_R_CHECK_PACKAGE_NAME_", unset = NA)
  on.exit({
    if (is.na(saved)) {
      Sys.unsetenv("_R_CHECK_PACKAGE_NAME_")
    } else {
      Sys.setenv("_R_CHECK_PACKAGE_NAME_" = saved)
    }
  })

  Sys.setenv("_R_CHECK_PACKAGE_NAME_" = "fz")
  expect_true(fz_is_checking())
  # returns before touching Python, so it cannot warn nor prompt
  expect_silent(fz_sync_python())

  Sys.unsetenv("_R_CHECK_PACKAGE_NAME_")
  expect_false(fz_is_checking())
})

test_that("options(fz.sync_python = FALSE) disables the check", {
  old <- options(fz.sync_python = FALSE)
  on.exit(options(old))
  expect_silent(fz_sync_python())
})
