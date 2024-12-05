test_that("Run_MCMC works with example files", {
  # Set up file paths
  option_file <- system.file("extdata", "option.R", package = "BayesianFitForecast")
  excel_file <- system.file("extdata", "SanFrancisco.xlsx", package = "BayesianFitForecast")
  output_path <- tempdir()
  
  # Log paths for debugging
  message("Option file path: ", option_file)
  message("Excel file path: ", excel_file)
  message("Output path: ", output_path)
  
  # Validate file existence
  expect_true(file.exists(option_file), label = "Option file exists")
  expect_true(file.exists(excel_file), label = "Excel file exists")
  expect_true(dir.exists(output_path), label = "Output directory exists")
  
  # Execute function in test environment
  local({
    # Ensure the variables are available within the local scope
    option_file <- option_file
    excel_file <- excel_file
    output_path <- output_path
    
    # Run the function
    expect_no_error(
      Run_MCMC(option_file, excel_file, output_path)
    )
  })
})
