# End-to-end test of the shipped external-simulator example
# (inst/examples/perfectgas/): a real Python program is run as the calculator
# for every case, and its output is collected by fzr().
#
# Guarded with skip_on_cran() so CRAN checks never initialise Python.

perfectgas_model <- function() {
  list(
    varprefix     = "$",
    delim         = "{}",
    formulaprefix = "@",
    commentline   = "#",
    output = list(
      pressure = 'python://grep(r"pressure = (\\S+)", "out.txt")'
    )
  )
}

test_that("the shipped perfectgas example runs end to end via an external simulator", {
  skip_on_cran()
  skip_if_not(fz_available(), "fz Python package not available")
  skip_if(Sys.which("python3") == "", "python3 not on PATH")

  ex <- system.file("examples", "perfectgas", package = "fz")
  expect_true(dir.exists(ex))
  expect_true(all(file.exists(file.path(ex, c("perfectgas.txt", "perfectgas.py")))))

  work <- file.path(tempfile("perfectgas-"))
  dir.create(work)
  file.copy(list.files(ex, full.names = TRUE), work)
  old_wd <- setwd(work)
  on.exit(setwd(old_wd), add = TRUE)

  # fzi finds exactly the three template variables
  vars <- fzi("perfectgas.txt", perfectgas_model())
  expect_setequal(names(vars), c("T", "V", "n"))

  results <- fzr(
    "perfectgas.txt",
    list(T = c(300, 350, 400), V = 1e-3, n = 1),
    perfectgas_model(),
    results_dir  = "results",
    calculators  = "sh://python3 perfectgas.py",
    input_static = "perfectgas.py"
  )

  expect_s3_class(results, "data.frame")
  expect_equal(nrow(results), 3)
  expect_true(all(c("T", "V", "n", "pressure") %in% names(results)))

  # P = n R T / V, with R = 8.314462618 J/(mol K)
  R <- 8.314462618
  expected <- 1 * R * results$T / 1e-3
  expect_equal(as.numeric(results$pressure), expected, tolerance = 1e-3)
})
