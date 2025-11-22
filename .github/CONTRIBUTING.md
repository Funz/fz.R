# Contributing to fz

Thank you for considering contributing to fz! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/fz.R.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`

## Development Setup

1. Install R dependencies:
   ```r
   install.packages(c("devtools", "testthat", "reticulate"))
   ```

2. Install Python dependencies:
   ```r
   library(fz)
   fz_install()
   ```

## Making Changes

1. Make your changes in your feature branch
2. Add tests for any new functionality
3. Run tests: `devtools::test()`
4. Run R CMD check: `devtools::check()`
5. Update documentation if needed: `devtools::document()`

## Code Style

- Follow the [tidyverse style guide](https://style.tidyverse.org/)
- Use roxygen2 for documentation
- Write clear, descriptive commit messages

## Testing

- All new features should include tests
- Ensure all tests pass before submitting a PR
- Aim for high test coverage

## Submitting Changes

1. Commit your changes with clear messages
2. Push to your fork
3. Submit a pull request to the main repository
4. Describe your changes in the PR description

## Reporting Issues

- Use the GitHub issue tracker
- Provide a minimal reproducible example
- Include your R and Python versions
- Describe expected vs actual behavior

## Questions?

Feel free to open an issue for any questions about contributing.
