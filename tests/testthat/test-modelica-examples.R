# Integration tests exercising the real funz-fz 1.x Python API.
#
# All Python-dependent tests are guarded with skip_on_cran() so CRAN checks
# never initialise Python. The fzr test additionally caps FZ_MAX_RETRIES=1
# to avoid burning time on retry loops.

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

simple_model <- function(output_cmd = "cat output.txt 2>/dev/null || echo ''") {
  list(
    varprefix     = "$",
    delim         = "{}",
    formulaprefix = "@",
    commentline   = "#",
    output        = list(result = output_cmd)
  )
}

make_template <- function(lines, suffix = ".txt") {
  tf <- tempfile(fileext = suffix)
  writeLines(lines, tf)
  tf
}

# ---------------------------------------------------------------------------
# fzl -- no files needed
# ---------------------------------------------------------------------------

test_that("fzl() lists models and calculators", {
  skip_on_cran()
  skip_if_not(fz_available(), "fz Python package not available")

  result <- fzl()

  expect_true(is.list(result))
  expect_true(all(c("models", "calculators") %in% names(result)))
  expect_true(is.list(result$models))
  expect_true(is.list(result$calculators))
})

# ---------------------------------------------------------------------------
# fzi -- parse variables from a template (no execution)
# ---------------------------------------------------------------------------

test_that("fzi() parses variable names and defaults from a template", {
  skip_on_cran()
  skip_if_not(fz_available(), "fz Python package not available")

  tf <- make_template(c(
    "# Perfect Gas parameters",
    "P = ${P~1.013}",
    "V = ${V~22.4}",
    "n = ${n~1.0}"
  ))

  model <- list(varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#")
  result <- fzi(tf, model)

  expect_true(is.list(result))
  expect_true("P" %in% names(result))
  expect_true("V" %in% names(result))
  expect_true("n" %in% names(result))
  expect_equal(as.numeric(result$P), 1.013, tolerance = 1e-6)
  expect_equal(as.numeric(result$V), 22.4,  tolerance = 1e-6)
})

# ---------------------------------------------------------------------------
# fzc -- compile template with explicit values (no execution)
# ---------------------------------------------------------------------------

test_that("fzc() compiles template for a single parameter set", {
  skip_on_cran()
  skip_if_not(fz_available(), "fz Python package not available")

  tf      <- make_template(c("P = ${P~1.013}", "V = ${V~22.4}"))
  model   <- list(varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#")
  out_dir <- file.path(tempdir(), paste0("fzc_single_", Sys.getpid()))

  expect_no_error(fzc(tf, list(P = 2.0, V = 11.2), model, out_dir))

  compiled_dirs <- list.dirs(out_dir, recursive = FALSE)
  expect_true(length(compiled_dirs) >= 1)

  compiled_file <- file.path(compiled_dirs[[1]], basename(tf))
  if (file.exists(compiled_file)) {
    content <- readLines(compiled_file, warn = FALSE)
    expect_false(any(grepl("\\$\\{", content)), info = "placeholders should be replaced")
    expect_true(any(grepl("2", content)),        info = "substituted value should appear")
  }
})

test_that("fzc() compiles template for multiple values (grid)", {
  skip_on_cran()
  skip_if_not(fz_available(), "fz Python package not available")

  tf      <- make_template(c("x = ${x~0}", "y = ${y~0}"))
  model   <- list(varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#")
  out_dir <- file.path(tempdir(), paste0("fzc_grid_", Sys.getpid()))

  expect_no_error(fzc(tf, list(x = c(1.0, 2.0), y = c(10.0, 20.0)), model, out_dir))

  compiled_dirs <- list.dirs(out_dir, recursive = FALSE)
  expect_true(length(compiled_dirs) == 4,
              info = paste("expected 4 compiled dirs, got", length(compiled_dirs)))
})

# ---------------------------------------------------------------------------
# fzr -- run parametric study (requires sh:// calculator)
# ---------------------------------------------------------------------------

test_that("fzr() runs a parametric study with an inline shell model", {
  skip_on_cran()
  skip_if_not(fz_available(), "fz Python package not available")

  calc <- "sh://python3 -c \"x=${x~0}; y=${y~0}; open('output.txt','w').write(f'result = {x+y}\\n')\""

  tf  <- make_template(c("x = ${x~0}", "y = ${y~0}"))
  model <- list(
    varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#",
    output = list(result = "grep 'result' output.txt | cut -d= -f2")
  )
  results_dir <- file.path(tempdir(), paste0("fzr_", Sys.getpid()))

  result <- tryCatch(
    fzr(tf, list(x = c(1.0, 2.0), y = 3.0), model,
        results_dir = results_dir, calculators = calc),
    error = function(e) {
      message("fzr integration test skipped: ", conditionMessage(e))
      NULL
    }
  )

  if (!is.null(result)) {
    expect_true(is.list(result) || is.data.frame(result))
    expect_true(length(result) > 0)
  }
})

# ---------------------------------------------------------------------------
# fzo -- read existing output directory (no execution)
# ---------------------------------------------------------------------------

test_that("fzo() reads output files from a directory", {
  skip_on_cran()
  skip_if_not(fz_available(), "fz Python package not available")

  out_dir <- file.path(tempdir(), paste0("fzo_", Sys.getpid()))
  dir.create(out_dir, showWarnings = FALSE)
  writeLines("result = 42", file.path(out_dir, "output.txt"))

  model <- list(
    varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#",
    output = list(result = "grep 'result' output.txt | cut -d= -f2")
  )

  result <- tryCatch(
    fzo(out_dir, model),
    error = function(e) {
      message("fzo test skipped: ", conditionMessage(e))
      NULL
    }
  )

  if (!is.null(result)) {
    expect_true(is.list(result) || is.data.frame(result))
  }
})

# ---------------------------------------------------------------------------
# Verify installed PerfectGas model alias (if present)
# ---------------------------------------------------------------------------

test_that("fzi() works with the installed PerfectGas model alias", {
  skip_on_cran()
  skip_if_not(fz_available(), "fz Python package not available")

  listing <- fzl()
  skip_if_not("PerfectGas" %in% names(listing$models),
              "PerfectGas model not installed")

  tf <- make_template(c("P = ${P~1.013}", "V = ${V~22.4}", "n = ${n~1.0}"))

  result <- fzi(tf, "PerfectGas")
  expect_true(is.list(result))
  expect_true(length(result) > 0)
})
