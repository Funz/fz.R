# fzd(model = <R function>, calculators = N) must always be forced to
# calculators = 1 before being forwarded to the fz (Python) module, since R
# functions bridged in via reticulate are only safe to call from the main
# thread. On the fz side, calculators > 1 now genuinely dispatches evaluations
# to a worker-thread pool (Funz/fz#73) for ordinary Python functions, so this
# R-side safeguard is what prevents R-function models from crashing the R
# session when a caller passes calculators > 1.

make_capturing_fz_module <- function(captured) {
  list(
    fzd = function(input_path, input_variables, model, output_expression, algorithm,
                    calculators, algorithm_options, analysis_dir,
                    input_static = NULL) {
      captured$calculators <- calculators
      list(summary = "ok")
    }
  )
}

a_dummy_r_function <- function(x, y) list(z = x + y)

test_that("fzd forces calculators to 1 (with a warning) for an R function model when > 1 requested", {
  captured <- new.env()
  testthat::local_mocked_bindings(get_fz = function() make_capturing_fz_module(captured))

  expect_warning(
    result <- fzd(
      input_path = NULL,
      input_variables = list(x = "[0;1]", y = "[0;1]"),
      model = a_dummy_r_function,
      output_expression = "z",
      algorithm = "algorithms/randomsampling.py",
      calculators = 4L
    ),
    "forced to 1"
  )

  expect_equal(captured$calculators, 1L)
  expect_equal(result$summary, "ok")
})

test_that("fzd does not warn and uses calculators = 1 when omitted for an R function model", {
  captured <- new.env()
  testthat::local_mocked_bindings(get_fz = function() make_capturing_fz_module(captured))

  expect_no_warning(
    fzd(
      input_path = NULL,
      input_variables = list(x = "[0;1]", y = "[0;1]"),
      model = a_dummy_r_function,
      output_expression = "z",
      algorithm = "algorithms/randomsampling.py"
    )
  )

  expect_equal(captured$calculators, 1L)
})

test_that("fzd does not warn when calculators = 1 is explicitly passed for an R function model", {
  captured <- new.env()
  testthat::local_mocked_bindings(get_fz = function() make_capturing_fz_module(captured))

  expect_no_warning(
    fzd(
      input_path = NULL,
      input_variables = list(x = "[0;1]", y = "[0;1]"),
      model = a_dummy_r_function,
      output_expression = "z",
      algorithm = "algorithms/randomsampling.py",
      calculators = 1L
    )
  )

  expect_equal(captured$calculators, 1L)
})

test_that("fzd rejects a non-scalar/non-numeric calculators for an R function model", {
  captured <- new.env()
  testthat::local_mocked_bindings(get_fz = function() make_capturing_fz_module(captured))

  expect_error(
    fzd(
      input_path = NULL,
      input_variables = list(x = "[0;1]"),
      model = function(x) list(y = x),
      output_expression = "y",
      algorithm = "algorithms/randomsampling.py",
      calculators = c(1L, 2L)
    ),
    "single integer"
  )

  expect_error(
    fzd(
      input_path = NULL,
      input_variables = list(x = "[0;1]"),
      model = function(x) list(y = x),
      output_expression = "y",
      algorithm = "algorithms/randomsampling.py",
      calculators = "sh://"
    ),
    "single integer"
  )
})

test_that("fzd forwards calculators unchanged for a file-based (non-function) model", {
  captured <- new.env()
  testthat::local_mocked_bindings(get_fz = function() make_capturing_fz_module(captured))

  expect_no_warning(
    fzd(
      input_path = "input.txt",
      input_variables = list(x = "[0;1]"),
      model = list(output = list(y = "cat output.txt")),
      output_expression = "y",
      algorithm = "algorithms/randomsampling.py",
      calculators = 4L
    )
  )

  expect_equal(captured$calculators, 4L)
})
