# fz (development version)

* `fzd()` now accepts an R function as `model`, letting adaptive
  design-of-experiments algorithms drive an R function directly instead of
  a file-based model (`input_path = NULL`, `output_expression` optional,
  `calculators` accepted as any single integer but currently always run
  sequentially, one call at a time — see below). This requires the `main`
  branch of `fz` on GitHub — install it with
  `fz_install(packages = "git+https://github.com/Funz/fz.git")`, and needs
  [Funz/fz#73](https://github.com/Funz/fz/pull/73) merged: R closures are
  bridged in via `reticulate`, which is only safe to call from the main
  thread, so `fz`'s function-model support was changed to always call the
  model sequentially (like `lapply`) instead of via a Python thread pool,
  regardless of `calculators`.
* `fz_install()` gains a `packages` argument (default `"funz-fz"`) so the
  latest `main` branch can be installed instead of the PyPI release.

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
