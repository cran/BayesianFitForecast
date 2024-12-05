#' Run Analyze Results with Specified Data and Options
#'
#' This function performs an analysis based on the specified data file, option_file, Excel file, and it saves the results in the output_path.
#' It loads auxiliary data, executes analysis steps, and saves the results.
#'
#' @param data_file_location The location of the data file which is generated after `Run_MCMC`.
#' @param option_file The name of the option file (e.g., "option1.R") located in the current working directory.
#' @param excel_file The path to an Excel file containing additional data. This parameter is required and must be a valid path to an existing file.
#' @param output_path Directory where the output will be saved. If `NULL`, a temporary directory will be created and used.
#' @return None. The function executes the analysis and saves the results to the specified `output_path`.
#' @import readxl
#' @import ggplot2
#' @import rstan
#' @import bayesplot
#' @import openxlsx
#' @importFrom stats rnorm
#' @import dplyr
#' @export
#' @examples
#' # Define file paths
#' data_file <- system.file("extdata", 
#'                           package = "BayesianFitForecast")
#' option_file <- system.file("extdata", "option.R", 
#'                           package = "BayesianFitForecast")
#'                                                      
#' excel_file <- system.file("extdata", "SanFrancisco.xlsx", 
#'                           package = "BayesianFitForecast")  
#' # Run the analysis
#' \donttest{
#' Run_analyzeResults(
#'   data_file = data_file, 
#'   option_file = option_file, 
#'   excel_file = excel_file, 
#'   output_path = NULL)
#' }
#' 
#' # Results are saved in the specified directory or temporary directory if none is provided.
Run_analyzeResults <- function(data_file_location, option_file, excel_file, output_path = NULL) {
  # Input validation
  if (is.null(excel_file)) {
    stop("Excel file path must be provided")
  }
  if (!file.exists(excel_file)) {
    stop("Excel file not found: ", excel_file)
  }
  if (!file.exists(data_file_location)) {
    stop("Data file not found: ", data_file_location)
  }
  
  # Load data and setup paths
  Mydata <<- readxl::read_excel(excel_file)
  option_file <<- normalizePath(option_file, mustWork = TRUE)
  data_file_location <<- normalizePath(data_file_location)
  output_path <<- if (is.null(output_path)) tempdir() else {
    path <- normalizePath(output_path)
    dir.create(path, showWarnings = FALSE, recursive = TRUE)
    path
  }
  Mydata <- readxl::read_excel(excel_file)
  option_file <- normalizePath(option_file, mustWork = TRUE)
  data_file_location <- normalizePath(data_file_location, winslash = "/")
  output_path <- if (is.null(output_path)) tempdir() else {
    path <- normalizePath(output_path,winslash = "/")
    dir.create(path, showWarnings = FALSE, recursive = TRUE)
    path
  }
  source(option_file, local = FALSE)
  # Locate scripts directory
  scripts_dir <- system.file("scripts", package = "BayesianFitForecast")
  if (scripts_dir == "") {
    scripts_dir <- file.path("inst", "scripts")
  }
  if (!dir.exists(scripts_dir)) {
    stop("Scripts directory not found at: ", scripts_dir)
  }
  
  # Process main analysis script
  main_script <- file.path(scripts_dir, "run_analyzeResults.R")
  if (!file.exists(main_script)) {
    stop("Required script missing: ", main_script)
  }
  
  # Handle auxiliary files
  auxiliary_files <- c("Metric_functions.R")
  analyze_lines <- readLines(main_script)
  
  for (aux_file in auxiliary_files) {
    aux_path <- file.path(scripts_dir, aux_file)
    if (!file.exists(aux_path)) {
      stop("Required auxiliary file missing: ", aux_path)
    }
    
    source_pattern <- paste0('source\\("', aux_file, '"\\)')
    source_line_index <- grep(source_pattern, analyze_lines)
    if (length(source_line_index) > 0) {
      analyze_lines[source_line_index] <- sprintf('source("%s")', 
                                                  normalizePath(aux_path, winslash = "/"))
    }
  }
  
  # Execute analysis
  temp_file <- file.path(tempdir(), 
                         paste0("analyze_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".R"))
  
  tryCatch({
    writeLines(analyze_lines, temp_file)
    source(temp_file, local = FALSE)  
  }, finally = {
    if (file.exists(temp_file)) {
      file.remove(temp_file)
    }
  })
  
  invisible(NULL)
}
