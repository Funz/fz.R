## Submission

This is an update from 1.1 to 1.2.1, aligning the wrapper with the
`funz-fz` 1.2 Python release.

1.2.0 did not pass the CRAN incoming pre-tests. This version fixes both
problems reported:

1. The invalid `LICENSE.md` file URI in `README.md` (it now points to the
   file on GitHub).
2. The `--run-donttest` failure, which is the same one already flagged for
   the released 1.1
   (<https://www.stats.ox.ac.uk/pub/bdr/donttest/fz.out>):

```
Error in py_get_attr(x, name, FALSE) :
  AttributeError: module 'fz' has no attribute 'fzc'
```

On that machine a different, unrelated Python package is importable under
the name `fz`, so the old `fz_available()` (which only checked that *some*
module named `fz` imported) returned `TRUE` and the guarded example then
called into the wrong module. `fz_available()` now additionally checks that
the imported module exposes the `funz-fz` API (`fzi`/`fzc`/`fzo`/`fzr`), so
every `if (fz_available())` example and test skips cleanly when the Python
side is missing or misconfigured.

## R CMD check results

0 errors | 0 warnings | 0 notes

Checked locally with `R CMD check --as-cran` on R-devel, and on
win-builder (R-devel). The only prior win-builder NOTE (an invalid
`LICENSE.md` file URI in `README.md`) is fixed in this version.

## Downstream dependencies

There are no reverse dependencies.

## Notes on the Python dependency

This package wraps the `funz-fz` Python package via `reticulate`. Following
CRAN policy for Python-backed packages:

- `SystemRequirements` declares `Python (>= 3.8)` and `funz-fz`.
- `Config/reticulate` declares the pip package so `reticulate` can offer
  automatic installation.
- `fz_install()` provides a one-call helper for users to install the Python
  dependency.
- Nothing attempts a Python connection at load time. Every example and test
  is guarded by `if (fz_available())` / `skip_if_not(fz_available())` and
  wrapped in `\donttest{}` (or `\dontrun{}` for the GitHub-only
  function-model mode), so `R CMD check` never initialises Python unless a
  working `funz-fz` is present.
