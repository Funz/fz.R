# Package-level variables
.fz <- NULL

.onLoad <- function(libname, pkgname) {
  # Delay loading of Python module until first use
  if (reticulate::py_module_available("fz")) {
    .fz <<- reticulate::import("fz", delay_load = TRUE)
  }
}

#' @keywords internal
get_fz <- function() {
  if (is.null(.fz)) {
    if (!reticulate::py_module_available("fz")) {
      stop(
        "The 'fz' Python package is not available. ",
        "Install it with fz_install() or manually with: ",
        "reticulate::py_install('fz')",
        call. = FALSE
      )
    }
    .fz <<- reticulate::import("fz", delay_load = TRUE)
  }
  .fz
}
