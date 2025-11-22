# fz 0.1.0

## Initial Release

* Initial release of fz R package
* Provides R wrapper for fz Python package using reticulate
* Core wrapper functions: `fz()`, `fzi()`, `fzc()`, `fzo()`, `fzd()`
* Functions for installing and checking fz availability: `fz_install()`, `fz_available()`
* Comprehensive test suite with testthat including:
  - Unit tests for all core functions
  - Practical Modelica integration tests
  - Test helpers and fixtures for common use cases
* Practical examples demonstrating:
  - Design of Experiments (DoE) with Modelica models
  - Optimization of system parameters
  - Uncertainty quantification
  - Parameter studies and sensitivity analysis
* Vignette with detailed Modelica examples:
  - Bouncing ball simulation
  - Spring-mass-damper optimization
  - Heat exchanger parameter study
  - Uncertainty quantification workflows
* CI/CD setup with GitHub Actions for R CMD check and CRAN checks
* Complete documentation with roxygen2
