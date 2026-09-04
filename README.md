# fz

<!-- badges: start -->
[![R-CMD-check](https://github.com/Funz/fz.R/workflows/R-CMD-check/badge.svg)](https://github.com/Funz/fz.R/actions)
[![test-coverage](https://github.com/Funz/fz.R/workflows/test-coverage/badge.svg)](https://github.com/Funz/fz.R/actions)
<!-- badges: end -->

R wrapper for the [funz-fz](https://pypi.org/project/funz-fz/) Python package using reticulate. fz is a parametric scientific computing framework: it wraps simulation codes to run parameter sweeps, design of experiments, and iterative algorithm-driven studies.

## Installation

```r
# install.packages("devtools")
devtools::install_github("Funz/fz.R")
```

## Python dependency

This package requires the `funz-fz` Python package. Install it via the helper:

```r
library(fz)
fz_install()
```

Or manually:

```r
reticulate::py_install("funz-fz")
```

## Core functions

| Function | Purpose |
|---|---|
| `fzi(input_path, model)` | Parse variable names and defaults from a template file |
| `fzc(input_path, input_variables, model)` | Compile template — substitute variable values |
| `fzr(input_path, input_variables, model, ...)` | Run full parametric study |
| `fzo(output_path, model)` | Read and parse output files |
| `fzl(models, calculators, check)` | List installed models and calculators |
| `fzd(input_path, input_variables, model, output_expression, algorithm, ...)` | Algorithm-driven iterative DoE |

The **model** argument is either a string alias (name of an installed model, e.g. `"PerfectGas"`) or an inline named list describing how variables are marked in the template and how outputs are extracted.

Output values can be a shell command (the default) or, with `funz-fz` >= 1.2, one of the shell-free extractors `python://`, `jq://`, `yq://`, `xpath://` (portable on Windows without bash). An output may also resolve to a vector (time series, spectrum, ...).

## Usage

### 1 — List installed models

```r
library(fz)

info <- fzl()
names(info$models)       # e.g. c("PerfectGas")
names(info$calculators)  # e.g. c("sh://")
```

### 2 — Parse variables from a template

```r
# Template file: input.txt
# pressure = ${P~1.013}
# volume   = ${V~22.4}

model <- list(
  varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#"
)

vars <- fzi("input.txt", model)
# vars$P == 1.013  (default value)
# vars$V == 22.4
```

### 3 — Run a parametric study

```r
# fzr compiles the template for every combination, runs the model via the
# calculator, and collects all outputs into a data frame.

model <- list(
  varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#",
  output = list(pressure = "grep 'pressure' output.txt | cut -d= -f2")
)

results <- fzr(
  "input.txt",
  list(P = c(1.0, 2.0, 3.0), V = 22.4),  # 3 cases
  model,
  calculators = "sh://bash run.sh"
)
# results is a data frame with columns P, V, pressure
```

### 4 — Algorithm-driven design of experiments

```r
# fzd iteratively queries the model using an algorithm (e.g. Monte Carlo,
# surrogate-based optimisation). Input ranges use "[min;max]" strings.

result <- fzd(
  "input.txt",
  list(P = "[1;5]", V = "[10;30]"),
  model,
  output_expression = "pressure",
  algorithm        = "algorithms/montecarlo_uniform.py",
  algorithm_options = list(batch_sample_size = 10, max_iterations = 5)
)

# `output_expression` may also be a character vector for multi-objective
# algorithms (e.g. NSGA-II): `c("cost", "-efficiency")`.
```

### 5 — Step-by-step workflow

```r
# Step 1: inspect which variables the template exposes
vars <- fzi("input.txt", model)

# Step 2: compile for specific values (no execution)
fzc("input.txt", list(P = 2.0, V = 11.2), model, output_dir = "compiled")

# Step 3: read output files after running the simulator externally
values <- fzo("compiled/P=2,V=11.2", model)
```

## A complete runnable example: an external simulator

The snippets above use a placeholder `run.sh`. Here is a self-contained
parametric study driven by a **real external program** — a tiny Python
simulator of the ideal gas law `P = n R T / V`. Both files ship with the
package under `inst/examples/perfectgas/`:

```r
library(fz)
# fz_install()  # once, if the funz-fz Python package is not yet installed

ex <- system.file("examples", "perfectgas", package = "fz")
file.copy(list.files(ex, full.names = TRUE), ".")  # perfectgas.txt + perfectgas.py
```

`perfectgas.txt` is the input template (`${T~300}` is variable `T`, default `300`):

```
temperature = ${T~300}     # K
volume      = ${V~0.001}   # m3
moles       = ${n~1}       # mol
```

`perfectgas.py` reads the compiled `perfectgas.txt` in its working directory,
computes the pressure, and writes `pressure = <value>` to `out.txt`.

```r
model <- list(
  varprefix = "$", delim = "{}", formulaprefix = "@", commentline = "#",
  # shell-free output extraction (funz-fz >= 1.2)
  output = list(pressure = 'python://grep(r"pressure = (\\S+)", "out.txt")')
)

results <- fzr(
  "perfectgas.txt",
  list(T = c(300, 350, 400), V = 1e-3, n = 1),   # 3 cases
  model,
  calculators  = "sh://python3 perfectgas.py",   # the external simulator
  input_static = "perfectgas.py"                  # shipped into every case dir (funz-fz >= 1.2)
)
results[, c("T", "V", "n", "pressure")]
#>     T     V n pressure
#> 1 300 0.001 1  2494339
#> 2 350 0.001 1  2910062
#> 3 400 0.001 1  3325785
```

The same model works with `fzd()` for an algorithm-driven study — pass
`input_variables` as `"[min;max]"` ranges (or a fixed `"1"`) and keep
`calculators = "sh://python3 perfectgas.py"`, `input_static = "perfectgas.py"`.

## System requirements

- R >= 3.6.0
- Python >= 3.8
- reticulate package

## Development

```r
devtools::test()   # run tests
devtools::check()  # R CMD check
```

## Contributing

Contributions are welcome. Please open a Pull Request or file an issue at
<https://github.com/Funz/fz.R/issues>.

## License

BSD 3-Clause. See the
[LICENSE.md](https://github.com/Funz/fz.R/blob/main/LICENSE.md) file.
