
# instruction:
# transform the code into a more advanced style, leveraging pipes (%>%), mutate, summarize,
# and other tidyverse techniques. Make sure the code is modular and efficient. Take best R coding
# practices for data science and ML projects to make the code readable, modular, and scalable.
# Write function when tasks are repetitive, complex, or require flexibility, improving readability, reusability, and consistency. Avoid functions for one-off code, simple transformations, or linear workflows, as they may add unnecessary complexity.
# if writing function, use Roxygen2-style comments to make the functions readable and modular.


# 1. Load Required Libraries -------------------------------------------------

# Load essential libraries for performance monitoring, data handling, and time-based analysis.
library(tidyverse)
library(yardstick)   # For evaluating model performance
library(lubridate)   # For handling date and time

# Explanation:
# Loading these libraries ensures that we have the tools needed for analyzing model performance,
# visualizing results, and managing time-based monitoring processes.

# 2. Load Production Model and Data ------------------------------------------

# Define paths or connection strings for loading the model and data
model_path <- "path/to/production_model.rds"
data_path <- "path/to/new_data.csv"
recipe_path <- "path/to/preprocessing_recipe.rds"

# Load the production model
production_model <- readRDS(model_path)

# Load new data to be used for monitoring
new_data <- read_csv(data_path)

# Load preprocessing recipe and apply it to the new data
preprocessing_recipe <- readRDS(recipe_path)
processed_data <- bake(preprocessing_recipe, new_data)

# Define the monitoring period
monitoring_period <- lubridate::interval(
  start = lubridate::ymd("2024-01-01"),
  end = Sys.Date()
)

# Explanation:
# - The production model and recent data are loaded into the environment.
# - The preprocessing recipe ensures consistency in data transformations before predictions.
# - Defining a monitoring period establishes a clear timeframe for performance analysis.


# 3. Set Up Model Monitoring Metrics --------------------------------------
# 3. Set Up Model Monitoring Metrics -----------------------------------------

# Define primary performance metrics based on model type
# For classification models: accuracy, precision, recall, and ROC AUC
# For regression models: RMSE, MAE

#' Calculate Model Performance Metrics
#'
#' @param predictions A tibble containing the predictions and actual outcomes.
#' @param model_type A string specifying the model type: "classification" or "regression".
#'
#' @return A tibble with calculated performance metrics.
#' @export
calculate_performance_metrics <- function(predictions, model_type) {
  if (model_type == "classification") {
    predictions %>%
      metrics(truth = actual, estimate = .pred_class) %>%
      bind_rows(
        predictions %>% roc_auc(truth = actual, .pred) %>% rename(.metric = ".metric", .estimate = ".estimate"),
        predictions %>% recall(truth = actual, estimate = .pred_class) %>% rename(.metric = ".metric", .estimate = ".estimate"),
        predictions %>% precision(truth = actual, estimate = .pred_class) %>% rename(.metric = ".metric", .estimate = ".estimate")
      )
  } else if (model_type == "regression") {
    predictions %>%
      metrics(truth = actual, estimate = .pred) %>%
      bind_rows(
        predictions %>% rmse(truth = actual, estimate = .pred) %>% rename(.metric = ".metric", .estimate = ".estimate"),
        predictions %>% mae(truth = actual, estimate = .pred) %>% rename(.metric = ".metric", .estimate = ".estimate")
      )
  }
}

# Calculate performance metrics on new data
predictions <- bind_cols(processed_data, predict(production_model, processed_data))
performance_metrics <- calculate_performance_metrics(predictions, model_type = "classification")

# Define metrics for drift detection using Population Stability Index (PSI)
#' Calculate Population Stability Index (PSI)
#'
#' @param old_data A tibble of previous production data.
#' @param new_data A tibble of recent production data.
#' @param variable A string specifying the variable to analyze for drift.
#'
#' @return A numeric value representing the PSI for the specified variable.
#' @export
calculate_psi <- function(old_data, new_data, variable) {
  old_dist <- old_data %>%
    count(!!sym(variable)) %>%
    mutate(prop = n / sum(n))

  new_dist <- new_data %>%
    count(!!sym(variable)) %>%
    mutate(prop = n / sum(n))

  psi <- old_dist %>%
    full_join(new_dist, by = variable, suffix = c("_old", "_new")) %>%
    mutate(
      prop_old = replace_na(prop_old, 0),
      prop_new = replace_na(prop_new, 0),
      psi_contrib = (prop_new - prop_old) * log(prop_new / prop_old)
    ) %>%
    summarise(psi = sum(psi_contrib, na.rm = TRUE)) %>%
    pull(psi)

  return(psi)
}

# Calculate PSI for relevant variables
psi_results <- list(
  feature1 = calculate_psi(old_data = previous_data, new_data = processed_data, variable = "feature1"),
  feature2 = calculate_psi(old_data = previous_data, new_data = processed_data, variable = "feature2")
)

# Explanation:
# - `calculate_performance_metrics` function computes classification or regression metrics based on the model type.
# - `calculate_psi` function calculates Population Stability Index (PSI) to monitor for data drift.
# - The performance metrics and PSI results provide insights into model accuracy and data stability.


# 4. Generate Predictions on New Data -------------------------------------
# 4. Generate Predictions on New Data ----------------------------------------

#' Generate Predictions and Calculate Monitoring Metrics
#'
#' @param model A trained model object.
#' @param new_data A tibble with preprocessed data for generating predictions.
#' @param model_type A string specifying the model type: "classification" or "regression".
#'
#' @return A tibble with actual values, predictions, and monitoring metrics.
#' @export
generate_predictions_and_metrics <- function(model, new_data, model_type) {
  predictions <- bind_cols(
    new_data,
    predict(model, new_data, type = ifelse(model_type == "classification", "prob", "raw"))
  ) %>%
    rename(prediction = .pred)

  monitoring_metrics <- calculate_performance_metrics(predictions, model_type)

  list(predictions = predictions, metrics = monitoring_metrics)
}

# Generate predictions and calculate metrics
results <- generate_predictions_and_metrics(production_model, processed_data, model_type = "classification")
new_predictions <- results$predictions
monitoring_metrics <- results$metrics

# Log metrics for trend analysis
log_metrics <- function(metrics) {
  metrics %>%
    mutate(
      timestamp = Sys.time(),
      model_version = "1.0.1"  # replace with dynamic versioning if needed
    ) %>%
    write_csv(paste0("monitoring_logs/metrics_log_", Sys.Date(), ".csv"), append = TRUE)
}

log_metrics(monitoring_metrics)

#' Detect Prediction Drift
#'
#' @param new_predictions A tibble with recent model predictions.
#' @param historical_metrics A tibble with past metrics for comparison.
#' @param drift_threshold Numeric, threshold for detecting drift.
#'
#' @return A message indicating if drift is detected.
#' @export
detect_drift <- function(new_predictions, historical_metrics, drift_threshold = 0.1) {
  recent_accuracy <- new_predictions %>%
    summarise(accuracy = mean(actual == prediction)) %>%
    pull(accuracy)

  historical_accuracy <- historical_metrics %>%
    filter(.metric == "accuracy") %>%
    summarise(avg_accuracy = mean(.estimate)) %>%
    pull(avg_accuracy)

  drift_detected <- abs(recent_accuracy - historical_accuracy) > drift_threshold

  if (drift_detected) {
    cat("Drift detected: Model accuracy changed by more than", drift_threshold, "\n")
  } else {
    cat("No drift detected\n")
  }
}

# Compare predictions to detect potential drift
historical_metrics <- read_csv("monitoring_logs/metrics_log_previous.csv")
detect_drift(new_predictions, historical_metrics)

# Explanation:
# - `generate_predictions_and_metrics`: Generates predictions and calculates monitoring metrics on new data.
# - `log_metrics`: Logs the metrics for trend analysis by appending to a CSV.
# - `detect_drift`: Compares recent prediction accuracy with historical data to detect any significant drift.
#   This step is essential for identifying if the model performance on new data is significantly different.


# 5. Log and Store Monitoring Metrics -------------------------------------
# 5. Log and Store Monitoring Metrics ----------------------------------------

#' Log Monitoring Metrics with Timestamp
#'
#' @param metrics A tibble of calculated performance metrics.
#' @param log_path File path for saving the metrics log.
#'
#' @return None. Saves metrics to a log file.
#' @export
log_monitoring_metrics <- function(metrics, log_path = "monitoring_logs/metrics_history.csv") {
  metrics %>%
    mutate(timestamp = Sys.time()) %>%
    write_csv(log_path, append = TRUE)
}

# Log the current monitoring metrics
log_monitoring_metrics(monitoring_metrics)

#' Set Up and Check Alert Thresholds
#'
#' @param metrics A tibble of the latest performance metrics.
#' @param threshold_list A named list of thresholds for alerting.
#'
#' @return None. Prints alert messages if any metric exceeds thresholds.
#' @export
check_alert_thresholds <- function(metrics, threshold_list = list(accuracy = 0.8, drift = 0.1)) {
  metrics %>%
    pivot_longer(cols = starts_with(".estimate"), names_to = "metric", values_to = "value") %>%
    mutate(alert = case_when(
      metric == "accuracy" & value < threshold_list$accuracy ~ "Accuracy below threshold!",
      metric == "drift" & value > threshold_list$drift ~ "Drift exceeds acceptable limit!",
      TRUE ~ NA_character_
    )) %>%
    filter(!is.na(alert)) %>%
    pull(alert) %>%
    walk(~ cat(.x, "\n"))  # Print alerts if thresholds are breached
}

# Check for any alerts based on latest metrics
check_alert_thresholds(monitoring_metrics)

# Explanation:
# - `log_monitoring_metrics`: Logs metrics with a timestamp to a CSV file, facilitating trend analysis over time.
# - `check_alert_thresholds`: Compares each metric to predefined thresholds and prints an alert message if any thresholds are breached. This ensures timely notification of any significant performance drop or drift.


# 6. Generate Monitoring Report -------------------------------------------
# 6. Generate Monitoring Report ---------------------------------------------

# Load required libraries for report generation
library(rmarkdown)

#' Generate Monitoring Report
#'
#' @param metrics A tibble containing historical performance and drift metrics.
#' @param actions_log A tibble documenting observations and actions taken.
#' @param report_path File path to save the generated report.
#'
#' @return None. Produces a report in HTML or PDF format.
#' @export
generate_monitoring_report <- function(metrics, actions_log, report_path = "monitoring_reports/monitoring_report.html") {

  # Summarize key metrics over the monitoring period
  metrics_summary <- metrics %>%
    group_by(date = as.Date(timestamp)) %>%
    summarize(
      mean_accuracy = mean(accuracy, na.rm = TRUE),
      mean_drift = mean(drift, na.rm = TRUE),
      max_accuracy_drop = min(accuracy, na.rm = TRUE),
      max_drift = max(drift, na.rm = TRUE),
      .groups = "drop"
    )

  # Compile actions log for documentation
  actions_summary <- actions_log %>%
    mutate(date = as.Date(action_date)) %>%
    group_by(date) %>%
    summarize(actions = paste(observation, collapse = "; "), .groups = "drop")

  # Create a markdown template for the report
  report_template <- "
  ---
  title: 'Model Monitoring Report'
  output: html_document
  ---

  ## Model Performance Summary
  ```{r}
  metrics_summary

# Observations and Actions Log

actions_summary"



# Write the markdown template to a temporary .Rmd file
temp_rmd <- tempfile(fileext = ".Rmd") writeLines(report_template, temp_rmd)

# Render the markdown file to the specified report path
rmarkdown::render(temp_rmd, output_file = report_path, quiet = TRUE) cat("Monitoring report generated and saved to:", report_path, "\n") }

# sample data for actions log
actions_log <- tibble( action_date = Sys.Date() - 1:5, observation = c("Accuracy drop detected; tuning initiated", "Drift threshold exceeded; analysis conducted", "Retraining completed", "No significant issues", "Minor accuracy fluctuation noted") )

# Generate the monitoring report
generate_monitoring_report(metrics = monitoring_metrics, actions_log = actions_log)

# Explanation:
# - generate_monitoring_report: This function creates a structured report by summarizing performance and drift metrics.
# It also logs observations or actions taken and generates a report in HTML format.
# - The report includes a summary of model performance, an actions log, and key insights, saved in a shareable HTML format.



# 7. Plan for Model Retraining and Updates --------------------------------
# 7. Plan for Model Retraining and Updates ------------------------------------

# Load necessary libraries for retraining and updating
library(tidyverse)
library(lubridate)

# Define a threshold for accuracy drop and drift detection
accuracy_threshold <- 0.85
drift_threshold <- 0.1

#' Check Retraining Criteria
#'
#' @param metrics A tibble containing performance and drift metrics over time.
#' @param accuracy_threshold Numeric, minimum acceptable accuracy level.
#' @param drift_threshold Numeric, maximum acceptable drift value.
#'
#' @return Boolean indicating whether retraining is required.
#' @export
check_retraining_criteria <- function(metrics, accuracy_threshold, drift_threshold) {
  latest_metrics <- metrics %>% filter(timestamp == max(timestamp))

  # Check if retraining criteria are met
  retrain <- latest_metrics %>%
    filter(accuracy < accuracy_threshold | drift > drift_threshold) %>%
    nrow() > 0

  retrain
}

# Sample metrics tibble to illustrate
metrics <- tibble(
  timestamp = Sys.Date() - 10:1,
  accuracy = c(0.88, 0.87, 0.86, 0.85, 0.84, 0.83, 0.82, 0.81, 0.80, 0.79),
  drift = c(0.05, 0.06, 0.07, 0.08, 0.09, 0.1, 0.11, 0.12, 0.13, 0.14)
)

# Determine if retraining is necessary
retrain_needed <- check_retraining_criteria(metrics, accuracy_threshold, drift_threshold)

# If retraining is required, proceed to the model retraining script
if (retrain_needed) {
  cat("Retraining triggered due to performance or drift issues. Redirecting to model_training_and_tuning.R.\n")
  # Source the retraining script
  source("model_training_and_tuning.R")

  # Update monitoring process after retraining
  # Load the retrained model
  retrained_model <- readRDS("models/latest_trained_model.rds")

  # Reset monitoring metrics for the new model cycle
  monitoring_metrics <- tibble(
    timestamp = Sys.Date(),
    accuracy = NA,
    drift = NA
  )

  cat("Retraining completed, and monitoring process has been restarted.\n")
} else {
  cat("Model performance within acceptable limits; no retraining needed.\n")
}

# Explanation:
# 1. **Define Retraining Triggers**: `check_retraining_criteria` evaluates the most recent performance and drift metrics.
#    If accuracy falls below `accuracy_threshold` or drift exceeds `drift_threshold`, retraining is triggered.
# 2. **Retrain Model**: If retraining is triggered, the `model_training_and_tuning.R` script is sourced to retrain the model.
#    The newly trained model is saved, replacing the outdated production model.
# 3. **Update Production Model**: The monitoring metrics are reset to track performance from the updated model's deployment date.


