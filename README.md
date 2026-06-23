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
  algorithm_options = "batch_sample_size=10;max_iterations=5"
)
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

BSD 3-Clause — see [LICENSE](LICENSE.md).
