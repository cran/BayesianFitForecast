test_that("Run_analyzeResults works with example files", {
  # Set up file paths
  data_file <- system.file("extdata", package = "BayesianFitForecast")
  option_file <- system.file("extdata", "option.R", package = "BayesianFitForecast")
  excel_file <- system.file("extdata", "SanFrancisco.xlsx", package = "BayesianFitForecast")
  output_path <- tempdir()

  # Log paths for debugging
  message("Data file path: ", data_file)
  message("Option file path: ", option_file)
  message("Excel file path: ", excel_file)
  message("Output path: ", output_path)
  
  # Validate file existence
  expect_true(file.exists(data_file), label = "Data file exists")
  expect_true(file.exists(option_file), label = "Option file exists")
  expect_true(file.exists(excel_file), label = "Excel file exists")
  expect_true(dir.exists(output_path), label = "Output directory exists")
  
  # Execute function in test environment
  local({
    # Run the function with no errors
    expect_no_error(
      Run_analyzeResults(data_file, option_file, excel_file, output_path)
    )
  })
})
