#' Install the fz Python Package
#'
#' This function installs the fz Python package into a virtual environment
#' or conda environment managed by reticulate.
#'
#' @param packages Package specification passed to [reticulate::py_install()].
#'   Default \code{"funz-fz"} installs the latest release from PyPI. To track
#'   unreleased features, install the latest \code{main} branch directly from
#'   GitHub with \code{"git+https://github.com/Funz/fz.git"}.
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
#'
#' # Track the latest main branch on GitHub (unreleased features)
#' fz_install(packages = "git+https://github.com/Funz/fz.git")
#' }
fz_install <- function(packages = "funz-fz", method = "auto", conda = "auto", pip = TRUE, ...) {
  reticulate::py_install(packages, method = method, conda = conda, pip = pip, ...)
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
#' \donttest{
#' if (fz_available()) {
#'   message("fz is available!")
#' } else {
#'   message("Please install fz with fz_install()")
#' }
#' }
fz_available <- function() {
  if (is.null(.pkg$fz_available)) {
    .pkg$fz_available <- reticulate::py_module_available("fz")
  }
  .pkg$fz_available
}

#' Install a Model
#'
#' Installs a model from a GitHub repository name, URL, or local zip file into
#' the user-level \code{~/.fz/models/} directory (or system-level when
#' \code{global = TRUE}).
#'
#' @param source GitHub name (e.g. \code{"Funz/Model-PerfectGas"}), URL, or
#'   path to a local zip file.
#' @param global Logical; install system-wide instead of user-level.
#'   Default \code{FALSE}.
#'
#' @return Named list with installation details (path, id, …).
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   install_model("Funz/Model-PerfectGas")
#' }
#' }
install_model <- function(source, global = FALSE) {
  fz_module <- get_fz()
  fz_module$install_model(source, global_install = global)
}

#' Install an Algorithm
#'
#' Installs an algorithm from a GitHub repository name, URL, or local zip file
#' into the user-level \code{~/.fz/algorithms/} directory (or system-level when
#' \code{global = TRUE}).
#'
#' @param source GitHub name (e.g. \code{"Funz/Algorithm-MonteCarlo"}), URL,
#'   or path to a local zip file.
#' @param global Logical; install system-wide instead of user-level.
#'   Default \code{FALSE}.
#'
#' @return Named list with installation details (path, name, …).
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   install_algorithm("Funz/Algorithm-MonteCarlo")
#' }
#' }
install_algorithm <- function(source, global = FALSE) {
  fz_module <- get_fz()
  fz_module$install_algorithm(source, global_install = global)
}

#' Uninstall a Model
#'
#' Removes a previously installed model from \code{~/.fz/models/}.
#'
#' @param model_name Name of the model to remove (e.g. \code{"PerfectGas"}).
#' @param global Logical; remove from system-level install. Default \code{FALSE}.
#'
#' @return \code{TRUE} if the model was removed, \code{FALSE} otherwise.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   uninstall_model("PerfectGas")
#' }
#' }
uninstall_model <- function(model_name, global = FALSE) {
  fz_module <- get_fz()
  fz_module$uninstall_model(model_name, global_uninstall = global)
}

#' Uninstall an Algorithm
#'
#' Removes a previously installed algorithm from \code{~/.fz/algorithms/}.
#'
#' @param algorithm_name Name of the algorithm to remove.
#' @param global Logical; remove from system-level install. Default \code{FALSE}.
#'
#' @return \code{TRUE} if the algorithm was removed, \code{FALSE} otherwise.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   uninstall_algorithm("MonteCarlo")
#' }
#' }
uninstall_algorithm <- function(algorithm_name, global = FALSE) {
  fz_module <- get_fz()
  fz_module$uninstall_algorithm(algorithm_name, global_uninstall = global)
}

#' List Installed Models
#'
#' Returns details of all models installed in \code{~/.fz/models/}.
#'
#' @param global Logical; list system-level installs. Default \code{FALSE}.
#'
#' @return Named list of installed model definitions.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   models <- list_installed_models()
#'   names(models)
#' }
#' }
list_installed_models <- function(global = FALSE) {
  fz_module <- get_fz()
  fz_module$list_installed_models(global_list = global)
}

#' List Installed Algorithms
#'
#' Returns details of all algorithms installed in \code{~/.fz/algorithms/}.
#'
#' @param global Logical; list system-level installs. Default \code{FALSE}.
#'
#' @return Named list of installed algorithm definitions.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   algos <- list_installed_algorithms()
#'   names(algos)
#' }
#' }
list_installed_algorithms <- function(global = FALSE) {
  fz_module <- get_fz()
  fz_module$list_installed_algorithms(global_list = global)
}

#' List Installed Models (alias)
#'
#' Alias for \code{\link{list_installed_models}}.
#'
#' @inheritParams list_installed_models
#' @return Named list of installed model definitions.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   names(list_models())
#' }
#' }
list_models <- function(global = FALSE) {
  list_installed_models(global)
}

#' Install a Model or Algorithm (generic)
#'
#' Generic alias: installs a model from a GitHub name, URL, or local zip file.
#' Equivalent to \code{\link{install_model}}.
#'
#' @inheritParams install_model
#' @return Named list with installation details.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   install("Funz/Model-PerfectGas")
#' }
#' }
install <- function(source, global = FALSE) {
  install_model(source, global)
}

#' Uninstall a Model (generic)
#'
#' Generic alias: removes a model by name.
#' Equivalent to \code{\link{uninstall_model}}.
#'
#' @param model_name Name of the model to remove.
#' @inheritParams uninstall_model
#' @return \code{TRUE} if removed, \code{FALSE} otherwise.
#' @export
#'
#' @examples
#' \donttest{
#' if (fz_available()) {
#'   uninstall("PerfectGas")
#' }
#' }
uninstall <- function(model_name, global = FALSE) {
  uninstall_model(model_name, global)
}
