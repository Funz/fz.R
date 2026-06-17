## R CMD check results

0 errors | 1 warning | 1 note

- WARNING: 'qpdf' is needed for checks on size reduction of PDFs.
  `qpdf` is not installed on this development machine; the package
  contains no PDFs and this will not appear on CRAN infrastructure.

- NOTE: unable to verify current time.
  Caused by network restrictions on this machine; not a package issue.

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
