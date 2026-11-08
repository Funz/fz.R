## Submission

This is an update from 1.2.0 to 2.0.0, aligning the wrapper with the
`funz-fz` 2.0 Python release (<https://github.com/Funz/fz/releases/tag/2.0>).

The R functions keep their signatures. The changes document and test the
`funz-fz` 2.0 behaviour that is visible from R (timeouts, default variable
delimiters, cache key, case directory names, `manifest.json`), and raise the
Python requirement to 3.9, as `funz-fz` 2.0 no longer supports Python 3.8.
The major version follows the `funz-fz` version.

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
  function-model mode), so `R CMD check` never initialises Python unless a
  working `funz-fz` is present. The new tests for `funz-fz` 2.0 behaviour
  are also skipped on CRAN (`skip_on_cran()`).
