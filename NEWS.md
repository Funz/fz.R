# fz 2.0.0

Aligned with the `funz-fz` 2.0 release
([Funz/fz](https://github.com/Funz/fz/releases/tag/2.0), 2026-11-08). The R functions keep
their signatures; the changes below come from the Python side and are visible
from R. See the `funz-fz` `NEWS.md` ("Upgrading from 1.2") for the full list.

## Behaviour changes in funz-fz 2.0 that affect R code

* Python >= 3.9 is required (`SystemRequirements`); Python 3.8 is no longer
  supported by `funz-fz`.
* `fzr(timeout = 0)` (and `FZ_RUN_TIMEOUT=0`) now means "no timeout"; it used to
  time every case out immediately. A negative `timeout` is an error.
  `ssh://` and `slurm://` calculators have no default timeout unless
  `FZ_RUN_TIMEOUT` is set; `sh://` and `funz://` keep the 1 hour default.
* A model without `delim` (nor `var_delim`) reads both `$(x)` and `${x}` as
  variables. Models that contain other `${...}` text (shell snippets) should set
  `delim`; all examples in this package already set `delim = "{}"`.
* `cache://` uses a new SHA-256 cache key: caches written by `funz-fz` <= 1.2
  are ignored unless `FZ_CACHE_ACCEPT_LEGACY=1`.
* `sh://` commands resolve a file name to the launch directory only if the file
  is absent from the case directory. With 1.2, a command such as
  `sh://cat in.txt > out.txt` could read the un-substituted template: results
  obtained that way should be re-checked.
* Case directory names (`case_naming = "path"`) percent-encode unsafe characters
  (`a/b` becomes `a%2Fb`); `fzo()` decodes them.
* `fzr()` now writes a `manifest.json` (campaign traceability) in
  `results_dir`, recording among others the `funz-fz` version.

## Python version synchronisation

* The package now expects the `funz-fz` release with its own major and minor
  version (`funz-fz>=2.0,<2.1` for this release). It declares it with
  `reticulate::py_require()`, so `reticulate` (now >= 1.41) provisions it on
  first use when no Python is configured. This downloads Python and `funz-fz`.
* `fz_install()` installs that version by default.
* `fz_available()` detects another `funz-fz` version in an existing Python
  environment: it offers to install the matching one in an interactive session,
  and warns otherwise. Set `options(fz.sync_python = FALSE)` to disable this.
* The error raised when Python is missing no longer suggests installing the
  unrelated PyPI package `fz`.

## Tests

* `tests/testthat/test-funz-fz-2.R` checks `timeout = 0`, the rejection of a
  negative `timeout` and the `manifest.json` written by `fzr()`. It is skipped
  when the installed `funz-fz` is older than 2.0.

## Documentation

* `fzr()`'s `timeout` documents the 2.0 resolution rules.

# fz 1.2.0

Aligned with the `funz-fz` 1.2 release
([Funz/fz](https://github.com/Funz/fz/releases/tag/1.2), 2026-09-04).

The win-builder incoming pre-tests for this version flagged two problems,
both fixed here (see "Fixes" below): the `--run-donttest`
`AttributeError: module 'fz' has no attribute 'fzc'` and the invalid
`LICENSE.md` file URI in `README.md`.

## New arguments tracking funz-fz 1.2

* `fzr()` gains `case_naming` (`"path"` default, `"hash"`, or `"index"`) to
  name each case's result/temp subdirectory. `"hash"`/`"index"` sidestep
  filesystem name-length limits when a study has many variables and write a
  `cases.csv` manifest at the results root.
* `fzr()`, `fzc()`, `fzi()` and `fzd()` gain `input_static`: a character
  vector of files identical across every case (a shared reference dataset, a
  weather CSV, ...). They are never templated or scanned for variables, never
  re-hashed per case, and — for relative paths — symlinked into each case
  directory instead of duplicated (and transferred to `ssh://`/`slurm://`/
  `funz://` calculators).
* `fzd()`'s `output_expression` now also accepts a character vector of
  length > 1 for multi-objective algorithms (e.g. NSGA-II): each case yields
  one scalar per expression. Vector-valued outputs can be reduced to a scalar
  objective with `mean()`, `sum()`, `len()`, `median()`, `stdev()`,
  `variance()`, indexing/slicing, and `zip()`.
* `fzr()`'s `timeout` default (`NULL`) now documents the funz-fz 1.2
  resolution order: the model's own `"timeout"` entry, then `FZ_RUN_TIMEOUT`
  (raised to 1 hour in 1.2). An explicit `timeout` still wins.

## Runnable example

* Added a self-contained external-simulator example under
  `inst/examples/perfectgas/` (`perfectgas.txt` template + `perfectgas.py`
  ideal-gas solver). The README and vignette now show a complete `fzr()`
  parametric run driven by a real external program
  (`calculators = "sh://python3 perfectgas.py"`,
  `input_static = "perfectgas.py"`), instead of a placeholder `run.sh`.
  `tests/testthat/test-perfectgas-example.R` runs it end to end.

## Documented model features from funz-fz 1.2

* `fzo()` documents the shell-free output extraction prefixes: `python://`,
  `jq://`, `yq://`, `xpath://` (and the explicit `bash://`). These are
  portable on Windows without a bash install and preserve list results as
  vectors; a plain shell command still simplifies a single-element result to
  a scalar.
* `fzo()`/`fzr()` outputs may now resolve to a vector (time series, spectrum,
  per-node profile), stored per case unmodified.

## Direct R function models in fzd()

* `fzd()` accepts an R function as `model`, letting adaptive
  design-of-experiments algorithms drive an R function directly instead of a
  file-based model (`input_path = NULL`, `output_expression` optional). This
  is available in `funz-fz` >= 1.2; earlier releases do not support callable
  models.
* R closures are bridged in via `reticulate`, which is only safe to call from
  the main thread, so the wrapper always forces `calculators = 1` (strictly
  sequential) for function models regardless of the value passed in
  ([Funz/fz#73](https://github.com/Funz/fz/pull/73)). A value other than `1`
  emits a warning.
* `fz_install()` gains a `packages` argument (default `"funz-fz"`) so a
  development build can be installed from GitHub with
  `fz_install(packages = "git+https://github.com/Funz/fz.git")`.

## Fixes

* `fz_available()` now returns `TRUE` only when the imported `fz` module
  actually exposes the `funz-fz` API (`fzi`/`fzc`/`fzo`/`fzr`), instead of
  merely checking that *some* module named `fz` is importable. On a machine
  where an unrelated PyPI package is importable as `fz` (as on the CRAN
  check farm), the `if (fz_available())` guards now skip cleanly rather than
  letting examples fail with `AttributeError: module 'fz' has no attribute
  'fzc'`.
* Fixed an invalid file URI (`LICENSE.md`) in `README.md` flagged by
  `R CMD check --as-cran`; it now links to the file on GitHub.
* Fixed `fzd()`'s own `algorithm_options` example/documentation, which used
  a `"key=val;key2=val2"` string that `funz-fz` has never actually accepted
  (only a named list, JSON string, or path to a JSON file) — replaced with
  a named list.
* Restored the `LICENSE` file (the templated file R's packaging convention
  requires alongside `License: BSD_3_clause + file LICENSE`), which had been
  mistakenly deleted, and fixed `R-CMD-check` CI to install `funz-fz` and
  point `reticulate` at it via `RETICULATE_PYTHON` — without this,
  `reticulate`'s automatic environment provisioning was silently resolving
  to an unrelated PyPI package literally named `fz` (not `funz-fz`).

# fz 1.1

First release, aligned with funz-fz 1.1 on PyPI.

## Core functions

* `fzi(input_path, model)` — parse variable names and defaults from a template file
* `fzc(input_path, input_variables, model, output_dir)` — compile template by substituting variable values
* `fzo(output_path, model)` — read and parse output files
* `fzr(input_path, input_variables, model, ...)` — run full parametric study
* `fzl(models, calculators, check)` — list installed models and calculators
* `fzd(input_path, input_variables, model, output_expression, algorithm, ...)` — iterative algorithm-driven design of experiments

## Model and algorithm management

* `install_model(source, global)` / `install_algorithm(source, global)` — install from GitHub, URL, or local zip
* `uninstall_model(model_name, global)` / `uninstall_algorithm(algorithm_name, global)` — remove installed items
* `list_installed_models(global)` / `list_installed_algorithms(global)` — list what is installed
* `list_models()` — alias for `list_installed_models()`
* `install()` / `uninstall()` — generic aliases for model install/uninstall

## Configuration

* `get_interpreter()` / `set_interpreter(interpreter)` — get or set the formula interpreter (`"python"` or `"R"`)
* `get_log_level()` / `set_log_level(level)` — control logging verbosity
* `get_config()` / `print_config()` / `reload_config()` — inspect and reload `FZ_*` environment variable settings

## Package helpers

* `fz_install()` — install the `funz-fz` Python package via reticulate
* `fz_available()` — check whether the Python package is importable
