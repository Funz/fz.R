## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE  # requires funz-fz Python package and a configured calculator
)

## ----setup--------------------------------------------------------------------
#  library(fz)

## ----install------------------------------------------------------------------
#  # Install the funz-fz Python package into the active reticulate environment
#  fz_install()
#  
#  # Verify
#  fz_available()

## ----model_dict---------------------------------------------------------------
#  model <- list(
#    varprefix    = "$",
#    delim        = "{}",
#    formulaprefix = "@",
#    commentline  = "#",
#    output = list(
#      pressure = "grep 'pressure =' output.txt | cut -d= -f2"
#    )
#  )

## ----model_alias--------------------------------------------------------------
#  fzl()$models  # lists installed aliases, e.g. "PerfectGas"

## ----fzi----------------------------------------------------------------------
#  vars <- fzi("input.txt", model)
#  # $P [1] 1.013
#  # $V [1] 22.4
#  # $n [1] 1.0

## ----fzc_single---------------------------------------------------------------
#  # Single case
#  fzc("input.txt", list(P = 2.0, V = 11.2), model, output_dir = "compiled")
#  # writes: compiled/P=2,V=11.2/input.txt  (placeholder replaced with 2.0 / 11.2)

## ----fzc_grid-----------------------------------------------------------------
#  # 2 x 3 = 6 cases
#  fzc("input.txt",
#      list(P = c(1.0, 2.0), V = c(10.0, 20.0, 30.0)),
#      model,
#      output_dir = "compiled")

## ----fzr----------------------------------------------------------------------
#  results <- fzr(
#    "input.txt",
#    list(P = c(1.0, 2.0, 3.0), V = 22.4),   # 3 cases (V fixed)
#    model,
#    results_dir = "results",
#    calculators = "sh://bash run.sh"           # run.sh executes the simulator
#  )
#  
#  # results is a data frame:
#  #     P    V  pressure
#  # 1  1.0  22.4   ...
#  # 2  2.0  22.4   ...
#  # 3  3.0  22.4   ...

## ----fzo----------------------------------------------------------------------
#  values <- fzo("results/P=2,V=22.4", model)
#  # $pressure [1] "2.026"
#  
#  # Glob to read all cases at once:
#  all_values <- fzo("results/*", model)

## ----fzd----------------------------------------------------------------------
#  result <- fzd(
#    "input.txt",
#    list(P = "[1;5]", V = "[10;30]"),
#    model,
#    output_expression = "pressure",
#    algorithm         = "algorithms/montecarlo_uniform.py",
#    algorithm_options = list(batch_sample_size = 10, max_iterations = 5, seed = 42)
#  )

## ----fzl----------------------------------------------------------------------
#  info <- fzl()
#  names(info$models)       # e.g. c("PerfectGas", "Moret")
#  names(info$calculators)  # e.g. c("sh://")
#  
#  # Filter by pattern
#  fzl(models = "Perfect*")
#  
#  # Probe calculators to verify they are reachable
#  fzl(check = TRUE)

## ----save_results-------------------------------------------------------------
#  saveRDS(results, "fz_results.rds")
#  write.csv(results, "fz_results.csv", row.names = FALSE)

## ----troubleshoot_install-----------------------------------------------------
#  fz_install()         # install funz-fz into the reticulate environment
#  fz_available()       # should return TRUE afterwards

## ----session_info-------------------------------------------------------------
#  sessionInfo()

