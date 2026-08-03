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
#'   \code{1L}) and is always forced to \code{1L} (see "Direct function
#'   model" below): R functions are only safe to call from the main thread,
#'   so a value other than \code{1} triggers a warning and is overridden.
#' @param algorithm_options Algorithm options as a named list, a JSON string,
#'   or a path to a JSON file. Default \code{NULL}.
#' @param analysis_dir Analysis directory. Default \code{"analysis"}.
#'
#' @section Direct function model:
#' Instead of a file-based model, \code{model} can be an R function (this
#' requires the \code{main} branch of \code{fz} from GitHub, installed with
#' \code{fz_install(packages = "git+https://github.com/Funz/fz.git")} -- this
#' mode is not available in released PyPI versions of \code{funz-fz} yet). In
#' this mode:
#' \itemize{
#'   \item \code{input_path} must be \code{NULL} -- there are no input files.
#'   \item \code{input_variables} names must match the function's arguments.
#'   \item \code{output_expression} may be \code{NULL}; the value used is then
#'     the first element of the function's return value (its return value
#'     directly if scalar, the first element if a vector/list, or the first
#'     entry's value if a named list).
#'   \item \code{calculators} must be a single integer, but is always forced
#'     to \code{1} here -- regardless of the value passed in -- before being
#'     forwarded to \code{fz}. On the \code{fz} (Python) side,
#'     \code{calculators > 1} now evaluates a Python-function model
#'     concurrently in a worker-thread pool (\href{https://github.com/Funz/fz/pull/73}{Funz/fz#73});
#'     that is unsafe here because R functions are called back into the R
#'     session via \code{reticulate}, which is only safe from the main
#'     thread -- invoking the function from any other thread crashes the R
#'     session. Passing a value other than \code{1} therefore emits a
#'     warning explaining that it is being forced back to \code{1}, and the
#'     call always proceeds with \code{calculators = 1} (strictly
#'     sequential, one call at a time, in the calling thread).
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
#'   # A minimal self-contained random-sampling algorithm (see
#'   # https://github.com/Funz/fz for ready-made algorithms to install)
#'   algo <- tempfile(fileext = ".py")
#'   writeLines(c(
#'     "import random",
#'     "class RandomSampler:",
#'     "    def __init__(self, **options):",
#'     "        self.batch = int(options.get('batch_sample_size', 5))",
#'     "        self.max_iterations = int(options.get('max_iterations', 3))",
#'     "        self.iteration = 0",
#'     "        self.input_vars = {}",
#'     "    def get_initial_design(self, input_vars, output_vars):",
#'     "        self.input_vars = input_vars",
#'     "        self.iteration = 1",
#'     "        return [{k: random.uniform(*v) for k, v in input_vars.items()}",
#'     "                for _ in range(self.batch)]",
#'     "    def get_next_design(self, previous_input_vars, previous_output_values):",
#'     "        self.iteration += 1",
#'     "        if self.iteration > self.max_iterations:",
#'     "            return []",
#'     "        return [{k: random.uniform(*v) for k, v in self.input_vars.items()}",
#'     "                for _ in range(self.batch)]",
#'     "    def get_analysis(self, input_vars, output_values):",
#'     "        valid = [v for v in output_values if v is not None]",
#'     "        mean = sum(valid) / len(valid) if valid else None",
#'     "        return {'text': f'mean={mean}', 'data': {'mean': mean}}"
#'   ), algo)
#'
#'   result <- fzd(
#'     tf,
#'     list(x = "[0;1]", y = "[-5;5]"),
#'     model,
#'     output_expression = "z",
#'     algorithm        = algo,
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
#'   calculators = 1L, # forced to 1L anyway for R functions -- see "Direct function model"
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
        "calculators = ", calculators, " was requested but is forced to 1 ",
        "when 'model' is an R function: on the fz (Python) side, calculators > 1 ",
        "now evaluates the model concurrently in a worker-thread pool (see ",
        "https://github.com/Funz/fz#function-models), but R functions bridged in ",
        "via reticulate are only safe to call from the main thread -- calling them ",
        "from any other thread crashes the R session. calculators is therefore ",
        "always reset to 1 here, regardless of the requested value.",
        call. = FALSE
      )
      calculators <- 1L
    }
  }
  fz_module <- get_fz()
  fz_module$fzd(input_path, input_variables, model, output_expression, algorithm,
                calculators = calculators,
                algorithm_options = algorithm_options,
                analysis_dir = analysis_dir)
}
