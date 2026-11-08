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

  # Declare the matching funz-fz version: reticulate provisions it in an
  # ephemeral environment when no other Python is configured. This only records
  # the requirement; nothing is downloaded until Python is first used.
  if (fz_is_checking()) {
    # Under R CMD check, also keep reticulate from provisioning its default
    # ephemeral environment (uv, Python and numpy, ~200 MB into HOME) when no
    # Python is configured: fz_available() is then simply FALSE.
    if (identical(Sys.getenv("RETICULATE_USE_MANAGED_VENV"), "")) {
      Sys.setenv(RETICULATE_USE_MANAGED_VENV = "no")
    }
  } else {
    tryCatch(
      reticulate::py_require(fz_python_requirement()),
      error = function(e) NULL # e.g. Python already initialised by another package
    )
  }
}

# TRUE during R CMD check (examples, tests, vignettes).
fz_is_checking <- function() {
  nzchar(Sys.getenv("_R_CHECK_PACKAGE_NAME_"))
}

# The funz-fz release series matching this R package: same major.minor, so that
# R package 2.0.x goes with funz-fz 2.0.x. The patch level is free on both sides.
fz_python_requirement <- function(version = utils::packageVersion("fz")) {
  v <- unlist(package_version(version))
  sprintf("funz-fz>=%d.%d,<%d.%d", v[1], v[2], v[1], v[2] + 1L)
}

# Does an installed funz-fz version string match the R package's major.minor?
fz_python_in_sync <- function(installed, version = utils::packageVersion("fz")) {
  # keep the numeric release segment only ("2.1.dev3" -> "2.1")
  release <- regmatches(installed, regexpr("^[0-9]+(\\.[0-9]+)*", installed))
  if (length(release) == 0L) {
    return(FALSE)
  }
  i <- unlist(package_version(paste0(release, ".0")))
  v <- unlist(package_version(version))
  i[1] == v[1] && i[2] == v[2]
}

# Version of funz-fz in the active Python, read without importing fz (an imported
# module cannot be replaced in a running session). NA when it is not installed.
fz_python_version <- function() {
  tryCatch(
    as.character(reticulate::import("importlib.metadata")$version("funz-fz")),
    error = function(e) NA_character_
  )
}

# An existing Python environment takes precedence over py_require(), and may hold
# another funz-fz version. Never changes it without the user's consent: asks in
# an interactive session, warns otherwise. Disable with
# options(fz.sync_python = FALSE), e.g. when tracking funz-fz from GitHub.
fz_sync_python <- function() {
  if (fz_is_checking() || !isTRUE(getOption("fz.sync_python", TRUE))) {
    return(invisible(NULL))
  }
  installed <- fz_python_version()
  if (is.na(installed) || fz_python_in_sync(installed)) {
    return(invisible(NULL))
  }

  requirement <- fz_python_requirement()
  python <- reticulate::py_exe()
  question <- sprintf(
    "The fz R package %s needs %s, but this Python has funz-fz %s:\n  %s\nInstall the matching version there?",
    utils::packageVersion("fz"), requirement, installed, python
  )
  if (interactive() && isTRUE(utils::askYesNo(question))) {
    system2(python, c("-m", "pip", "install", shQuote(requirement)))
    installed <- fz_python_version()
    if (!is.na(installed) && fz_python_in_sync(installed)) {
      message("funz-fz ", installed, " installed in ", python)
      return(invisible(NULL))
    }
  }

  warning(
    "The fz R package ", utils::packageVersion("fz"), " needs ", requirement,
    ", but funz-fz ", installed, " is in use (", python, "). ",
    "Update it with: ", shQuote(python), " -m pip install ", shQuote(requirement),
    "\nSet options(fz.sync_python = FALSE) to silence this check.",
    call. = FALSE
  )
  invisible(NULL)
}

#' @keywords internal
get_fz <- function() {
  if (is.null(.pkg$fz)) {
    if (!fz_available()) {
      stop(
        "The 'fz' Python package is not available. ",
        "Install it with fz_install() or manually with: ",
        "reticulate::py_install('", fz_python_requirement(), "')",
        call. = FALSE
      )
    }
    .pkg$fz <- reticulate::import("fz", delay_load = TRUE)
  }
  .pkg$fz
}
