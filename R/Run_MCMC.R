#' Run MCMC Analysis with Specified Option File
#'
#' This function runs an MCMC analysis based on the specified option file, sourcing auxiliary scripts, and executing the analysis.
#'
#' @param option_file The name of the option file (e.g., "option1.R") located in the current working directory.
#' @param excel_file The path to the Excel file containing the data.
#' @param output_path Directory where the output will be saved. If `NULL`, uses a temporary directory.
#' @return None. The function executes and saves results directly.
#' @importFrom stats rnorm
#' @import readxl
#' @import rstan
#' @import dplyr
#' @export
#' @examples
#' # Get path to the example option file included with package
#' option_file <- system.file("extdata", "option.R", 
#'                           package = "BayesianFitForecast")
#'                           
#' # Specify the path to the Excel file you want to analyze
#' excel_file <- system.file("extdata", "SanFrancisco.xlsx", 
#'                           package = "BayesianFitForecast")  # Modify this path accordingly
#'                           
#' # Run the MCMC analysis
#' \donttest{
#' Run_MCMC(option_file = option_file, excel_file = excel_file, output_path = NULL)
#' }
Run_MCMC <- function(option_file, excel_file = NULL, output_path = NULL) {
  # Input validation
  if (is.null(excel_file)) {
    stop("Excel file path must be provided")
  }
  if (!file.exists(excel_file)) {
    stop("Excel file not found: ", excel_file)
  }
  
  # Load data and setup paths
  Mydata <<- readxl::read_excel(excel_file)
  option_file <<- normalizePath(option_file, mustWork = TRUE)
  output_path <<- if (is.null(output_path)) tempdir() else {
    path <- normalizePath(output_path)
    dir.create(path, showWarnings = FALSE, recursive = TRUE)
    path
  }
  Mydata <- readxl::read_excel(excel_file)
  option_file <- normalizePath(option_file, mustWork = TRUE)
  output_path <- if (is.null(output_path)) tempdir() else {
    path <- normalizePath(output_path)
    dir.create(path, showWarnings = FALSE, recursive = TRUE)
    path
  }
  # Source the option file to make all parameters and variables global
  source(option_file, local = FALSE)  # Make sure everything is global
  
  # Locate scripts directory
  scripts_dir <- system.file("scripts", package = "BayesianFitForecast")
  if (scripts_dir == "") {
    scripts_dir <- file.path("inst", "scripts")
  }
  if (!dir.exists(scripts_dir)) {
    stop("Scripts directory not found at: ", scripts_dir)
  }
  
  # Process main MCMC script
  main_script <- file.path(scripts_dir, "run_MCMC.R")
  if (!file.exists(main_script)) {
    stop("Required script missing: ", main_script)
  }
  
  # Handle auxiliary files
  auxiliary_files <- c("diff.R", "ode_rhs.R", "stancreator.R")
  run_mcmc_lines <- readLines(main_script)
  
  for (aux_file in auxiliary_files) {
    aux_path <- file.path(scripts_dir, aux_file)
    if (!file.exists(aux_path)) {
      stop("Required auxiliary file missing: ", aux_path)
    }
    
    source_pattern <- paste0('source\\("', aux_file, '"\\)')
    source_line_index <- grep(source_pattern, run_mcmc_lines)
    if (length(source_line_index) > 0) {
      run_mcmc_lines[source_line_index] <- sprintf('source("%s")', 
                                                   normalizePath(aux_path, winslash = "/"))
    }
  }
  
  # Execute analysis
  temp_file <- file.path(tempdir(), 
                         paste0("mc_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".R"))
  
  tryCatch({
    writeLines(run_mcmc_lines, temp_file)
    source(temp_file, local = FALSE)  # Source in global environment
  }, finally = {
    if (file.exists(temp_file)) {
      file.remove(temp_file)
    }
  })
  
  invisible(NULL)  # Return nothing explicitly
}
