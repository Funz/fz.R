#' fzi Function
#'
#' Parses input file(s) to find variables, formulas, and static objects.
#'
#' @param input_path Path to input file or directory.
#' @param model Model definition dict or alias string.
#'
#' @return Named list with variable names and their default values (or NULL).
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   tf <- tempfile(fileext = ".txt")
#'   writeLines(c("pressure = ${P~1.013}", "volume = ${V~22.4}"), tf)
#'
#'   model <- list(varprefix = "$", delim = "{}", formulaprefix = "@",
#'                 commentline = "#")
#'
#'   vars <- fzi(tf, model)
#' }
#' }
fzi <- function(input_path, model) {
  fz_module <- get_fz()
  fz_module$fzi(input_path, model)
}

#' fzc Function
#'
#' Compiles input file(s) by replacing variable placeholders with values.
#' Each unique combination of values is written to its own subdirectory inside
#' \code{output_dir}, named \code{var1=val1,var2=val2,...}.
#'
#' @param input_path Path to input file or directory.
#' @param input_variables Named list of variable values. Supply a vector of
#'   values to generate a full-factorial grid across variables.
#' @param model Model definition dict or alias string.
#' @param output_dir Output directory for compiled files. Default \code{"output"}.
#'
#' @return NULL (invisibly). Called for side effects.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   tf <- tempfile(fileext = ".txt")
#'   writeLines(c("P = ${P~1.013}", "V = ${V~22.4}"), tf)
#'
#'   model <- list(varprefix = "$", delim = "{}", formulaprefix = "@",
#'                 commentline = "#")
#'   out <- tempfile()
#'
#'   fzc(tf, list(P = 2.0, V = 11.2), model, out)
#'   fzc(tf, list(P = c(1.0, 2.0), V = c(11.2, 22.4)), model, out)
#' }
#' }
fzc <- function(input_path, input_variables, model, output_dir = "output") {
  fz_module <- get_fz()
  fz_module$fzc(input_path, input_variables, model, output_dir)
}

#' fzo Function
#'
#' Reads and parses output file(s) according to the model's output commands.
#' Each matched directory is processed independently; the results are combined
#' into a single list or data frame.
#'
#' @param output_path Path or glob pattern matching one or more output
#'   directories. Subdirectories within matched directories are not processed.
#' @param model Model definition dict or alias string.
#'
#' @return Named list or data frame of parsed output values.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   out_dir <- file.path(tempdir(), "P=2,V=11.2")
#'   dir.create(out_dir, recursive = TRUE)
#'   writeLines("result = 42", file.path(out_dir, "output.txt"))
#'
#'   model <- list(
#'     varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#",
#'     output = list(result = "grep 'result' output.txt | cut -d= -f2")
#'   )
#'
#'   values <- fzo(out_dir, model)
#' }
#' }
fzo <- function(output_path, model) {
  fz_module <- get_fz()
  fz_module$fzo(output_path, model)
}

#' fzr Function
#'
#' Runs full parametric calculations over an input template.
#' fzr combines \code{\link{fzc}}, calculator execution, and
#' \code{\link{fzo}} into a single call: it compiles the template for every
#' parameter combination, runs the model via the calculator(s), and collects
#' all outputs into a data frame.
#'
#' @param input_path Path to input file or directory.
#' @param input_variables Named list of variable values (or vectors of values
#'   for a full-factorial grid), or a data frame where each row is one case.
#' @param model Model definition dict or alias string.
#' @param results_dir Results directory. Default \code{"results"}.
#' @param calculators Calculator specification(s). Strings of the form
#'   \code{"sh://<command>"} run a local shell command;
#'   \code{"ssh://user\@host"} runs over SSH;
#'   \code{NULL} auto-detects installed calculators.
#' @param callbacks Optional named list of callback functions.
#' @param timeout Timeout in seconds per case. Default \code{NULL} (no timeout).
#'
#' @return Data frame (or named list) with one row per case and columns for
#'   each input variable and output quantity.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   tf <- tempfile(fileext = ".sh")
#'   writeLines(c(
#'     "#!/bin/sh",
#'     "echo result = $(( ${x~0} + ${y~0} )) > output.txt"
#'   ), tf)
#'
#'   model <- list(
#'     varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#",
#'     output = list(result = "grep result output.txt | cut -d= -f2")
#'   )
#'
#'   results <- fzr(tf, list(x = c(1L, 2L), y = 3L), model,
#'                  calculators = "sh://bash input.sh")
#' }
#' }
fzr <- function(input_path, input_variables, model,
                results_dir = "results", calculators = NULL,
                callbacks = NULL, timeout = NULL) {
  fz_module <- get_fz()
  fz_module$fzr(input_path, input_variables, model,
                results_dir = results_dir,
                calculators = calculators,
                callbacks = callbacks,
                timeout = timeout)
}

#' fzl Function
#'
#' Lists installed models and available calculators.
#'
#' @param models Pattern to match models. Default \code{"*"} for all.
#'   Accepts glob patterns (\code{"my*"}) or plain alias names.
#' @param calculators Pattern to match calculators. Default \code{"*"} for all.
#' @param check Logical; probe each calculator to verify it is reachable.
#'   Default \code{FALSE}.
#'
#' @return Named list with two entries:
#'   \describe{
#'     \item{models}{Named list of installed model definitions.}
#'     \item{calculators}{Named list of available calculators.}
#'   }
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   info <- fzl()
#'   names(info$models)
#'   names(info$calculators)
#'
#'   info <- fzl(models = "Perfect*")
#'   info <- fzl(check = TRUE)
#' }
#' }
fzl <- function(models = "*", calculators = "*", check = FALSE) {
  fz_module <- get_fz()
  fz_module$fzl(models = models, calculators = calculators, check = check)
}

#' fzd Function
#'
#' Runs an iterative design of experiments driven by an algorithm.
#' Unlike \code{\link{fzr}} (which evaluates a fixed grid), \code{fzd} lets an
#' algorithm adaptively choose which parameter combinations to evaluate, which
#' is useful for sensitivity analysis, surrogate-model fitting, or optimization.
#'
#' @param input_path Path to input file or directory. Must be \code{NULL} when
#'   \code{model} is an R function (see "Direct function model" below).
#' @param input_variables Named list of variable range strings of the form
#'   \code{"[min;max]"}, e.g. \code{list(x = "[0;1]", y = "[-5;5]")}.
#' @param model Model definition dict or alias string, or an R function (see
#'   "Direct function model" below).
#' @param output_expression Expression evaluated on the model outputs to
#'   produce the scalar quantity the algorithm optimizes or analyses,
#'   e.g. \code{"result"} or \code{"out1 + 2 * out2"}. May be \code{NULL}
#'   only when \code{model} is a function, in which case the first output
#'   value is used.
#' @param algorithm Path to the algorithm Python file, e.g.
#'   \code{"algorithms/montecarlo_uniform.py"}.
#' @param calculators Calculator specification(s). Default \code{NULL}. When
#'   \code{model} is a function, this must be a single integer (default
#'   \code{1L}), accepted for API compatibility (see "Direct function model"
#'   below) — calls are always run sequentially regardless of its value.
#' @param algorithm_options Algorithm options as a named list, a JSON string,
#'   or a path to a JSON file. Default \code{NULL}.
#' @param analysis_dir Analysis directory. Default \code{"analysis"}.
#'
#' @section Direct function model:
#' Instead of a file-based model, \code{model} can be an R function (this
#' requires the \code{main} branch of \code{fz} from GitHub, installed with
#' \code{fz_install(packages = "git+https://github.com/Funz/fz.git")} — this
#' mode is not available in released PyPI versions of \code{funz-fz} yet). In
#' this mode:
#' \itemize{
#'   \item \code{input_path} must be \code{NULL} — there are no input files.
#'   \item \code{input_variables} names must match the function's arguments.
#'   \item \code{output_expression} may be \code{NULL}; the value used is then
#'     the first element of the function's return value (its return value
#'     directly if scalar, the first element if a vector/list, or the first
#'     entry's value if a named list).
#'   \item \code{calculators} must be a single integer, accepted for API
#'     compatibility but currently without effect: on the \code{fz} side,
#'     function-model calls always run sequentially, one at a time in the
#'     calling thread — never through a thread pool. This is required
#'     because R functions are called back into the R session via
#'     \code{reticulate}, which is only safe from the main thread; running
#'     a Python-side thread pool (which always dispatches to a worker thread,
#'     even with a single worker) would call the function from a thread
#'     other than the main one and crash the R session. This safety fix
#'     requires \href{https://github.com/Funz/fz/pull/73}{Funz/fz#73} on the
#'     \code{fz} \code{main} branch (not yet in a PyPI release as of
#'     2026-07-12); without it, direct function models crash regardless of
#'     \code{calculators}. A value other than \code{1} emits a warning
#'     noting that it has no effect.
#'   \item each iteration's directory (\code{iterNNN/}) only contains a
#'     \code{values.csv} of that iteration's function inputs/outputs, since
#'     there is no file-based execution.
#' }
#'
#' @return Named list with the analysis results produced by the algorithm.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   tf <- tempfile(fileext = ".txt")
#'   writeLines(c("x = ${x~0}", "y = ${y~0}"), tf)
#'
#'   model <- list(
#'     varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#",
#'     output = list(z = "grep z output.txt | cut -d= -f2")
#'   )
#'
#'   result <- fzd(
#'     tf,
#'     list(x = "[0;1]", y = "[-5;5]"),
#'     model,
#'     output_expression = "z",
#'     algorithm        = "algorithms/montecarlo_uniform.py",
#'     algorithm_options = list(batch_sample_size = 10, max_iterations = 3)
#'   )
#' }
#' }
#'
#' \dontrun{
#' # Direct function model (requires fz main branch from GitHub)
#' rosenbrock <- function(x, y) {
#'   list(result = (1 - x)^2 + 100 * (y - x^2)^2)
#' }
#'
#' result <- fzd(
#'   input_path = NULL,
#'   input_variables = list(x = "[-2;2]", y = "[-2;2]"),
#'   model = rosenbrock,
#'   output_expression = "result",
#'   algorithm = "examples/algorithms/bfgs.py",
#'   calculators = 4L,
#'   algorithm_options = list(max_iter = 20, tol = 1e-4)
#' )
#' }
fzd <- function(input_path, input_variables, model, output_expression = NULL, algorithm,
                calculators = NULL, algorithm_options = NULL,
                analysis_dir = "analysis") {
  if (is.function(model)) {
    if (is.null(calculators)) {
      calculators <- 1L
    } else if (!is.numeric(calculators) || length(calculators) != 1) {
      stop(
        "When 'model' is an R function, 'calculators' must be a single integer.",
        call. = FALSE
      )
    }
    calculators <- as.integer(calculators)
    if (calculators != 1L) {
      warning(
        "calculators = ", calculators, " has no effect when 'model' is an R ",
        "function: evaluations always run sequentially (one call at a time), ",
        "since R functions bridged in via reticulate are only safe to call ",
        "from the main thread.",
        call. = FALSE
      )
    }
  }
  fz_module <- get_fz()
  fz_module$fzd(input_path, input_variables, model, output_expression, algorithm,
                calculators = calculators,
                algorithm_options = algorithm_options,
                analysis_dir = analysis_dir)
}
