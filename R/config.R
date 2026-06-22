#' Get the Current Interpreter
#'
#' Returns the global formula interpreter used when evaluating formula
#' expressions inside template files (e.g. \code{"python"} or \code{"R"}).
#'
#' @return Character string naming the current interpreter.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   get_interpreter()
#' }
#' }
get_interpreter <- function() {
  get_fz()$get_interpreter()
}

#' Set the Interpreter
#'
#' Sets the global formula interpreter for evaluating expressions inside
#' template files.
#'
#' @param interpreter Character string: \code{"python"} or \code{"R"}.
#'
#' @return NULL (invisibly). Called for side effects.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   set_interpreter("R")
#'   set_interpreter("python")
#' }
#' }
set_interpreter <- function(interpreter) {
  get_fz()$set_interpreter(interpreter)
}

#' Get the Current Log Level
#'
#' Returns the current logging verbosity level.
#'
#' @return A log-level value (use \code{as.character()} to convert to a string
#'   such as \code{"DEBUG"}, \code{"INFO"}, \code{"WARNING"}, \code{"ERROR"}).
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   as.character(get_log_level())
#' }
#' }
get_log_level <- function() {
  get_fz()$get_log_level()
}

#' Set the Log Level
#'
#' Controls how much output fz emits during execution.
#'
#' @param level Character string or log-level object: one of \code{"DEBUG"},
#'   \code{"INFO"}, \code{"WARNING"}, \code{"ERROR"}.
#'
#' @return NULL (invisibly). Called for side effects.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   set_log_level("DEBUG")
#'   set_log_level("WARNING")
#'   set_log_level("ERROR")
#' }
#' }
set_log_level <- function(level) {
  get_fz()$set_log_level(level)
}

#' Get the Global Configuration
#'
#' Returns the fz configuration object. Values are controlled by environment
#' variables such as \code{FZ_LOG_LEVEL}, \code{FZ_MAX_WORKERS},
#' \code{FZ_MAX_RETRIES}, and \code{FZ_SHELL_PATH}.
#'
#' @return A Python \code{Config} object. Access fields with \code{$}, e.g.
#'   \code{get_config()$max_workers}.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   cfg <- get_config()
#'   cfg$max_workers
#'   cfg$max_retries
#' }
#' }
get_config <- function() {
  get_fz()$get_config()
}

#' Print the Current Configuration
#'
#' Prints all fz configuration values in a human-readable format, including
#' which settings come from environment variables.
#'
#' @return NULL (invisibly). Called for side effects.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   print_config()
#' }
#' }
print_config <- function() {
  get_fz()$print_config()
}

#' Reload Configuration from Environment Variables
#'
#' Re-reads all \code{FZ_*} environment variables and updates the live
#' configuration. Useful after changing environment variables within the
#' session.
#'
#' @return NULL (invisibly). Called for side effects.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   Sys.setenv(FZ_MAX_WORKERS = "8")
#'   reload_config()
#'   get_config()$max_workers
#' }
#' }
reload_config <- function() {
  get_fz()$reload_config()
}
