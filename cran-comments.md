## Submission

This is an update from 1.2.0 to 2.0.0, aligning the wrapper with the
`funz-fz` 2.0 Python release (<https://github.com/Funz/fz/releases/tag/2.0>).

The R functions keep their signatures. The changes document and test the
`funz-fz` 2.0 behaviour that is visible from R (timeouts, default variable
delimiters, cache key, case directory names, `manifest.json`), and raise the
Python requirement to 3.9, as `funz-fz` 2.0 no longer supports Python 3.8.
The major version follows the `funz-fz` version.

A subsequent win-builder pre-test flagged a `donttest` NOTE: the
`fz_available()` example had a CPU/elapsed time ratio of ~10 (5.6s user CPU
vs. 0.58s elapsed). This comes from importing `numpy` (a transitive
dependency of the `funz-fz` Python package pulled in by `reticulate`),
which spins up one BLAS/OpenMP thread per core on the check machine even
though the example does no numeric computation. `.onLoad()` now caps
`OMP_NUM_THREADS`/`OPENBLAS_NUM_THREADS`/`MKL_NUM_THREADS`/
`NUMEXPR_NUM_THREADS`/`VECLIB_MAXIMUM_THREADS` to 1 (only if not already
set by the user) before any Python import happens.

## R CMD check results

<!-- To fill in before submitting: R CMD check --as-cran (R-devel) and
     win-builder results for this version. -->

GitHub Actions `R-CMD-check` (ubuntu-latest and macos-latest, R release)
passes for this version.

## Downstream dependencies

There are no reverse dependencies.

## Notes on the Python dependency

This package wraps the `funz-fz` Python package via `reticulate`. Following
CRAN policy for Python-backed packages:

- `SystemRequirements` declares `Python (>= 3.9)` and `funz-fz`.
- `Config/reticulate` declares the pip package so `reticulate` can offer
  automatic installation.
- `fz_install()` provides a one-call helper for users to install the Python
  dependency.
- Nothing attempts a Python connection at load time. Every example and test
  is guarded by `if (fz_available())` / `skip_if_not(fz_available())` and
  wrapped in `\donttest{}` (or `\dontrun{}` for the GitHub-only
  function-model mode), so `R CMD check` only probes the available Python and
  runs no Python-backed code unless a working `funz-fz` is present. The new
  tests for `funz-fz` 2.0 behaviour are also skipped on CRAN (`skip_on_cran()`).
- `.onLoad()` declares the matching `funz-fz` version with
  `reticulate::py_require()`, which only records the requirement. Outside
  `R CMD check`, `reticulate` provisions it on first use when no Python is
  configured. During `R CMD check` (`_R_CHECK_PACKAGE_NAME_` set) neither this
  declaration nor the version check runs, and `.onLoad()` sets
  `RETICULATE_USE_MANAGED_VENV=no` (unless already set), so `reticulate` does
  not provision an ephemeral environment into the home directory. An existing
  Python environment is never changed without the user's consent in an
  interactive session.
