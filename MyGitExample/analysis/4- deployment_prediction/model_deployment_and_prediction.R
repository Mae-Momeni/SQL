
# instruction:
# transform the code into a more advanced style, leveraging pipes (%>%), mutate, summarize,
# and other tidyverse techniques. Make sure the code is modular and efficient. Take best R coding
# practices for data science and ML projects to make the code readable, modular, and scalable.
# Write function when tasks are repetitive, complex, or require flexibility, improving readability, reusability, and consistency. Avoid functions for one-off code, simple transformations, or linear workflows, as they may add unnecessary complexity.
# if writing function, use Roxygen2-style comments to make the functions readable and modular.



# 1. Load Required Libraries --------------------------------------------------

# Load essential libraries
library(tidyverse)
library(tidymodels)

# Explanation:
# `tidyverse` provides a suite of data manipulation tools.
# `tidymodels` contains tools for modeling workflows, recipes, and model evaluation.

# Load any additional libraries required for specific models (e.g., for XGBoost or GAM)
library(xgboost)  # Only if the model was trained using XGBoost
library(mgcv)     # Only if the model was trained using Generalized Additive Models


# 2. Load Trained Model -------------------------------------------------------

#' Load a Trained Model from File
#'
#' @param file_path A string indicating the file path of the saved model (.rds file).
#'
#' @return A trained model object.
#' @export
load_trained_model <- function(file_path) {
  model <- readRDS(file_path)
  if (!inherits(model, "workflow")) {
    stop("Loaded object is not a workflow. Please check the file path or model type.")
  }
  message("Model loaded successfully.")
  model
}

# Define the path to the trained model file
model_path <- "path/to/saved_model.rds"  # Replace with actual path

# Load the model
trained_model <- load_trained_model(model_path)

# Explanation:
# - The function `load_trained_model` loads a saved model from a specified file path.
# - `inherits` checks if the loaded object is of the `workflow` class to ensure it's a valid model.
# - The path to the model is defined as `model_path`, and the model is loaded into `trained_model`.


# 3. Data Preparation for New Data ----------------------------------------

# 3. Data Preparation for New Data --------------------------------------------

# Load necessary libraries if not already loaded
library(tidyverse)
library(tidymodels)

#' Load New Data for Prediction
#'
#' @param file_path A string indicating the file path of the new dataset (e.g., CSV file).
#'
#' @return A data frame with the new data.
#' @export
load_new_data <- function(file_path) {
  read_csv(file_path) %>%
    janitor::clean_names() %>%  # Ensures consistent column naming
    mutate(across(where(is.character), as.factor))  # Converts character columns to factors if needed
}

# Define path to the new data file
new_data_path <- "path/to/new_data.csv"  # Replace with actual path

# Load new data
new_data <- load_new_data(new_data_path)

#' Load and Prepare Recipe for New Data
#'
#' @param recipe_path Path to the saved preprocessing recipe (.rds file).
#' @param new_data Data frame containing the new data.
#'
#' @return A preprocessed data frame consistent with the model's requirements.
#' @export
apply_preprocessing <- function(recipe_path, new_data) {
  # Load saved recipe
  recipe <- readRDS(recipe_path)
  if (!inherits(recipe, "recipe")) {
    stop("Loaded object is not a recipe. Please check the file path.")
  }

  # Apply the recipe to the new data
  preprocessed_data <- recipe %>%
    prep(training = new_data, retain = TRUE) %>%  # Prepares recipe based on new data
    bake(new_data)  # Applies the recipe transformations

  preprocessed_data
}

# Define path to the saved recipe file
recipe_path <- "path/to/saved_recipe.rds"  # Replace with actual path

# Apply preprocessing to new data
preprocessed_data <- apply_preprocessing(recipe_path, new_data)

# Check for Consistency -------------------------------------------------------
#' Check Consistency of New Data with Model Expectations
#'
#' @param preprocessed_data The preprocessed new data.
#' @param model A trained model object.
#'
#' @return NULL; prints warnings if inconsistencies are detected.
#' @export
check_data_consistency <- function(preprocessed_data, model) {
  model_cols <- model$pre$mold$predictors %>% colnames()
  data_cols <- preprocessed_data %>% colnames()

  if (!all(model_cols %in% data_cols)) {
    missing_cols <- setdiff(model_cols, data_cols)
    warning("The following columns are missing in the new data: ", paste(missing_cols, collapse = ", "))
  }

  extra_cols <- setdiff(data_cols, model_cols)
  if (length(extra_cols) > 0) {
    warning("The new data has extra columns not required by the model: ", paste(extra_cols, collapse = ", "))
  }
}

# Perform consistency check
check_data_consistency(preprocessed_data, trained_model)

# Explanation:
# - `load_new_data`: Loads and cleans new data for prediction. Ensures column names are standardized and character columns are converted to factors if needed.
# - `apply_preprocessing`: Loads the saved recipe, preps it with the new data, and applies the necessary transformations to ensure consistency with training.
# - `check_data_consistency`: Verifies that the new data has the required columns and no unnecessary ones, aligning it with the model's expectations.


# 4. Generate Predictions -------------------------------------------------
# 4. Generate Predictions -----------------------------------------------------

# Load necessary libraries if not already loaded
library(tidymodels)

#' Generate Predictions for New Data
#'
#' @param model A trained model object.
#' @param data A preprocessed data frame ready for prediction.
#' @param type Character, specifies type of prediction: "class" or "prob" for classification, "numeric" for regression.
#'
#' @return A tibble with predictions (classes/probabilities for classification, numeric values for regression).
#' @export
generate_predictions <- function(model, data, type = "class") {
  predictions <- predict(model, data, type = type)

  if (type == "prob") {
    prob_predictions <- predict(model, data, type = "prob")
    predictions <- bind_cols(predictions, prob_predictions)
  }

  predictions
}

# Example: Generate Predictions
# Determine prediction type based on model mode
prediction_type <- ifelse(model$spec$mode == "classification", "class", "numeric")

# Generate predictions based on model type
predictions <- generate_predictions(trained_model, preprocessed_data, type = prediction_type)

#' Post-Process Predictions (optional for specific business logic)
#'
#' @param predictions A tibble of predictions.
#' @param model_type Character, specifies "classification" or "regression".
#' @param prob_threshold Numeric, optional threshold for classification (default = 0.5).
#' @param round_digits Integer, optional rounding digits for regression predictions.
#'
#' @return A tibble of processed predictions.
#' @export
post_process_predictions <- function(predictions, model_type, prob_threshold = 0.5, round_digits = NULL) {
  if (model_type == "classification") {
    if ("prob" %in% colnames(predictions)) {
      predictions <- predictions %>%
        mutate(pred_class = if_else(.pred_1 >= prob_threshold, "class_1", "class_0"))  # Adjust as per your class labels
    }
  } else if (model_type == "regression") {
    if (!is.null(round_digits)) {
      predictions <- predictions %>%
        mutate(pred_value = round(.pred, digits = round_digits))
    }
  }

  predictions
}

# Example of post-processing (for classification threshold or rounding in regression)
processed_predictions <- post_process_predictions(
  predictions,
  model_type = model$spec$mode,
  prob_threshold = 0.5,
  round_digits = 2  # Adjust as necessary
)

# Explanation:
# - `generate_predictions`: Uses the `predict` function to generate predictions, handling both class and probability predictions for classification, or numeric predictions for regression.
# - `post_process_predictions`: Optionally applies post-processing to handle probability thresholds for classifications or rounding for regression predictions, adding flexibility to handle business-specific logic.


# 5. Evaluate Predictions on Validation Set -------------------------------

# 5. Evaluate Predictions on Validation Set (Optional) ------------------------

# Load necessary libraries if not already loaded
library(tidymodels)
library(yardstick)

#' Evaluate Model on Validation Data
#'
#' @param model A trained model object.
#' @param validation_data A data frame containing validation data.
#' @param recipe A recipe object for preprocessing the validation data.
#' @param target_var Character, the name of the target variable in the validation data.
#'
#' @return A tibble with evaluation metrics.
#' @export
evaluate_model <- function(model, validation_data, recipe, target_var) {
  # Preprocess the validation data
  validation_prepped <- bake(recipe, new_data = validation_data)

  # Generate predictions
  prediction_type <- ifelse(model$spec$mode == "classification", "class", "numeric")
  predictions <- predict(model, validation_prepped, type = prediction_type) %>%
    bind_cols(validation_data %>% select(!!sym(target_var)))

  # Calculate evaluation metrics
  metrics <- if (model$spec$mode == "classification") {
    predictions %>%
      yardstick::metrics(truth = !!sym(target_var), estimate = .pred_class) %>%
      bind_rows(yardstick::roc_auc(predictions, truth = !!sym(target_var), .pred_1))  # Adjust .pred_1 for binary classes
  } else {
    predictions %>%
      yardstick::metrics(truth = !!sym(target_var), estimate = .pred) %>%
      filter(.metric %in% c("rmse", "mae", "rsq"))
  }

  metrics
}

# Example: Evaluate on Validation Data
validation_metrics <- evaluate_model(
  model = trained_model,
  validation_data = validation_data,
  recipe = data_recipe,
  target_var = "target"
)

#' Compare Training and Validation Performance
#'
#' @param train_metrics A tibble with metrics from training data.
#' @param validation_metrics A tibble with metrics from validation data.
#'
#' @return A tibble showing the difference between training and validation metrics.
#' @export
compare_performance <- function(train_metrics, validation_metrics) {
  validation_metrics %>%
    left_join(train_metrics, by = ".metric", suffix = c("_validation", "_training")) %>%
    mutate(performance_gap = .estimate_training - .estimate_validation)
}

# Example: Load and compare with training metrics (assuming `train_metrics` exists)
performance_comparison <- compare_performance(train_metrics, validation_metrics)

# Explanation:
# - `evaluate_model`: This function preprocesses the validation data, generates predictions, and calculates relevant metrics. For classifiers, it includes ROC AUC; for regressors, it includes RMSE, MAE, and R-squared.
# - `compare_performance`: Compares metrics from training and validation to highlight any performance gap, helping to diagnose issues like overfitting.



# 6. Save Predictions -----------------------------------------------------
# 6. Save Predictions --------------------------------------------------------

# Load necessary libraries if not already loaded
library(tidymodels)
library(tidyverse)

#' Save Predictions to File
#'
#' @param predictions A data frame containing prediction results.
#' @param file_path Character, the path where the predictions should be saved.
#' @param include_probs Logical, whether to include probability columns for classification models.
#'
#' @return None. Saves the predictions as a CSV file.
#' @export
save_predictions <- function(predictions, file_path, include_probs = FALSE) {
  # Include necessary columns: ID, predicted values, and probabilities (if specified)
  predictions_output <- predictions %>%
    select(ID, .pred_class, starts_with(".pred")) %>%
    if (!include_probs) select(-starts_with(".pred_")) else .

  # Save the output as a CSV
  write_csv(predictions_output, file_path)
  cat("Predictions saved to:", file_path, "\n")
}

# Example: Generate and save predictions
predictions <- predict(trained_model, new_data = validation_prepped, type = "prob") %>%
  bind_cols(validation_prepped %>% select(ID))  # Assuming ID column exists

# Save predictions with or without probabilities based on model type
is_classification <- trained_model$spec$mode == "classification"
save_predictions(predictions, file_path = "results/predictions.csv", include_probs = is_classification)

# Explanation:
# - `save_predictions`: This function takes in a predictions dataframe and saves it to a specified file path. It includes only essential columns such as ID, predicted class, and probabilities if `include_probs` is set to TRUE.
# - `predictions` and `save_predictions` example: The code snippet shows how predictions are generated and saved. For classification models, probabilities are saved by setting `include_probs = TRUE`.



# 7. Save Model Artifacts for Future Use ----------------------------------

# 7. Save Model Artifacts for Future Use --------------------------------------

# Load necessary libraries if not already loaded
library(tidymodels)
library(tidyverse)

#' Save Final Model Pipeline
#'
#' @param model_pipeline A trained workflow object that includes the preprocessing recipe and the model.
#' @param path Character, file path to save the model pipeline (e.g., .rds file).
#'
#' @return None. Saves the model pipeline to the specified path.
#' @export
save_model_pipeline <- function(model_pipeline, path = "models/final_model_pipeline.rds") {
  saveRDS(model_pipeline, path)
  cat("Model pipeline saved to:", path, "\n")
}

#' Document Model Version and Metadata
#'
#' @param model_pipeline_name Character, a descriptive name for the model (e.g., "XGBoost Classifier v1.0").
#' @param version Character, version number of the model.
#' @param date Date, date of model saving (default is the current date).
#' @param description Character, additional details about the model’s purpose, tuning details, or performance.
#' @param file_path Character, file path to save the documentation (e.g., .txt or .md file).
#'
#' @return None. Saves a text or markdown file with model metadata.
#' @export
document_model_metadata <- function(model_pipeline_name, version, date = Sys.Date(), description,
                                    file_path = "models/model_metadata.md") {
  metadata_content <- paste0(
    "# Model Metadata\n\n",
    "## Model Name\n", model_pipeline_name, "\n\n",
    "## Version\n", version, "\n\n",
    "## Date\n", format(date, "%Y-%m-%d"), "\n\n",
    "## Description\n", description, "\n\n",
    "## File Location\n", "Model Pipeline Path: ", file_path, "\n\n",
    "## Notes\n", "Ensure model compatibility and document any dependencies.\n"
  )

  writeLines(metadata_content, con = file_path)
  cat("Model metadata saved to:", file_path, "\n")
}

# Example usage
# Save the final model pipeline
save_model_pipeline(final_model_workflow, path = "models/final_model_pipeline.rds")

# Document model metadata
document_model_metadata(
  model_pipeline_name = "XGBoost Classifier v1.0",
  version = "1.0",
  description = "Final XGBoost classifier trained on the full dataset with optimal hyperparameters.",
  file_path = "models/model_metadata.md"
)

# Explanation:
# - `save_model_pipeline`: This function saves the full model pipeline, including preprocessing steps and the final model, as an RDS file for reproducibility.
# - `document_model_metadata`: This function generates a markdown file that includes the model name, version, date, description, and path to the saved model, providing crucial context for future reference.


# 8. Generate Deployment Report -------------------------------------------
# 8. Generate Deployment Report ---------------------------------------------

# Load necessary libraries if not already loaded
library(tidyverse)

#' Summarize Prediction Results
#'
#' @param predictions A data frame containing the prediction results, with columns for actual and predicted values.
#' @param model_type Character, the type of model ("classification" or "regression").
#'
#' @return A tibble summarizing key statistics or metrics based on the model type.
#' @export
summarize_prediction_results <- function(predictions, model_type = "classification") {
  if (model_type == "classification") {
    metrics <- predictions %>%
      yardstick::metrics(truth = actual, estimate = predicted) %>%
      filter(.metric %in% c("accuracy", "precision", "recall", "f_meas", "roc_auc"))
  } else if (model_type == "regression") {
    metrics <- predictions %>%
      yardstick::metrics(truth = actual, estimate = predicted) %>%
      filter(.metric %in% c("rmse", "rsq", "mae"))
  } else {
    stop("Invalid model type. Choose either 'classification' or 'regression'.")
  }

  metrics
}

#' Document Key Insights
#'
#' @param summary_metrics A tibble containing key metrics from the model evaluation.
#' @param additional_notes Character, additional findings or observations from the model evaluation.
#'
#' @return A character string containing the formatted insights.
#' @export
document_key_insights <- function(summary_metrics, additional_notes = NULL) {
  insights <- paste0(
    "## Key Insights from Model Predictions\n\n",
    "### Performance Metrics\n",
    knitr::kable(summary_metrics, format = "markdown"), "\n\n",
    "### Observations\n",
    if (!is.null(additional_notes)) additional_notes else "No additional observations."
  )

  insights
}

#' Save Deployment Report
#'
#' @param summary_metrics A tibble containing summary statistics or metrics.
#' @param insights Character, key insights from the model’s predictions.
#' @param file_path Character, the file path to save the report (e.g., "reports/deployment_report.md").
#'
#' @return None. Saves the report in markdown format.
#' @export
save_deployment_report <- function(summary_metrics, insights, file_path = "reports/deployment_report.md") {
  report_content <- paste0(
    "# Deployment Report\n\n",
    "Generated on: ", Sys.Date(), "\n\n",
    "## Summary of Prediction Results\n\n",
    knitr::kable(summary_metrics, format = "markdown"), "\n\n",
    insights
  )

  writeLines(report_content, con = file_path)
  cat("Deployment report saved to:", file_path, "\n")
}

# Example usage
# Assume `predictions` contains columns for actual and predicted values
pred_summary <- summarize_prediction_results(predictions, model_type = "classification")
key_insights <- document_key_insights(pred_summary, additional_notes = "Model performed well on class A but struggled with class B.")
save_deployment_report(pred_summary, key_insights, file_path = "reports/deployment_report.md")

# Explanation:
# - `summarize_prediction_results`: Summarizes key metrics based on the model type. For classification models, metrics like accuracy, precision, and ROC AUC are calculated; for regression models, metrics like RMSE and MAE are provided.
# - `document_key_insights`: Generates formatted insights, combining summary metrics and any additional notes for observations.
# - `save_deployment_report`: Assembles the report content with the date, summary of results, and insights, saving it as a markdown file.





