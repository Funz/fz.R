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
#' \dontrun{
#' if (fz_available()) {
#'   # Write a template with two variables and their defaults
#'   tf <- tempfile(fileext = ".txt")
#'   writeLines(c("pressure = ${P~1.013}", "volume = ${V~22.4}"), tf)
#'
#'   model <- list(varprefix = "$", delim = "{}", formulaprefix = "@",
#'                 commentline = "#")
#'
#'   vars <- fzi(tf, model)
#'   # vars$P == 1.013, vars$V == 22.4
#'
#'   # Using an installed model alias instead of an inline dict:
#'   # vars <- fzi(tf, "PerfectGas")
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
#' \dontrun{
#' if (fz_available()) {
#'   tf <- tempfile(fileext = ".txt")
#'   writeLines(c("P = ${P~1.013}", "V = ${V~22.4}"), tf)
#'
#'   model <- list(varprefix = "$", delim = "{}", formulaprefix = "@",
#'                 commentline = "#")
#'   out <- tempfile()
#'
#'   # Single case: one compiled directory P=2,V=11.2
#'   fzc(tf, list(P = 2.0, V = 11.2), model, out)
#'
#'   # Grid: 2 x 2 = 4 compiled directories
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
#' \dontrun{
#' if (fz_available()) {
#'   # After running a simulation that wrote "result = 42" to output.txt:
#'   out_dir <- "my_results/P=2,V=11.2"
#'
#'   model <- list(
#'     varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#",
#'     output = list(result = "grep 'result' output.txt | cut -d= -f2")
#'   )
#'
#'   values <- fzo(out_dir, model)
#'   # values$result == "42"
#'
#'   # Glob to read all cases at once:
#'   # values <- fzo("my_results/*", model)
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
#' \dontrun{
#' if (fz_available()) {
#'   # Template: shell script that writes sum of x and y
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
#'   # Two values of x, one value of y -> 2 cases
#'   results <- fzr(tf, list(x = c(1L, 2L), y = 3L), model,
#'                  calculators = "sh://bash input.sh")
#'   # results is a data frame with columns x, y, result
#'
#'   # Using an installed model alias:
#'   # results <- fzr("input.txt", list(P = c(1, 2, 3)), "PerfectGas")
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
#' \dontrun{
#' if (fz_available()) {
#'   # List everything
#'   info <- fzl()
#'   names(info$models)       # e.g. c("PerfectGas", "Moret")
#'   names(info$calculators)  # e.g. c("sh://")
#'
#'   # Check only models whose name starts with "Perfect"
#'   info <- fzl(models = "Perfect*")
#'
#'   # Probe calculators to verify they are reachable
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
#' @param input_path Path to input file or directory.
#' @param input_variables Named list of variable range strings of the form
#'   \code{"[min;max]"}, e.g. \code{list(x = "[0;1]", y = "[-5;5]")}.
#' @param model Model definition dict or alias string.
#' @param output_expression Expression evaluated on the model outputs to
#'   produce the scalar quantity the algorithm optimizes or analyses,
#'   e.g. \code{"result"} or \code{"out1 + 2 * out2"}.
#' @param algorithm Path to the algorithm Python file, e.g.
#'   \code{"algorithms/montecarlo_uniform.py"}.
#' @param calculators Calculator specification(s). Default \code{NULL}.
#' @param algorithm_options Algorithm options as a named list or
#'   semicolon-separated string, e.g. \code{"batch_sample_size=10;seed=42"}.
#'   Default \code{NULL}.
#' @param analysis_dir Analysis directory. Default \code{"analysis"}.
#'
#' @return Named list with the analysis results produced by the algorithm.
#' @export
#'
#' @examples
#' \dontrun{
#' if (fz_available()) {
#'   tf <- tempfile(fileext = ".txt")
#'   writeLines(c("x = ${x~0}", "y = ${y~0}"), tf)
#'
#'   model <- list(
#'     varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#",
#'     output = list(z = "grep z output.txt | cut -d= -f2")
#'   )
#'
#'   # Run 30 Monte Carlo samples over x in [0,1] and y in [-5,5]
#'   result <- fzd(
#'     tf,
#'     list(x = "[0;1]", y = "[-5;5]"),
#'     model,
#'     output_expression = "z",
#'     algorithm        = "algorithms/montecarlo_uniform.py",
#'     algorithm_options = "batch_sample_size=10;max_iterations=3"
#'   )
#' }
#' }
fzd <- function(input_path, input_variables, model, output_expression, algorithm,
                calculators = NULL, algorithm_options = NULL,
                analysis_dir = "analysis") {
  fz_module <- get_fz()
  fz_module$fzd(input_path, input_variables, model, output_expression, algorithm,
                calculators = calculators,
                algorithm_options = algorithm_options,
                analysis_dir = analysis_dir)
}
