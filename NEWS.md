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
