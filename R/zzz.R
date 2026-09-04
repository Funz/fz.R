.pkg <- new.env(parent = emptyenv())
.pkg$fz <- NULL
.pkg$fz_available <- NULL

.onLoad <- function(libname, pkgname) {
  # Python is not initialised at load time -- deferred to first use via get_fz().
  # Cap BLAS/OpenMP thread pools so importing numpy (a transitive dependency
  # of the fz Python package) does not spawn one thread per core: on shared
  # CI machines this makes examples' CPU time far exceed elapsed time
  # (flagged by CRAN's donttest CPU/elapsed-ratio check) without speeding
  # anything up, since these examples do no heavy numeric computation.
  for (var in c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS",
                "NUMEXPR_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")) {
    if (identical(Sys.getenv(var), "")) {
      do.call(Sys.setenv, structure(list("1"), names = var))
    }
  }
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
