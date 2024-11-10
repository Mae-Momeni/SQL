
# instruction:
# transform the code into a more advanced style, leveraging pipes (%>%), mutate, summarize,
# and other tidyverse techniques. Make sure the code is modular and efficient. Take best R coding
# practices for data science and ML projects to make the code readable, modular, and scalable.
# Write function when tasks are repetitive, complex, or require flexibility, improving readability, reusability, and consistency. Avoid functions for one-off code, simple transformations, or linear workflows, as they may add unnecessary complexity.
# if writing function, use Roxygen2-style comments to make the functions readable and modular.


# 1. Load Required Libraries -------------------------------------------------

# Load essential libraries for model retraining, evaluation, and versioning
library(tidyverse)
library(tidymodels)
library(rsample)
library(lubridate)  # For date handling in versioning
# Additional libraries for specific models or versioning can be loaded here

# Explanation:
# This section loads the necessary libraries, ensuring all required functions and packages
# are available for data manipulation, model training, and versioning.

# 2. Load Model, Data, and Recipes -------------------------------------------

# Define paths for model, data, and recipe
model_path <- "models/production_model.rds"
data_path <- "data/latest_training_data.csv"
recipe_path <- "models/production_recipe.rds"

#' Load Production Model, Data, and Recipe
#'
#' @param model_path Path to the saved model file.
#' @param data_path Path to the latest training dataset.
#' @param recipe_path Path to the saved preprocessing recipe.
#'
#' @return A list containing the loaded model, data, and recipe.
#' @export
load_model_data_recipe <- function(model_path, data_path, recipe_path) {
  list(
    model = readRDS(model_path),
    data = read_csv(data_path),
    recipe = readRDS(recipe_path)
  )
}

# Load model, data, and recipe
resources <- load_model_data_recipe(model_path, data_path, recipe_path)
prod_model <- resources$model
training_data <- resources$data
prod_recipe <- resources$recipe

# Explanation:
# This section defines a function to load the production model, new training data, and preprocessing recipe.
# By loading these items at the beginning, they are ready for comparison and retraining steps.
# The `list()` structure keeps the resources organized for easy access.


# 3. Define Retraining Criteria ----------------------------------------------

# Set retraining criteria and version control for tracking model retraining cycles

#' Check if Retraining is Required
#'
#' @param model_performance Numeric value of current model performance (e.g., accuracy).
#' @param threshold Numeric, performance threshold below which retraining is triggered.
#' @param last_retrained Date, last retraining date.
#' @param retrain_interval Numeric, the number of days before a time-based retraining is triggered.
#'
#' @return Logical, indicating whether retraining is needed.
#' @export
check_retraining_needed <- function(model_performance, threshold, last_retrained, retrain_interval = 30) {
  performance_trigger <- model_performance < threshold
  time_trigger <- as.numeric(Sys.Date() - last_retrained) > retrain_interval
  performance_trigger || time_trigger
}

# Define retraining parameters
current_model_performance <- 0.88   # Example current performance metric
performance_threshold <- 0.90       # Performance threshold for retraining
last_retrained_date <- as.Date("2023-01-01") # Example date
retrain_interval_days <- 30

# Check if retraining is needed
needs_retraining <- check_retraining_needed(
  model_performance = current_model_performance,
  threshold = performance_threshold,
  last_retrained = last_retrained_date,
  retrain_interval = retrain_interval_days
)

if (needs_retraining) {
  cat("Retraining is required based on defined criteria.\n")
} else {
  cat("Retraining is not required at this time.\n")
}

# Version Control Setup ------------------------------------------------------

# Define a function to generate a version tag based on date and performance

#' Generate Model Version Tag
#'
#' @param model_performance Numeric, model performance metric to include in the version tag.
#'
#' @return A character string representing the model version.
#' @export
generate_version_tag <- function(model_performance) {
  paste0("v", format(Sys.Date(), "%Y%m%d"), "_", round(model_performance * 100, 0))
}

# Example of generating a version tag for the new model
new_model_version <- generate_version_tag(current_model_performance)
cat("New model version:", new_model_version, "\n")

# Explanation:
# - **Set Retraining Triggers**: The function `check_retraining_needed()` evaluates whether retraining is required based on model performance and a time interval. It triggers retraining if either the performance drops below a set threshold or a set period has passed since the last retraining.
# - **Version Control Setup**: `generate_version_tag()` creates a version tag that includes the current date and rounded performance metric, helping to identify model versions easily. This tag can be used to track and log retraining cycles.


# 4. Retrain the Model ----------------------------------------------------
# 4. Retrain the Model -------------------------------------------------------

# Load necessary libraries
library(tidyverse)
library(tidymodels)

#' Retrain Model with Cross-Validation and Hyperparameter Tuning
#'
#' @param data A data frame with training data.
#' @param model_spec A model specification object.
#' @param recipe A preprocessing recipe object.
#' @param tune_params Logical, whether to tune hyperparameters (default: TRUE).
#' @param folds Number of cross-validation folds (default: 5).
#'
#' @return A tuned workflow object.
#' @export
retrain_model <- function(data, model_spec, recipe, tune_params = TRUE, folds = 5) {
  # Set up cross-validation folds
  cv_folds <- vfold_cv(data, v = folds)

  # Create workflow combining recipe and model
  workflow <- workflow() %>%
    add_model(model_spec) %>%
    add_recipe(recipe)

  # Define tuning grid if tuning is enabled
  if (tune_params) {
    tuning_grid <- grid_latin_hypercube(
      trees(),
      tree_depth(),
      learn_rate(),
      loss_reduction(),
      sample_size = sample_prop(),
      size = 10
    )

    # Tune model across CV folds
    results <- tune_grid(
      workflow,
      resamples = cv_folds,
      grid = tuning_grid,
      metrics = metric_set(roc_auc, accuracy, rmse)
    )
  } else {
    # Fit without tuning
    results <- fit_resamples(
      workflow,
      resamples = cv_folds,
      metrics = metric_set(roc_auc, accuracy, rmse)
    )
  }

  # Return the tuning results
  results
}

# Define model specifications and recipe (examples)
model_spec <- boost_tree(trees = 1000, tree_depth = 6) %>%
  set_engine("xgboost") %>%
  set_mode("classification")

data_recipe <- create_recipe(data = training_data, target_var = "target_variable")

# Retrain model with cross-validation and tuning if necessary
retrained_results <- retrain_model(
  data = training_data,
  model_spec = model_spec,
  recipe = data_recipe,
  tune_params = TRUE,
  folds = 5
)

# Evaluate Retrained Model ---------------------------------------------------

#' Evaluate Model Performance
#'
#' @param results A resample or tuning results object.
#'
#' @return A tibble with mean performance metrics.
#' @export
evaluate_model_performance <- function(results) {
  collect_metrics(results) %>%
    group_by(.metric) %>%
    summarise(mean = mean(mean), .groups = "drop") %>%
    pivot_wider(names_from = .metric, values_from = mean)
}

# Collect metrics for retrained model
retrained_metrics <- evaluate_model_performance(retrained_results)
print(retrained_metrics)

# Compare with production model's performance
cat("\nComparing retrained model metrics with production model:\n")
print(production_model_metrics)
print(retrained_metrics)

# Explanation:
# - **Use Cross-Validation for Retraining**: The `retrain_model()` function performs cross-validation on the updated data. If `tune_params` is set to `TRUE`, it tunes the model using a Latin hypercube grid. A custom `recipe` is applied to ensure consistent preprocessing.
# - **Tune Hyperparameters**: Hyperparameter tuning is optional and configured via the `tune_params` parameter. If enabled, a grid search tunes key parameters, enhancing model performance with updated data.
# - **Evaluate Retrained Model**: The `evaluate_model_performance()` function collects and summarizes mean performance metrics, which are then compared with the production model’s metrics for assessment.


# 5. Compare and Validate Model Versions ----------------------------------

# 5. Compare and Validate Model Versions -------------------------------------

# Load necessary libraries
library(tidyverse)

#' Compare Model Performance Metrics
#'
#' @param production_metrics A tibble with performance metrics of the production model.
#' @param retrained_metrics A tibble with performance metrics of the retrained model.
#'
#' @return A tibble with performance comparison.
#' @export
compare_model_performance <- function(production_metrics, retrained_metrics) {
  production_metrics %>%
    full_join(retrained_metrics, by = ".metric", suffix = c("_production", "_retrained")) %>%
    mutate(
      performance_improvement = across(ends_with("_retrained")) - across(ends_with("_production"))
    )
}

# Compare retrained model with production model
comparison_metrics <- compare_model_performance(production_model_metrics, retrained_metrics)
print(comparison_metrics)

# Select Model for Deployment
# ----------------------------------------------------------------------------

#' Determine Model for Deployment
#'
#' @param comparison A tibble with performance comparison metrics.
#' @param improvement_threshold A named list specifying minimum improvement required for each metric.
#'
#' @return A character indicating the model selected for deployment.
#' @export
select_model_for_deployment <- function(comparison, improvement_threshold = list(accuracy = 0.01, roc_auc = 0.01)) {
  improvement_check <- comparison %>%
    filter(!is.na(performance_improvement)) %>%
    summarise(
      deploy_retrained = all(
        map2_lgl(performance_improvement, names(improvement_threshold),
                 ~ .x >= improvement_threshold[[.y]]))
    ) %>%
    pull(deploy_retrained)

  if (improvement_check) {
    cat("Deploying retrained model.\n")
    "retrained"
  } else {
    cat("Retaining production model.\n")
    "production"
  }
}

# Set improvement thresholds (customizable)
improvement_thresholds <- list(accuracy = 0.01, roc_auc = 0.01)

# Decide on model deployment
selected_model <- select_model_for_deployment(comparison_metrics, improvement_thresholds)

# Explanation:
# - **Performance Comparison**: The `compare_model_performance()` function compares metrics for the retrained and production models, calculating the performance improvement for each metric.
# - **Select Model for Deployment**: The `select_model_for_deployment()` function checks if the retrained model meets predefined performance thresholds. If so, it recommends deploying the retrained model; otherwise, it retains the production model.


# 6. Version and Save the Model -------------------------------------------

# 6. Version and Save the Model ---------------------------------------------

# Load necessary libraries
library(tidyverse)
library(lubridate)

#' Generate Model Version Identifier
#'
#' @param base_name A character string for the model's base name (e.g., "model_xgb").
#' @return A character string representing the versioned model name with timestamp.
#' @export
generate_version_id <- function(base_name) {
  paste0(base_name, "_v", format(Sys.time(), "%Y%m%d_%H%M%S"))
}

# Example base name (e.g., "xgboost_model" or "gam_model")
model_base_name <- ifelse(selected_model == "retrained", "retrained_model", "production_model")
versioned_model_id <- generate_version_id(model_base_name)

#' Save Model with Versioning
#'
#' @param model A trained model object.
#' @param model_id A versioned model identifier.
#' @param metrics A tibble with model performance metrics.
#' @param metadata_path File path for saving model metadata.
#' @param model_dir Directory path for saving versioned model files.
#'
#' @return None. Saves model and metadata.
#' @export
save_versioned_model <- function(model, model_id, metrics, metadata_path, model_dir = "models/") {
  # Create directory if it doesn't exist
  dir.create(model_dir, showWarnings = FALSE, recursive = TRUE)

  # Define paths
  model_path <- file.path(model_dir, paste0(model_id, ".rds"))
  metadata_path <- file.path(model_dir, paste0(model_id, "_metadata.csv"))

  # Save model object
  saveRDS(model, model_path)
  cat("Model saved at:", model_path, "\n")

  # Prepare and save metadata
  model_metadata <- metrics %>%
    mutate(model_id = model_id, saved_at = Sys.time()) %>%
    bind_rows() %>%
    select(model_id, saved_at, everything())

  write_csv(model_metadata, metadata_path)
  cat("Model metadata saved at:", metadata_path, "\n")
}

# Save the selected model (either retrained or production)
if (selected_model == "retrained") {
  save_versioned_model(fit_retrained_model, versioned_model_id, retrained_metrics, "models/")
} else {
  save_versioned_model(fit_production_model, versioned_model_id, production_model_metrics, "models/")
}

# Explanation:
# - **Update Model Version**: The `generate_version_id()` function creates a unique version identifier using a base name and timestamp, ensuring traceability.
# - **Save Model to Versioned Directory**: The `save_versioned_model()` function saves the model object and stores it with a unique version ID in a designated folder.
# - **Log Model Metadata**: This function also logs model metadata, including performance metrics, version ID, and timestamp, for easy tracking and reproducibility.


# 7. Deploy the Retrained Model -------------------------------------------
# 7. Deploy the Retrained Model (if applicable) ----------------------------

# Load necessary libraries
library(tidyverse)

#' Deploy Model to Production
#'
#' @param model A trained model object to be deployed.
#' @param deploy_path File path to save the production model.
#' @param metadata A tibble containing model metadata (e.g., version, performance metrics).
#' @param monitor_log_path Path to save the monitoring log.
#'
#' @return None. Saves the model to the production location and updates the monitoring log.
#' @export
deploy_model_to_production <- function(model, deploy_path = "production_model.rds", metadata, monitor_log_path = "monitoring/monitor_log.csv") {
  # Save the model to the production path
  saveRDS(model, deploy_path)
  cat("Model deployed to production at:", deploy_path, "\n")

  # Update monitoring log
  metadata <- metadata %>%
    mutate(deployed_at = Sys.time(), status = "active")

  # Create monitoring directory if not exists
  dir.create(dirname(monitor_log_path), showWarnings = FALSE, recursive = TRUE)

  # Append to or create a monitoring log file
  if (file.exists(monitor_log_path)) {
    write_csv(metadata, monitor_log_path, append = TRUE)
  } else {
    write_csv(metadata, monitor_log_path)
  }
  cat("Monitoring log updated at:", monitor_log_path, "\n")
}

# Deploy retrained model if selected for production
if (selected_model == "retrained") {
  deploy_model_to_production(fit_retrained_model, "production_model.rds", retrained_metadata, "monitoring/monitor_log.csv")
} else {
  cat("Retrained model not selected for deployment. No updates made to production model.\n")
}

# Explanation:
# - **Deploy New Model to Production**: The `deploy_model_to_production()` function replaces the production model with the retrained model if it meets performance criteria, saving it as "production_model.rds".
# - **Update Monitoring Process**: Metadata for the deployed model is appended to a monitoring log file, capturing the deployment time, version, and performance metrics. This helps in tracking model performance over time and maintaining an audit trail.



# 8. Archive and Document Model Versions ----------------------------------

# 8. Archive and Document Model Versions -----------------------------------

# Load necessary libraries
library(tidyverse)
library(fs) # For file handling

# Define paths for versioning
archive_dir <- "model_archive"
versioned_model_path <- file.path(archive_dir, paste0("model_", Sys.Date(), ".rds"))
documentation_path <- file.path(archive_dir, paste0("retraining_documentation_", Sys.Date(), ".md"))

#' Archive Previous Model Versions
#'
#' @param current_model_path The path of the current production model.
#' @param archive_path The destination path for archiving the model.
#'
#' @return None. Moves the current model to an archive location.
#' @export
archive_model <- function(current_model_path, archive_path) {
  dir_create(dirname(archive_path))
  file_copy(current_model_path, archive_path, overwrite = TRUE)
  cat("Current production model archived at:", archive_path, "\n")
}

#' Document Retraining Process
#'
#' @param documentation_path Path to save retraining documentation.
#' @param metadata A tibble containing details on retraining criteria, changes, and performance metrics.
#'
#' @return None. Saves retraining documentation to the specified path.
#' @export
document_retraining <- function(documentation_path, metadata) {
  doc_content <- paste0(
    "# Retraining Documentation - ", Sys.Date(), "\n\n",
    "## Retraining Criteria\n",
    "- Criteria: ", metadata$criteria, "\n\n",
    "## Changes Made\n",
    "- Changes: ", metadata$changes, "\n\n",
    "## Performance Comparison\n",
    "- Previous Model: ", metadata$prev_performance, "\n",
    "- New Model: ", metadata$new_performance, "\n"
  )

  dir_create(dirname(documentation_path))
  write_lines(doc_content, documentation_path)
  cat("Retraining process documented at:", documentation_path, "\n")
}

# Archive current production model
archive_model("production_model.rds", versioned_model_path)

# Document retraining process
retraining_metadata <- tibble(
  criteria = "Performance threshold and data drift",
  changes = "Hyperparameter tuning and data preprocessing adjustments",
  prev_performance = "Accuracy: 0.85, AUC: 0.88",
  new_performance = "Accuracy: 0.88, AUC: 0.90"
)
document_retraining(documentation_path, retraining_metadata)

# Explanation:
# - **Archive Previous Model Versions**: `archive_model()` saves the current production model as a backup in an archive folder, using a versioned filename based on the current date.
# - **Document Retraining Process**: `document_retraining()` creates a markdown file summarizing the retraining criteria, changes, and performance comparisons between the old and new models. This provides a detailed record of the retraining process for future reference.


