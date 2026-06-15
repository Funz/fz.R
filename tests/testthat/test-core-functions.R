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
  skip_if(fz_available(), "fz is installed, skipping unavailability test")

  expect_error(fzl(), "fz.*not available")
  expect_error(fzi("f", list()), "fz.*not available")
})

test_that("fzl() returns installed models and calculators", {
  skip_if_not(fz_available(), "fz Python package not available")

  result <- fzl()
  expect_true(is.list(result))
  expect_true("models" %in% names(result))
  expect_true("calculators" %in% names(result))
})

test_that("fzi() parses variables from a template file", {
  skip_if_not(fz_available(), "fz Python package not available")

  tf <- tempfile(fileext = ".txt")
  writeLines(c("pressure = ${P~1.013}", "volume = ${V~22.4}"), tf)

  model <- list(varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#")
  result <- fzi(tf, model)

  expect_true(is.list(result))
  expect_true("P" %in% names(result))
  expect_true("V" %in% names(result))
})

test_that("fzc() compiles a template file with given values", {
  skip_if_not(fz_available(), "fz Python package not available")

  tf <- tempfile(fileext = ".txt")
  writeLines(c("pressure = ${P~1.013}", "volume = ${V~22.4}"), tf)

  model <- list(varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#")
  out_dir <- file.path(tempdir(), paste0("fzc_", Sys.getpid()))

  expect_no_error(fzc(tf, list(P = 2.0, V = 11.2), model, out_dir))

  # fzc writes compiled files into a subdirectory named var1=val1,var2=val2,...
  compiled_dirs <- list.dirs(out_dir, recursive = FALSE)
  expect_true(length(compiled_dirs) >= 1)
})
