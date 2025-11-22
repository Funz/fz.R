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
