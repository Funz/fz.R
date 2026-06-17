.pkg <- new.env(parent = emptyenv())
.pkg$fz <- NULL
.pkg$fz_available <- NULL

.onLoad <- function(libname, pkgname) {
  # Python is not initialised at load time — deferred to first use via get_fz().
}

#' @keywords internal
get_fz <- function() {
  if (is.null(.pkg$fz)) {
    if (!fz_available()) {
      stop(
        "The 'fz' Python package is not available. ",
        "Install it with fz_install() or manually with: ",
        "reticulate::py_install('fz')",
        call. = FALSE
      )
    }
    .pkg$fz <- reticulate::import("fz", delay_load = TRUE)
  }
  .pkg$fz
}
