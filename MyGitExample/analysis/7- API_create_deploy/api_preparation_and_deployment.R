
# instruction:
# transform the code into a more advanced style, leveraging pipes (%>%), mutate, summarize,
# and other tidyverse techniques. Make sure the code is modular and efficient. Take best R coding
# practices for data science and ML projects to make the code readable, modular, and scalable.
# Write function when tasks are repetitive, complex, or require flexibility, improving readability, reusability, and consistency. Avoid functions for one-off code, simple transformations, or linear workflows, as they may add unnecessary complexity.
# if writing function, use Roxygen2-style comments to make the functions readable and modular.


# 1. Load Required Libraries ------------------------------------------------
library(plumber)    # For building and deploying APIs
library(jsonlite)   # For JSON conversion and handling
library(logger)     # For logging API activities
library(tidyverse)  # For data manipulation and handling

# Explanation:
# This section loads essential libraries. `plumber` handles API requests, `jsonlite` enables JSON data handling,
# and `logger` provides structured logging for monitoring API interactions. `tidyverse` is used for data preparation.

# 2. Package Model and Assets for Deployment --------------------------------

#' Save Model and Preprocessing Assets for Deployment
#'
#' @param model_path Path to the trained model file (e.g., 'final_model.rds').
#' @param recipe_path Path to the preprocessing recipe file (e.g., 'recipe.rds').
#' @param bundle_dir Directory path for the deployment bundle.
#'
#' @return None. Saves model, recipe, and example data into the specified directory.
#' @export
prepare_deployment_bundle <- function(model_path, recipe_path, bundle_dir = "deployment_bundle") {
  # Create the deployment bundle directory if it does not exist
  if (!dir.exists(bundle_dir)) {
    dir.create(bundle_dir)
  }

  # Copy model and recipe files to the deployment bundle
  file.copy(model_path, bundle_dir)
  file.copy(recipe_path, bundle_dir)

  # Create a sample input dataset for testing and reference
  example_data <- head(readRDS(recipe_path) %>% bake(new_data = NULL))
  write_csv(example_data, file.path(bundle_dir, "example_data.csv"))

  # Add a README file with API usage instructions
  readme_content <- "
  # Deployment Bundle for Model API
  This bundle includes the following files:
  - Trained model file: `final_model.rds`
  - Preprocessing recipe: `recipe.rds`
  - Example input data: `example_data.csv`

  ## API Instructions
  - Expected input format: JSON payload following the format in `example_data.csv`
  - Output: Predicted values in JSON format.
  "
  writeLines(readme_content, con = file.path(bundle_dir, "README.md"))

  cat("Deployment bundle created at:", bundle_dir, "\n")
}

# Usage:
prepare_deployment_bundle("final_model.rds", "recipe.rds")

# Explanation:
# This function packages the model and preprocessing recipe into a specified `deployment_bundle` directory.
# An example dataset (first few rows) is also saved, providing an input reference format. Additionally,
# a README file with API usage instructions is created to document the deployment requirements.


# 3. API Development ------------------------------------------------------
# 3. API Development --------------------------------------------------------

# Load the necessary model and recipe files
model <- readRDS("deployment_bundle/final_model.rds")
recipe <- readRDS("deployment_bundle/recipe.rds")

# Define API using plumber
# Create a new plumber API object
#* @apiTitle Model Prediction API
#* @apiDescription API to generate predictions using a pre-trained model.

#' @plumber
function(pr) {

  #* Health Check Endpoint
  #* @get /health
  #* @serializer unboxedJSON
  function(req, res) {
    res$status <- 200
    list(status = "API is running")
  }

  #* Predict Endpoint
  #* @post /predict
  #* @param input:json The input data for prediction in JSON format
  #* @serializer unboxedJSON
  function(input, res) {
    # Log incoming request
    log_info("Received prediction request")

    tryCatch({
      # Parse input data and validate
      input_data <- jsonlite::fromJSON(input)

      # Check if input_data matches expected format
      if (!all(names(input_data) %in% names(bake(recipe, new_data = NULL)))) {
        stop("Invalid input format or missing required fields")
      }

      # Convert input to data frame and apply recipe
      input_df <- as_tibble(input_data)
      processed_data <- bake(recipe, new_data = input_df)

      # Generate predictions
      predictions <- predict(model, processed_data, type = "raw") %>%
        as.vector()

      # Return predictions as JSON
      res$status <- 200
      list(predictions = predictions)

    }, error = function(e) {
      # Log error and return error message
      log_error("Prediction request failed: {e$message}")
      res$status <- 400
      list(error = "Prediction failed", message = e$message)
    })
  }
}

# Explanation:
# - **Health Check Endpoint**: Returns a status message indicating if the API is running.
# - **Predict Endpoint**: Accepts JSON input, validates and preprocesses it, then uses the model to generate predictions.
# - **Error Handling**: If input data is invalid or any error occurs, an error message is returned in JSON format.
# - **Logging**: Logs are created for successful requests and errors to track API usage and troubleshoot issues.


# 4. Test API Locally -----------------------------------------------------
# 4. Test API Locally -------------------------------------------------------

# Load plumber for running the API locally
library(plumber)

# Define file path to API definition
api_file <- "path/to/api_definition.R"  # Replace with the actual path to this script

# Run the API locally
#* @apiTitle Local API Server for Model Prediction Testing
plumber::pr(api_file) %>%
  plumber::pr_run(port = 8000)

# Explanation:
# This code snippet starts a local API server on port 8000.
# Access it by navigating to http://localhost:8000/predict in your browser or API client.

# Simulate API Requests -----------------------------------------------------

# Load necessary packages for testing
library(httr)
library(jsonlite)

# Define sample data for testing
sample_data <- list(
  # Replace these with actual fields and values as expected by the model
  field1 = 5.2,
  field2 = "Category_A",
  field3 = 3.8
)

# Convert sample data to JSON format
sample_json <- toJSON(sample_data, auto_unbox = TRUE)

# Test Prediction Endpoint
response <- httr::POST(
  url = "http://localhost:8000/predict",
  body = sample_json,
  encode = "json",
  content_type("application/json")
)

# Check if the response status is successful
if (response$status_code == 200) {
  # Parse the response content if successful
  prediction_result <- content(response, "parsed")
  print("Prediction response:")
  print(prediction_result)
} else {
  # Print error message if the request fails
  cat("API request failed with status code:", response$status_code, "\n")
  print(content(response, "parsed"))
}

# Explanation:
# - **Run Local API Server**: The plumber API is started on a local server, allowing endpoint testing.
# - **Simulate API Requests**: A sample JSON request is sent to the `/predict` endpoint. The response is checked for success, with predictions printed if the call is successful or an error message displayed otherwise.
# - **Local Testing**: This approach ensures the API works as expected, handling correct predictions and error cases appropriately before full deployment.


# 5. API Deployment -------------------------------------------------------

# 5. API Deployment ---------------------------------------------------------

# Load necessary libraries
library(plumber)
library(config)

# Configuration Setup ------------------------------------------------------

# Define environment variables
# Using the config package to set environment-specific settings
config <- config::get()

api_port <- config$api_port       # Example: 8000 for local, 80 or 443 for production
api_host <- config$api_host       # Example: "0.0.0.0" for public, "127.0.0.1" for private/local
api_key <- Sys.getenv("API_KEY")  # Secure key if needed for API authentication

# Explanation:
# - **Environment Variables**: Environment variables are loaded from a config file or set through `Sys.getenv()` for sensitive data.
# - **Deployment Flexibility**: This setup ensures flexible deployment, as you can adjust settings per environment without modifying the code.

# API Deployment Command ----------------------------------------------------

# Deploy the API to the server
# Replace `api_file` with the actual path to your API definition script

#* @apiTitle Production API Deployment

deploy_api <- function(api_file, host = api_host, port = api_port) {
  pr(api_file) %>%
    pr_run(host = host, port = port)
}

# Run deployment
deploy_api("path/to/api_definition.R")

# Explanation:
# - **deploy_api Function**: This function deploys the API to the specified `host` and `port` based on environment variables.
# - **Run Deployment**: It uses the `plumber::pr_run()` function to start the API on the production server or cloud environment.
# - **API Security**: Ensure API keys and other sensitive information are securely set as environment variables and not hardcoded.

# Additional Notes on Cloud Deployment --------------------------------------

# When deploying to cloud services (e.g., AWS, Azure, Google Cloud), consider:
# - **Docker Containers**: Wrap the API into a Docker container for portability and scalability.
# - **Kubernetes or Serverless Setup**: For larger applications, consider Kubernetes or serverless functions.
# - **Load Balancing and Scaling**: Set up load balancing and autoscaling if high availability is required.
# - **Monitoring**: Use monitoring tools like CloudWatch (AWS) or Application Insights (Azure) to track API performance in production.

# Explanation:
# This section ensures the API is ready for production deployment, with configuration settings for each environment, secure handling of sensitive data, and flexibility for cloud or on-premise deployments.

# 6. Post-Deployment Verification -----------------------------------------

# 6. Post-Deployment Verification ------------------------------------------------

# Load necessary libraries
library(httr)
library(logger)
library(lubridate)

# Set API Health Check Endpoint
health_check_url <- paste0("http://", api_host, ":", api_port, "/health")

# Schedule Health Checks ----------------------------------------------------

#' Health Check Function
#'
#' @return Log message confirming API health status or indicating failure
#' @export
health_check <- function(url = health_check_url) {
  response <- tryCatch({
    httr::GET(url)
  }, error = function(e) {
    NULL
  })

  status <- if (!is.null(response) && httr::status_code(response) == 200) {
    log_info("API Health Check Successful at {Sys.time()} - Status: {httr::status_code(response)}")
    TRUE
  } else {
    log_error("API Health Check Failed at {Sys.time()}")
    FALSE
  }

  status
}

# Automate Health Checks
# Schedule using a cron job or similar scheduler
# Example: Run every hour with cron: `0 * * * * Rscript -e 'health_check()'`

# Explanation:
# - **Health Check Function**: This function checks the health of the API by sending a GET request to the `/health` endpoint.
# - **Automated Scheduling**: Set up a cron job to run this script periodically, such as every hour, to ensure the API is live and responsive.

# Validate API Responses ---------------------------------------------------

#' Test API with Sample Data
#'
#' @param test_data A data frame representing a sample input for the API.
#' @param url The URL for the prediction endpoint.
#'
#' @return Logs the API response, including status and message
#' @export
test_api_response <- function(test_data, url = paste0("http://", api_host, ":", api_port, "/predict")) {
  response <- tryCatch({
    httr::POST(url, body = jsonlite::toJSON(test_data, auto_unbox = TRUE), encode = "json")
  }, error = function(e) {
    log_error("Error in API response at {Sys.time()}: {e$message}")
    NULL
  })

  if (!is.null(response)) {
    response_status <- httr::status_code(response)
    response_content <- content(response, "text", encoding = "UTF-8")
    log_info("API Test Response at {Sys.time()} - Status: {response_status}, Response: {response_content}")
    return(response_content)
  } else {
    log_warning("Failed to receive API response.")
  }
}

# Example test data for validation
test_data <- list(input_feature1 = 0.5, input_feature2 = 1.2, input_feature3 = "example")

# Run test
test_api_response(test_data)

# Explanation:
# - **API Response Validation**: This function tests the deployed API by sending sample data to the `/predict` endpoint and logs the response.
# - **Error Logging**: Logs any errors that occur during the request and captures both valid and invalid cases.

# Log API Responses --------------------------------------------------------

# Set up a logging mechanism to capture responses from health checks and test requests.

#' Log API Status and Performance
#'
#' @param response_content Content returned by the API for analysis
#' @param timestamp The time of the request
#' @param response_time Time taken for the response
#'
#' @return None. Logs data for analysis.
#' @export
log_api_performance <- function(response_content, timestamp = Sys.time(), response_time) {
  log_entry <- tibble(
    timestamp = timestamp,
    response_time = response_time,
    response_content = response_content
  )

  # Append log to a CSV file or database
  write_csv(log_entry, "logs/api_responses_log.csv", append = TRUE)
}

# Calculate response time and log
start_time <- Sys.time()
response_content <- test_api_response(test_data)
end_time <- Sys.time()
log_api_performance(response_content, timestamp = start_time, response_time = as.numeric(difftime(end_time, start_time, units = "secs")))

# Explanation:
# - **Log API Performance**: Records response time, content, and timestamp in a CSV file for future analysis.
# - **Response Time Tracking**: Measures the duration between sending a request and receiving a response, useful for performance monitoring.




