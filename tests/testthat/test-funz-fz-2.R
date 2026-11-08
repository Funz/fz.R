# Behaviour that depends on funz-fz >= 2.0, as seen through the R wrapper.
#
# Skipped on CRAN, when the Python side is missing, and when the installed
# funz-fz is older than 2.0 (e.g. before 2.0 reaches PyPI).

skip_unless_funz_fz_2 <- function() {
  skip_on_cran()
  skip_if_not(fz_available(), "fz Python package not available")
  version <- tryCatch(
    as.character(reticulate::py_get_attr(get_fz(), "__version__")),
    error = function(e) "0"
  )
  skip_if(
    utils::compareVersion(version, "2.0") < 0,
    paste0("needs funz-fz >= 2.0 (installed: ", version, ")")
  )
  skip_if(Sys.which("bash") == "", "bash not on PATH")
  version
}

# Creates a work directory holding a one-variable template and a bash
# calculator script; returns its path. The caller setwd()s into it.
new_fzr_case <- function() {
  work <- tempfile("fz2-")
  dir.create(work)
  writeLines("x = ${x}", file.path(work, "input.txt"))
  writeLines("cut -d= -f2 input.txt > out.txt", file.path(work, "run.sh"))
  work
}

fz2_model <- function() {
  list(
    varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#",
    output = list(y = "cat out.txt")
  )
}

test_that("timeout = 0 means no timeout (funz-fz >= 2.0)", {
  skip_unless_funz_fz_2()
  work <- new_fzr_case()
  old_wd <- setwd(work)
  on.exit({ setwd(old_wd); unlink(work, recursive = TRUE) }, add = TRUE)
  model <- fz2_model()

  results <- fzr("input.txt", list(x = c(1, 2)), model,
                 results_dir = "results",
                 calculators = "sh://bash run.sh",
                 timeout = 0)

  expect_equal(as.character(results$status), c("done", "done"))
  expect_equal(as.numeric(results$y), c(1, 2))
})

test_that("a negative timeout is rejected (funz-fz >= 2.0)", {
  skip_unless_funz_fz_2()
  work <- new_fzr_case()
  old_wd <- setwd(work)
  on.exit({ setwd(old_wd); unlink(work, recursive = TRUE) }, add = TRUE)
  model <- fz2_model()

  expect_error(
    fzr("input.txt", list(x = 1), model,
        results_dir = "results",
        calculators = "sh://bash run.sh",
        timeout = -1),
    "timeout must be >= 0"
  )
})

test_that("fzr() writes a manifest.json recording the funz-fz version", {
  version <- skip_unless_funz_fz_2()
  work <- new_fzr_case()
  old_wd <- setwd(work)
  on.exit({ setwd(old_wd); unlink(work, recursive = TRUE) }, add = TRUE)
  model <- fz2_model()

  fzr("input.txt", list(x = 1), model,
      results_dir = "results",
      calculators = "sh://bash run.sh")

  manifest <- file.path("results", "manifest.json")
  expect_true(file.exists(manifest))
  text <- paste(readLines(manifest, warn = FALSE), collapse = "\n")
  expect_match(text, paste0('"fz_version": "', version, '"'), fixed = TRUE)
})
