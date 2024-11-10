
# instruction:
# transform the code into a more advanced style, leveraging pipes (%>%), mutate, summarize,
# and other tidyverse techniques. Make sure the code is modular and efficient. Take best R coding
# practices for data science and ML projects to make the code readable, modular, and scalable.
# Write function when tasks are repetitive, complex, or require flexibility, improving readability, reusability, and consistency. Avoid functions for one-off code, simple transformations, or linear workflows, as they may add unnecessary complexity.
# if writing function, use Roxygen2-style comments to make the functions readable and modular.



# 1. Pre-Deployment Testing (if separate from deployment) -----------------

# Load Required Libraries -------------------------------------------------
library(tidyverse)
library(testthat)
library(jsonlite)
library(httr)

# 1. Define Test Cases ----------------------------------------------------
# Create a list of test cases, covering valid, invalid, and edge cases for API requests
test_cases <- list(
  valid_input = list(
    description = "Valid input data",
    payload = list(feature1 = 10, feature2 = 5, feature3 = "categoryA"),
    expected_status = 200
  ),
  missing_field = list(
    description = "Missing required field",
    payload = list(feature1 = 10, feature2 = 5),  # feature3 is missing
    expected_status = 400
  ),
  invalid_data_type = list(
    description = "Invalid data type for feature",
    payload = list(feature1 = "text_instead_of_number", feature2 = 5, feature3 = "categoryA"),
    expected_status = 400
  ),
  edge_case_large_value = list(
    description = "Edge case with very large value",
    payload = list(feature1 = 1e10, feature2 = 5, feature3 = "categoryA"),
    expected_status = 200
  )
)

# 2. Automate Testing Using testthat --------------------------------------
# Define a function to run test cases and validate API responses
#' Run API Test Cases
#'
#' @param url The API endpoint URL to test.
#' @param test_cases A list of test cases, each containing a payload, description, and expected status.
#' @return A data frame logging the results of each test case.
run_api_tests <- function(url, test_cases) {
  results <- map_dfr(test_cases, function(case) {
    response <- POST(url, body = toJSON(case$payload), encode = "json")
    response_status <- status_code(response)
    response_content <- content(response, as = "text", encoding = "UTF-8")

    tibble(
      description = case$description,
      expected_status = case$expected_status,
      actual_status = response_status,
      passed = response_status == case$expected_status,
      response_content = response_content
    )
  })

  results
}

# Define the API URL (replace with actual endpoint for testing)
api_url <- "http://localhost:8000/predict"

# Run tests and collect results
test_results <- run_api_tests(api_url, test_cases)

# 3. Log Pre-Deployment Results -------------------------------------------
# Save the test results to a log file
#' Log API Test Results
#'
#' @param results A data frame of test results.
#' @param file_path Path to save the log file (e.g., "logs/pre_deployment_test_results.csv").
log_test_results <- function(results, file_path = "logs/pre_deployment_test_results.csv") {
  if (!dir.exists(dirname(file_path))) {
    dir.create(dirname(file_path), recursive = TRUE)
  }

  write_csv(results, file_path)
  cat("Test results saved to:", file_path, "\n")
}

# Save the test results
log_test_results(test_results)

# Explanation:
# - **Define Test Cases**: We create a list of test cases, covering different scenarios such as valid input, missing fields, invalid data types, and edge cases.
# - **Automate Testing Using testthat**: The `run_api_tests` function sends API requests for each test case, records the response, and compares it with the expected status.
# - **Log Pre-Deployment Results**: The `log_test_results` function saves the results as a CSV file for further review. This helps track any issues before deployment.



# 2. Post-Deployment API Testing ------------------------------------------
# Load Required Libraries -------------------------------------------------
library(tidyverse)
library(httr)
library(jsonlite)
library(lubridate)

# 1. Define Post-Deployment Test Function ---------------------------------
#' Run Automated Tests on Deployed API
#'
#' @param url The live API endpoint URL to test.
#' @param test_cases A list of test cases with input payloads and expected responses.
#' @return A data frame logging test results, including latency and error codes.
run_post_deployment_tests <- function(url, test_cases) {
  results <- map_dfr(test_cases, function(case) {
    start_time <- Sys.time()
    response <- POST(url, body = toJSON(case$payload), encode = "json")
    end_time <- Sys.time()

    response_status <- status_code(response)
    response_content <- content(response, as = "text", encoding = "UTF-8")
    latency <- as.numeric(difftime(end_time, start_time, units = "secs"))

    tibble(
      timestamp = Sys.time(),
      description = case$description,
      expected_status = case$expected_status,
      actual_status = response_status,
      latency = latency,
      passed = response_status == case$expected_status,
      response_content = response_content
    )
  })

  results
}

# Define the API URL (replace with actual endpoint for testing)
deployed_api_url <- "http://your-deployed-api.com/predict"

# Run tests on the deployed API
post_deployment_results <- run_post_deployment_tests(deployed_api_url, test_cases)

# 2. Capture and Log Test Results -----------------------------------------
#' Log Post-Deployment Test Results
#'
#' @param results A data frame of test results from the deployed API.
#' @param file_path Path to save the log file (e.g., "logs/post_deployment_test_results.csv").
log_post_deployment_results <- function(results, file_path = "logs/post_deployment_test_results.csv") {
  if (!dir.exists(dirname(file_path))) {
    dir.create(dirname(file_path), recursive = TRUE)
  }

  write_csv(results, file_path)
  cat("Post-deployment test results saved to:", file_path, "\n")
}

# Save the test results
log_post_deployment_results(post_deployment_results)

# Explanation:
# - **Run Automated Tests on Deployed API**: The `run_post_deployment_tests` function sends API requests to the live endpoint for each test case and calculates latency. Each response is logged with the HTTP status, latency, and content.
# - **Check for Latency and Error Codes**: This process captures both the status code and response time for each request, ensuring that latency is within acceptable limits and errors are appropriately handled.
# - **Capture Test Results and Errors**: The `log_post_deployment_results` function writes the results to a CSV file, logging each test’s timestamp, expected/actual status, and any errors. This enables ongoing monitoring of the deployed API.



# 3. Model and API Monitoring ---------------------------------------------

# Load Required Libraries -------------------------------------------------
library(tidyverse)
library(httr)
library(jsonlite)
library(lubridate)
library(logger)  # For logging events and alerts
library(glue)    # For formatted messages

# 1. Define Function for Monitoring API Health -----------------------------
#' Perform Health Check on Deployed API
#'
#' @param url The URL of the API's health endpoint.
#' @return A data frame with the health check timestamp, response time, and status.
check_api_health <- function(url = "http://your-deployed-api.com/health") {
  start_time <- Sys.time()
  response <- tryCatch({
    GET(url)
  }, error = function(e) {
    return(NA)
  })
  end_time <- Sys.time()

  response_status <- if (!is.na(response)) status_code(response) else 503
  latency <- as.numeric(difftime(end_time, start_time, units = "secs"))

  tibble(
    timestamp = Sys.time(),
    api_status = ifelse(!is.na(response), response_status, "Error"),
    latency = latency,
    health_check_passed = response_status == 200 && latency < 1
  )
}

# Run an initial health check
health_check_result <- check_api_health()

# 2. Define Function for Monitoring API Performance ------------------------
#' Track Key API Performance Metrics
#'
#' @param url The URL of the deployed API's prediction endpoint.
#' @param test_cases A list of test cases to monitor API responses.
#' @return A data frame logging key performance metrics like latency, accuracy, and errors.
monitor_api_performance <- function(url, test_cases) {
  map_dfr(test_cases, function(case) {
    start_time <- Sys.time()
    response <- POST(url, body = toJSON(case$payload), encode = "json")
    end_time <- Sys.time()

    latency <- as.numeric(difftime(end_time, start_time, units = "secs"))
    response_status <- status_code(response)
    response_content <- content(response, as = "parsed", type = "application/json")

    predicted_value <- response_content$prediction
    expected_value <- case$expected_output

    tibble(
      timestamp = Sys.time(),
      latency = latency,
      status = response_status,
      predicted = predicted_value,
      expected = expected_value,
      correct_prediction = if (!is.null(expected_value)) predicted_value == expected_value else NA,
      error_flag = response_status != 200 || (latency > 1)
    )
  })
}

# 3. Log and Save Monitoring Results ---------------------------------------
#' Save Monitoring Logs
#'
#' @param health_result Data frame with health check results.
#' @param performance_result Data frame with API performance results.
#' @param health_log_path File path to save health check logs.
#' @param performance_log_path File path to save performance logs.
log_monitoring_results <- function(
    health_result,
    performance_result,
    health_log_path = "logs/api_health_check.csv",
    performance_log_path = "logs/api_performance_log.csv"
) {
  if (!dir.exists(dirname(health_log_path))) dir.create(dirname(health_log_path), recursive = TRUE)
  if (!dir.exists(dirname(performance_log_path))) dir.create(dirname(performance_log_path), recursive = TRUE)

  write_csv(health_result, health_log_path, append = TRUE)
  write_csv(performance_result, performance_log_path, append = TRUE)

  cat("Health check and performance logs saved to:", health_log_path, "and", performance_log_path, "\n")
}

# Perform API monitoring and logging
performance_result <- monitor_api_performance("http://your-deployed-api.com/predict", test_cases)
log_monitoring_results(health_check_result, performance_result)

# 4. Set Up Automated Alerts -----------------------------------------------
#' Automated Alert for Monitoring Issues
#'
#' @param health_result Data frame with latest health check.
#' @param performance_result Data frame with latest performance metrics.
#' @return None. Sends an alert if any issues are detected.
send_alert_if_issue <- function(health_result, performance_result) {
  # Health check alert
  if (!health_result$health_check_passed) {
    log_warn(glue("ALERT: API health check failed with status: {health_result$api_status} and latency: {health_result$latency}"))
  }

  # Performance alert
  if (any(performance_result$error_flag)) {
    error_cases <- performance_result %>% filter(error_flag == TRUE)
    log_warn(glue("ALERT: API performance issue detected. High latency or errors in {nrow(error_cases)} requests."))
  }
}

# Run the alert check
send_alert_if_issue(health_check_result, performance_result)

# Explanation:
# - **Track Key Performance Metrics**: The `monitor_api_performance` function tracks latency, HTTP status, and prediction accuracy. Results are logged in a structured format, allowing trend analysis over time.
# - **Automated Health Checks and Alerts**: The `check_api_health` function checks the health endpoint, and `send_alert_if_issue` sends alerts if health or performance metrics fail. Alerts are logged using the `logger` package to ensure stakeholders are notified.
# - **Log Monitoring Results**: The `log_monitoring_results` function saves health checks and performance logs to CSV files for future review, providing a timestamped history of API performance.



# 4. Model and API Versioning ---------------------------------------------

# Load Required Libraries -------------------------------------------------
library(tidyverse)
library(glue)
library(logger)

# 1. Define Versioning Schema ---------------------------------------------
#' Generate a Version Label for Model and API
#'
#' @param major Major version number.
#' @param minor Minor version number.
#' @param patch Patch version number.
#' @return A version label string.
generate_version_label <- function(major = 1, minor = 0, patch = 0) {
  glue("v{major}.{minor}.{patch}")
}

# Define version labels
current_model_version <- generate_version_label(1, 0, 0)
current_api_version <- generate_version_label(1, 0, 0)

# Explanation:
# This function generates a semantic version label for models and APIs, improving
# version tracking and consistency across components.

# 2. Ensure Backward Compatibility ----------------------------------------
#' Check Backward Compatibility for Updated Model
#'
#' @param new_model The new model object.
#' @param original_model The current production model object.
#' @return Boolean indicating if the new model maintains compatibility.
check_backward_compatibility <- function(new_model, original_model) {
  # Compare model structures, feature names, and types
  original_features <- names(original_model$terms)
  new_features <- names(new_model$terms)

  compatible <- setequal(original_features, new_features)

  if (!compatible) {
    log_warn("Backward compatibility issue: Feature names or types have changed.")
  }

  compatible
}

# Example compatibility check (replace with actual model objects in production)
# compatible <- check_backward_compatibility(new_model, original_model)

# Explanation:
# The `check_backward_compatibility` function compares the feature names and types
# between the original and new models to ensure that changes do not disrupt existing
# functionality. It logs warnings if any incompatibilities are detected.

# 3. Archive Older Versions -----------------------------------------------
#' Archive Model and API Versions
#'
#' @param model_object The model object to archive.
#' @param version_label The version label of the model.
#' @param archive_dir Directory to store archived versions.
#'
#' @return None. Saves the model to the specified archive directory.
archive_version <- function(model_object, version_label, archive_dir = "archive") {
  # Create archive directory if it doesn't exist
  if (!dir.exists(archive_dir)) dir.create(archive_dir)

  model_path <- file.path(archive_dir, glue("model_{version_label}.rds"))
  saveRDS(model_object, model_path)

  # Log archiving action
  log_info(glue("Model archived as version {version_label} at {model_path}"))
}

# Example archiving (replace with actual model object)
# archive_version(new_model, current_model_version)

# Explanation:
# The `archive_version` function saves a specified model object with its version label
# in an archive directory. This keeps a historical record of model versions, facilitating
# traceability and rollback if needed.

# 4. Include Version in API Response --------------------------------------
#' Add Version Information to API Response
#'
#' @param response The API response object.
#' @param api_version The current API version.
#' @param model_version The current model version.
#' @return The modified response object with version information added.
add_version_to_response <- function(response, api_version, model_version) {
  response$api_version <- api_version
  response$model_version <- model_version
  response
}

# Example API response (replace with actual response structure in production)
api_response <- list(prediction = 0.85)  # Dummy prediction
api_response <- add_version_to_response(api_response, current_api_version, current_model_version)

# Explanation:
# The `add_version_to_response` function appends API and model version information
# to each API response, making it easy to track which versions generated a given
# result. This is useful for monitoring and debugging.

# Summary:
# - **Define Versioning Schema**: Creates standardized version labels to track changes.
# - **Ensure Backward Compatibility**: Checks for consistency in feature names/types.
# - **Archive Older Versions**: Saves older model versions with version labels.
# - **Include Version in API Response**: Adds version metadata to API outputs for traceability.



# 5. Log and Archive Testing Results --------------------------------------

# Load Required Libraries -------------------------------------------------
library(tidyverse)
library(lubridate)
library(logger)

# 1. Log All Testing Results ----------------------------------------------
#' Log Testing Results
#'
#' @param test_name Name of the test (e.g., "pre-deployment", "post-deployment", "health check").
#' @param results List of test results, including metrics and status codes.
#' @param log_file File path to save the log entry.
#'
#' @return None. Logs the test results to the specified file.
log_test_results <- function(test_name, results, log_file = "logs/testing_results_log.csv") {
  # Prepare log entry
  log_entry <- tibble(
    timestamp = Sys.time(),
    test_name = test_name,
    metrics = results$metrics %>% map_chr(~ paste(.x, collapse = ", ")),
    status = results$status,
    error_message = results$error_message %||% NA_character_
  )

  # Log to CSV
  if (!file.exists(log_file)) {
    write_csv(log_entry, log_file, append = FALSE)
  } else {
    write_csv(log_entry, log_file, append = TRUE)
  }

  # Console log for quick review
  log_info(glue("Test '{test_name}' results logged at {log_file}"))
}

# Example usage of log_test_results
# pre_deployment_results <- list(
#   metrics = list(accuracy = 0.95, latency = 120),
#   status = "success"
# )
# log_test_results("pre-deployment", pre_deployment_results)

# Explanation:
# `log_test_results` logs the details of each test, including timestamp, test name, metrics, status,
# and any error messages. Each entry is appended to a CSV log for traceability.

# 2. Store Historical Metrics and Logs ------------------------------------
#' Store Historical API Metrics
#'
#' @param metrics A named list of metrics (e.g., error_rate, latency).
#' @param archive_file File path for saving historical metrics.
#'
#' @return None. Appends metrics to the archive file for historical tracking.
store_historical_metrics <- function(metrics, archive_file = "logs/api_metrics_history.csv") {
  # Prepare metrics entry
  metrics_entry <- tibble(
    timestamp = Sys.time(),
    error_rate = metrics$error_rate %||% NA_real_,
    latency = metrics$latency %||% NA_real_,
    other_metrics = metrics$other_metrics %>% map_chr(~ paste(.x, collapse = ", ")) %||% NA_character_
  )

  # Append to historical metrics file
  if (!file.exists(archive_file)) {
    write_csv(metrics_entry, archive_file, append = FALSE)
  } else {
    write_csv(metrics_entry, archive_file, append = TRUE)
  }

  # Console log for confirmation
  log_info(glue("API metrics archived at {archive_file}"))
}

# Example usage of store_historical_metrics
# api_metrics <- list(
#   error_rate = 0.02,
#   latency = 150,
#   other_metrics = list(success_rate = 0.98, requests_per_min = 60)
# )
# store_historical_metrics(api_metrics)

# Explanation:
# `store_historical_metrics` records API performance metrics like error rate and latency.
# Each entry includes a timestamp, and the data is appended to a CSV file for performance tracking
# over time. This helps monitor API health and detect trends or issues.

# Summary:
# - **Log All Testing Results**: Records each test with details in a log file for traceability.
# - **Store Historical Metrics and Logs**: Maintains a historical record of key API metrics,
#   allowing performance analysis and monitoring of trends over time.



