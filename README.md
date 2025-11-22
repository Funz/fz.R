# fz

<!-- badges: start -->
[![R-CMD-check](https://github.com/Funz/fz.R/workflows/R-CMD-check/badge.svg)](https://github.com/Funz/fz.R/actions)
[![test-coverage](https://github.com/Funz/fz.R/workflows/test-coverage/badge.svg)](https://github.com/Funz/fz.R/actions)
<!-- badges: end -->

R wrapper for fz core functions using reticulate. This package provides R bindings to the fz Python package, allowing R users to access fz functionality directly from R.

## Installation

You can install the development version of fz from [GitHub](https://github.com/Funz/fz.R) with:

```r
# install.packages("devtools")
devtools::install_github("Funz/fz.R")
```

## Python Dependencies

This package requires the `fz` Python package. You can install it using:

```r
library(fz)
fz_install()
```

Or manually with:

```r
reticulate::py_install("fz")
```

## Usage

First, check if the fz Python package is available:

```r
library(fz)

# Check if fz is available
if (fz_available()) {
  message("fz is ready to use!")
} else {
  message("Please install fz with fz_install()")
}
```

### Core Functions

The package provides R wrappers for the main fz Python functions:

```r
# Use the core fz functions
result1 <- fz(...)    # Main fz function
result2 <- fzi(...)   # fzi function
result3 <- fzc(...)   # fzc function
result4 <- fzo(...)   # fzo function
result5 <- fzd(...)   # fzd function
```

All functions pass arguments directly to their Python counterparts, maintaining the same API and behavior as the original fz Python package.

### Practical Examples

The package includes comprehensive examples for working with Modelica models:

```r
# Example 1: Design of Experiments with Bouncing Ball model
fzi(model = "modelica", model_path = "BouncingBall.mo")
fzc(
  input = list(h0 = c(1, 10), v0 = c(-2, 2)),
  output = "h_max"
)
results <- fzd(design = "LatinHypercube", n = 50)

# Example 2: Optimization of Spring-Mass-Damper system
fzi(model = "modelica", model_path = "SpringMassDamper.mo")
fzc(
  input = list(m = c(0.5, 5), k = c(100, 10000), c = c(1, 100)),
  output = "settling_time"
)
optimal <- fzo(objective = "minimize", objective_var = "settling_time")

# Example 3: Parameter study for Heat Exchanger
fzi(model = "modelica", model_path = "HeatExchanger.mo")
fzc(
  input = list(mdot_hot = c(0.5, 1.5), mdot_cold = c(0.5, 1.5)),
  output = c("effectiveness", "Q_total")
)
results <- fzd(design = "FullFactorial")
```

For more detailed examples, see the vignette:

```r
vignette("modelica-examples", package = "fz")
```

## System Requirements

- R (>= 3.6.0)
- Python (>= 3.7)
- reticulate package

## Development

This package uses:

- **reticulate** for Python integration
- **testthat** for unit testing
- **GitHub Actions** for continuous integration and CRAN checks
- **roxygen2** for documentation

### Running Tests

```r
devtools::test()
```

### Running R CMD check

```r
devtools::check()
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Issues

Please report issues at https://github.com/Funz/fz.R/issues
