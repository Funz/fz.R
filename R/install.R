#' Install the fz Python Package
#'
#' This function installs the fz Python package into a virtual environment
#' or conda environment managed by reticulate.
#'
#' @param method Installation method. Either "auto", "virtualenv", or "conda".
#' @param conda Path to conda executable. Only used when method is "conda".
#' @param pip Logical; use pip for installation? Default is TRUE.
#' @param ... Additional arguments passed to [reticulate::py_install()].
#'
#' @return NULL (invisibly). Called for side effects.
#'
#' @export
#' @importFrom reticulate py_install
#'
#' @examples
#' \dontrun{
#' # Install fz in a virtual environment
#' fz_install()
#'
#' # Install in a conda environment
#' fz_install(method = "conda")
#' }
fz_install <- function(method = "auto", conda = "auto", pip = TRUE, ...) {
  reticulate::py_install("fz", method = method, conda = conda, pip = pip, ...)
}

#' Check if fz Python Package is Available
#'
#' Checks whether the fz Python package is available in the current
#' Python environment.
#'
#' @return Logical; TRUE if fz is available, FALSE otherwise.
#'
#' @export
#' @importFrom reticulate py_module_available
#'
#' @examples
#' \dontrun{
#' if (fz_available()) {
#'   message("fz is available!")
#' } else {
#'   message("Please install fz with fz_install()")
#' }
#' }
fz_available <- function() {
  reticulate::py_module_available("fz")
}
