#' Core fz Function
#'
#' Main fz function that wraps the Python fz.fz() function.
#'
#' @param ... Arguments passed to the Python fz.fz() function.
#'
#' @return The result from the Python fz.fz() function.
#' @export
#'
#' @examples
#' \dontrun{
#' if (fz_available()) {
#'   result <- fz()
#' }
#' }
fz <- function(...) {
  fz_module <- get_fz()
  fz_module$fz(...)
}

#' fzi Function
#'
#' Wraps the Python fz.fzi() function.
#'
#' @param ... Arguments passed to the Python fz.fzi() function.
#'
#' @return The result from the Python fz.fzi() function.
#' @export
#'
#' @examples
#' \dontrun{
#' if (fz_available()) {
#'   result <- fzi()
#' }
#' }
fzi <- function(...) {
  fz_module <- get_fz()
  fz_module$fzi(...)
}

#' fzc Function
#'
#' Wraps the Python fz.fzc() function.
#'
#' @param ... Arguments passed to the Python fz.fzc() function.
#'
#' @return The result from the Python fz.fzc() function.
#' @export
#'
#' @examples
#' \dontrun{
#' if (fz_available()) {
#'   result <- fzc()
#' }
#' }
fzc <- function(...) {
  fz_module <- get_fz()
  fz_module$fzc(...)
}

#' fzo Function
#'
#' Wraps the Python fz.fzo() function.
#'
#' @param ... Arguments passed to the Python fz.fzo() function.
#'
#' @return The result from the Python fz.fzo() function.
#' @export
#'
#' @examples
#' \dontrun{
#' if (fz_available()) {
#'   result <- fzo()
#' }
#' }
fzo <- function(...) {
  fz_module <- get_fz()
  fz_module$fzo(...)
}

#' fzd Function
#'
#' Wraps the Python fz.fzd() function.
#'
#' @param ... Arguments passed to the Python fz.fzd() function.
#'
#' @return The result from the Python fz.fzd() function.
#' @export
#'
#' @examples
#' \dontrun{
#' if (fz_available()) {
#'   result <- fzd()
#' }
#' }
fzd <- function(...) {
  fz_module <- get_fz()
  fz_module$fzd(...)
}
