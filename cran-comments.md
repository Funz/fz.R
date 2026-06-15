## R CMD check results

0 errors | 0 warnings | 0 notes

(Local check shows 1 WARNING about `qpdf` not being installed on this machine,
and 1 NOTE about timestamp verification — both are environment-only and will
not appear on CRAN infrastructure.)

## Downstream dependencies

This is a new submission with no existing reverse dependencies.

## Notes on Python dependency

This package wraps the `funz-fz` Python package via `reticulate`. Following
CRAN policy for Python-backed packages:

- `SystemRequirements` declares `Python (>= 3.8)` and `funz-fz`.
- `Config/reticulate` declares the pip package so `reticulate` can offer
  automatic installation.
- `fz_install()` provides a one-call helper for users to install the Python
  dependency.
- `fz_available()` guards all examples and tests; nothing attempts a Python
  connection at load time or during `R CMD check`.
- All examples are wrapped in `\dontrun{}`.
