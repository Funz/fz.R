# Test helpers for Modelica examples

#' Check if we're running on CI
#'
#' @return Logical indicating if tests are running on CI
skip_on_ci <- function() {
  ci <- Sys.getenv("CI", "false")
  if (tolower(ci) == "true") {
    testthat::skip("Skipping on CI")
  }
}

#' Create a mock Modelica model configuration
#'
#' @param model_name Name of the model
#' @return List with model configuration
mock_modelica_config <- function(model_name = "TestModel") {
  list(
    model = "modelica",
    model_name = model_name,
    input_vars = list(
      param1 = c(0, 1),
      param2 = c(0, 10)
    ),
    output_vars = c("result1", "result2")
  )
}

#' Create a sample parameter grid for testing
#'
#' @param n_points Number of points in the grid
#' @return Data frame with parameter combinations
create_parameter_grid <- function(n_points = 10) {
  data.frame(
    mass = seq(0.5, 2.0, length.out = n_points),
    stiffness = seq(100, 1000, length.out = n_points),
    damping = seq(0.1, 1.0, length.out = n_points)
  )
}

#' Example Modelica model: Bouncing Ball
#'
#' @return Character string with model description
example_bouncing_ball <- function() {
  list(
    name = "BouncingBall",
    description = "Simple bouncing ball model with gravity",
    inputs = c("h0", "v0", "e"),  # height, velocity, restitution
    outputs = c("h_max", "t_ground", "bounces"),
    input_ranges = list(
      h0 = c(0.1, 10.0),   # initial height (m)
      v0 = c(-5.0, 5.0),    # initial velocity (m/s)
      e = c(0.5, 0.95)      # coefficient of restitution
    )
  )
}

#' Example Modelica model: Spring-Mass-Damper
#'
#' @return List with model description
example_spring_mass_damper <- function() {
  list(
    name = "SpringMassDamper",
    description = "Spring-mass-damper oscillator",
    inputs = c("m", "k", "c", "F0"),  # mass, stiffness, damping, force
    outputs = c("x_max", "settling_time", "overshoot"),
    input_ranges = list(
      m = c(0.5, 5.0),      # mass (kg)
      k = c(100, 10000),    # stiffness (N/m)
      c = c(1, 100),        # damping (N.s/m)
      F0 = c(10, 1000)      # initial force (N)
    )
  )
}

#' Example Modelica model: Heat Exchanger
#'
#' @return List with model description
example_heat_exchanger <- function() {
  list(
    name = "HeatExchanger",
    description = "Counter-flow heat exchanger",
    inputs = c("mdot_hot", "mdot_cold", "T_hot_in", "T_cold_in"),
    outputs = c("T_hot_out", "T_cold_out", "effectiveness", "Q_total"),
    input_ranges = list(
      mdot_hot = c(0.1, 2.0),      # hot fluid flow rate (kg/s)
      mdot_cold = c(0.1, 2.0),     # cold fluid flow rate (kg/s)
      T_hot_in = c(60, 100),       # hot inlet temp (C)
      T_cold_in = c(10, 30)        # cold inlet temp (C)
    )
  )
}

#' Create a design of experiments configuration
#'
#' @param design_type Type of design ("LatinHypercube", "FullFactorial", etc.)
#' @param n_samples Number of samples
#' @param model Model configuration from example functions
#' @return List with DoE configuration
create_doe_config <- function(design_type = "LatinHypercube",
                               n_samples = 20,
                               model = example_bouncing_ball()) {
  list(
    design = design_type,
    n = n_samples,
    model_name = model$name,
    input = model$input_ranges,
    output = model$outputs
  )
}

#' Create an optimization configuration
#'
#' @param objective Objective ("minimize" or "maximize")
#' @param objective_var Variable to optimize
#' @param model Model configuration
#' @return List with optimization configuration
create_optimization_config <- function(objective = "minimize",
                                       objective_var = NULL,
                                       model = example_spring_mass_damper()) {
  if (is.null(objective_var)) {
    objective_var <- model$outputs[1]
  }

  list(
    objective = objective,
    objective_var = objective_var,
    model_name = model$name,
    input = model$input_ranges,
    output = model$outputs,
    algorithm = "GradientDescent",
    max_iterations = 100,
    tolerance = 1e-6
  )
}

#' Validate fz result structure
#'
#' @param result Result from fz function
#' @return Logical indicating if structure is valid
validate_fz_result <- function(result) {
  # Expected structure of fz results
  # This is a placeholder - actual structure depends on fz implementation
  if (is.null(result)) return(FALSE)

  # Basic checks
  checks <- c(
    is.list(result) || is.data.frame(result),
    length(result) > 0
  )

  all(checks)
}

#' Pretty print a parameter configuration
#'
#' @param config Configuration list
#' @return Invisible NULL (prints to console)
print_config <- function(config) {
  cat("Configuration:\n")
  cat("=============\n")
  for (name in names(config)) {
    value <- config[[name]]
    if (is.list(value)) {
      cat(sprintf("%s:\n", name))
      for (subname in names(value)) {
        cat(sprintf("  %s: %s\n", subname, toString(value[[subname]])))
      }
    } else {
      cat(sprintf("%s: %s\n", name, toString(value)))
    }
  }
  invisible(NULL)
}
