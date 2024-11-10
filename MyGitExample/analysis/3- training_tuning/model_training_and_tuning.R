
# instruction:
# transform the code into a more advanced style, leveraging pipes (%>%), mutate, summarize,
# and other tidyverse techniques. Make sure the code is modular and efficient. Take best R coding
# practices for data science and ML projects to make the code readable, modular, and scalable.
# Write function when tasks are repetitive, complex, or require flexibility, improving readability, reusability, and consistency. Avoid functions for one-off code, simple transformations, or linear workflows, as they may add unnecessary complexity.
# if writing function, use Roxygen2-style comments to make the functions readable and modular.
# provide a concise explanation of each section part after the code


# 1. Initial Setup ------------------------------------------------------------

# Load necessary libraries
library(tidymodels)  # Core package for modeling
library(yardstick)   # For model evaluation metrics
library(dplyr)       # For data manipulation
library(ggplot2)     # For visualization
library(purrr)       # For functional programming where needed

# Set Seed for Reproducibility
set.seed(123)  # Replace 123 with any preferred seed for reproducibility



# 2. Data Loading and Preparation ---------------------------------------------

# Load Prepared Data
data <- readRDS("data/processed/prebake_dataset.rds")  # Load the pre-processed dataset

# Data Splitting: 80/20 split for training and testing
# Using initial_split from rsample to split data into training and testing sets
set_split <- initial_split(data, prop = 0.8, strata = target_variable)  # Replace `target_variable` with actual target column name

# Create training and testing datasets
train_data <- training(set_split)
test_data <- testing(set_split)


# 3. Define a Preprocessing Recipe --------------------------------------------

# Load necessary libraries
library(tidyverse)
library(tidymodels)
library(recipes)

# Define preprocessing steps for model training and tuning

# Specify the target and predictors (customizable)
target_variable <- "your_target_variable" # Replace with actual target variable name
predictor_variables <- setdiff(names(data), target_variable) # All except target

# Start the recipe
recipe_spec <- recipe(!!sym(target_variable) ~ ., data = data) %>%
  # 1. Impute Missing Values (if needed)
  step_impute_mean(all_numeric_predictors()) %>% # For numeric columns
  step_impute_mode(all_nominal_predictors()) %>% # For categorical columns

  # 2. Encode Categorical Variables
  step_dummy(all_nominal_predictors(), one_hot = TRUE) %>% # One-hot encoding

  # 3. Scale/Normalize Numeric Variables
  step_normalize(all_numeric_predictors()) %>% # Standardization to mean = 0, sd = 1

  # 4. Feature Engineering (optional, model-specific)
  step_interact(terms = ~ all_numeric_predictors()^2) %>% # Polynomial terms for all numeric pairs
  step_log(all_numeric_predictors(), -all_outcomes(), offset = 1) %>% # Log transformation, if applicable
  step_BoxCox(all_numeric_predictors()) # Box-Cox for normality, if needed

# Prepare the recipe with the data
prepped_recipe <- recipe_spec %>% prep(training = data)

# Save the recipe structure for reuse
saveRDS(prepped_recipe, "path/to/recipe_structure.rds") # Replace path with desired location

cat("Recipe defined and saved successfully.")



# 4. Specify a Model Type -------------------------------------------------

# Load necessary libraries
library(tidyverse)
library(tidymodels)
library(xgboost)
library(mgcv)  # For Generalized Additive Models (GAM)

# 1. Define preprocessing recipe
# ----------------------------------------------------------------------------

#' Create a Preprocessing Recipe
#'
#' @param data A data frame containing predictors and target variable.
#' @param target_var Name of the target variable as a string.
#'
#' @return A recipe object with preprocessing steps applied.
#' @export
create_recipe <- function(data, target_var) {
  recipe(as.formula(paste(target_var, "~ .")), data = data) %>%
    step_impute_mean(all_numeric(), -all_outcomes()) %>%         # Impute missing values for numeric
    step_impute_mode(all_nominal(), -all_outcomes()) %>%         # Impute missing values for categorical
    step_dummy(all_nominal(), -all_outcomes()) %>%               # Encode categorical variables
    step_normalize(all_numeric(), -all_outcomes()) %>%           # Scale numeric variables
    step_poly(all_numeric(), -all_outcomes(), degree = 2) %>%    # Polynomial features (optional)
    step_log(all_numeric(), -all_outcomes(), offset = 1)         # Log transformation for skewed features
}

# Apply recipe
data_recipe <- create_recipe(data = your_data, target_var = "target")

# Explanation: This section defines a recipe for preprocessing. The steps include imputing missing values,
# encoding categorical variables, scaling numeric variables, and optionally adding polynomial/log transformations.


# 2. Model Specification for Four Models (XGBoost and GAM for classification and regression)
# ----------------------------------------------------------------------------

# XGBoost Model Specifications
xgb_class_spec <- boost_tree(trees = 1000, tree_depth = 6) %>%
  set_engine("xgboost") %>%
  set_mode("classification")

xgb_regr_spec <- boost_tree(trees = 1000, tree_depth = 6) %>%
  set_engine("xgboost") %>%
  set_mode("regression")

# GAM Model Specifications
gam_class_spec <- gen_additive_mod(select_features = TRUE, degree = 2) %>%
  set_engine("mgcv") %>%
  set_mode("classification")

gam_regr_spec <- gen_additive_mod(select_features = TRUE, degree = 2) %>%
  set_engine("mgcv") %>%
  set_mode("regression")

# Explanation: This section sets up model specifications for the four models. Each model specifies the
# appropriate mode (classification or regression) and engine (xgboost or mgcv for GAM). Hyperparameters are
# set for initial values and can be tuned later.


# 3. Create Workflows for Each Model
# ----------------------------------------------------------------------------

#' Create Workflow with Recipe and Model
#'
#' @param model_spec A model specification object (e.g., xgboost, gam).
#' @param recipe A preprocessing recipe object.
#'
#' @return A workflow object combining the recipe and model.
#' @export
create_workflow <- function(model_spec, recipe) {
  workflow() %>%
    add_model(model_spec) %>%
    add_recipe(recipe)
}

# Combine recipe and model for each workflow
workflow_xgb_class <- create_workflow(xgb_class_spec, data_recipe)
workflow_xgb_regr <- create_workflow(xgb_regr_spec, data_recipe)
workflow_gam_class <- create_workflow(gam_class_spec, data_recipe)
workflow_gam_regr <- create_workflow(gam_regr_spec, data_recipe)

# Explanation: This section creates workflow objects for each model, combining the preprocessing recipe and
# model specification into a single object.


# 4. Set Up Tuning Parameters (if needed) for XGBoost and GAM Models
# ----------------------------------------------------------------------------

# Define parameter grids for tuning
xgb_param_grid <- grid_latin_hypercube(
  trees(),
  tree_depth(),
  learn_rate(),
  loss_reduction(),
  sample_size = sample_prop(),
  finalize(mtry(), select(data, -target_var)),
  size = 20
)

gam_param_grid <- grid_regular(
  select_features(),
  degree(),
  size = 10
)

# Explanation: This section defines tuning grids for XGBoost and GAM models. The grids allow tuning for
# important hyperparameters, like the number of trees and tree depth for XGBoost, and feature selection and
# degree for GAM.


# 5. Train Models Using Cross-Validation
# ----------------------------------------------------------------------------

# Set up cross-validation
set.seed(123)
cv_folds <- vfold_cv(your_data, v = 5)

#' Train Model with Cross-Validation
#'
#' @param workflow A workflow object with recipe and model.
#' @param resamples A resample object for cross-validation.
#' @param grid Optional parameter grid for tuning.
#'
#' @return A tuned or trained workflow.
#' @export
train_with_cv <- function(workflow, resamples, grid = NULL) {
  if (!is.null(grid)) {
    tune_grid(workflow, resamples = resamples, grid = grid)
  } else {
    fit_resamples(workflow, resamples = resamples)
  }
}

# Train each model with CV and tuning where applicable
results_xgb_class <- train_with_cv(workflow_xgb_class, cv_folds, xgb_param_grid)
results_xgb_regr <- train_with_cv(workflow_xgb_regr, cv_folds, xgb_param_grid)
results_gam_class <- train_with_cv(workflow_gam_class, cv_folds, gam_param_grid)
results_gam_regr <- train_with_cv(workflow_gam_regr, cv_folds, gam_param_grid)

# Explanation: This section sets up cross-validation and applies it to each model. Each model is trained using
# a 5-fold CV, with tuning grids applied where relevant.


# 6. Select Best Models and Finalize Workflows
# ----------------------------------------------------------------------------

#' Select Best Model from Tuning Results
#'
#' @param tuning_results A tuning results object.
#'
#' @return A workflow object with best parameters.
#' @export
finalize_model <- function(tuning_results) {
  best_params <- select_best(tuning_results, "accuracy")
  finalize_workflow(tuning_results, best_params)
}

# Apply best parameter selection
final_workflow_xgb_class <- finalize_model(results_xgb_class)
final_workflow_xgb_regr <- finalize_model(results_xgb_regr)
final_workflow_gam_class <- finalize_model(results_gam_class)
final_workflow_gam_regr <- finalize_model(results_gam_regr)

# Explanation: Here, the code selects the best parameters from the tuning results for each model, producing
# final workflows ready for training or evaluation.


# 7. Fit Final Models on Full Training Data
# ----------------------------------------------------------------------------

# Fit each finalized model on full data
fit_xgb_class <- final_workflow_xgb_class %>% fit(your_data)
fit_xgb_regr <- final_workflow_xgb_regr %>% fit(your_data)
fit_gam_class <- final_workflow_gam_class %>% fit(your_data)
fit_gam_regr <- final_workflow_gam_regr %>% fit(your_data)

# Explanation: This section fits the final workflows on the entire training dataset, generating fully trained models.


# 8. Save Models
# ----------------------------------------------------------------------------

#' Save Model Object
#'
#' @param model A trained model object.
#' @param path File path for saving the model.
#'
#' @return None. Saves the model to the specified path.
#' @export
save_model <- function(model, path) {
  saveRDS(model, path)
  cat("Model saved to:", path, "\n")
}

# Save each model to disk
save_model(fit_xgb_class, "models/xgb_class_model.rds")
save_model(fit_xgb_regr, "models/xgb_regr_model.rds")
save_model(fit_gam_class, "models/gam_class_model.rds")
save_model(fit_gam_regr, "models/gam_regr_model.rds")

# Explanation: This final section saves each trained model as an RDS file for later use.


# 5. Build a Workflow -----------------------------------------------------

# Load necessary libraries
library(tidymodels)
library(tidyverse)

# Assuming the preprocessing recipe `data_recipe` and model specifications from Section 4 are ready

# Function to create and inspect workflows
# ----------------------------------------------------------------------------
#' Create and Inspect Model Workflow
#'
#' @param recipe A preprocessed recipe object.
#' @param model_spec A model specification object (e.g., XGBoost, GAM).
#'
#' @return A workflow object that combines the recipe and model specification.
#' @export
create_and_inspect_workflow <- function(recipe, model_spec) {
  workflow() %>%
    add_recipe(recipe) %>%
    add_model(model_spec) %>%
    print()
}

# Define workflows for each model by combining the recipe and respective model specifications
# ----------------------------------------------------------------------------

# XGBoost Classification Workflow
workflow_xgb_class <- create_and_inspect_workflow(data_recipe, xgb_class_spec)

# XGBoost Regression Workflow
workflow_xgb_regr <- create_and_inspect_workflow(data_recipe, xgb_regr_spec)

# GAM Classification Workflow
workflow_gam_class <- create_and_inspect_workflow(data_recipe, gam_class_spec)

# GAM Regression Workflow
workflow_gam_regr <- create_and_inspect_workflow(data_recipe, gam_regr_spec)

# Explanation:
# This section combines the preprocessing recipe (`data_recipe`) with each specified model type.
# We use `create_and_inspect_workflow()` to:
#   1. Create the workflow by adding the recipe and model to the workflow object.
#   2. Print the workflow to verify its structure, ensuring it includes the correct recipe and model.
# This setup is modular, reusable, and allows for easy inspection of each model’s workflow structure.



# 6. Define Resampling Strategy for Cross-Validation ----------------------
# Load necessary libraries
library(tidymodels)
library(tidyverse)

# Function to Define Cross-Validation Resampling Strategy
#' Define Cross-Validation Resampling Strategy
#'
#' @param data A data frame to perform resampling on.
#' @param target_var Name of the target variable as a string, for stratified resampling.
#' @param v_folds Number of folds for cross-validation (default is 5).
#' @param stratify Logical, whether to stratify based on the target variable (default is TRUE).
#'
#' @return A resampling object based on the specified resampling strategy.
#' @export
define_cv_strategy <- function(data, target_var, v_folds = 5, stratify = TRUE) {
  if (stratify) {
    vfold_cv(data, v = v_folds, strata = target_var)
  } else {
    vfold_cv(data, v = v_folds)
  }
}

# Define Resampling Strategy with Cross-Validation and Stratification for Each Model

# Set up cross-validation strategy for classification models with stratification on target
cv_strategy_class <- define_cv_strategy(data = your_data, target_var = "target_variable", v_folds = 5, stratify = TRUE)

# Set up cross-validation strategy for regression models (stratification not needed)
cv_strategy_regr <- define_cv_strategy(data = your_data, target_var = "target_variable", v_folds = 5, stratify = FALSE)

# Explanation:
# This section defines the cross-validation strategy using a flexible function. `define_cv_strategy()` sets up
# 5-fold cross-validation, with optional stratification based on the target variable.
# Stratification helps preserve the target distribution within folds, important for imbalanced classification.
# Separate resampling strategies are created for classification and regression tasks.


# 7. Hyperparameter Tuning ------------------------------------------------

# Load necessary libraries
library(tidymodels)
library(tidyverse)

# Function to Define Tuning Parameters and Strategy
# ----------------------------------------------------------------------------
#' Define Tuning Grid for Model
#'
#' @param model_type Character string specifying the model type ("xgboost" or "gam").
#' @param tuning_strategy Character, tuning method ("grid", "random", "bayesian").
#' @param grid_size Numeric, number of combinations in grid for random tuning.
#'
#' @return A tuning grid object based on specified model type and strategy.
#' @export
define_tuning_grid <- function(model_type, tuning_strategy = "grid", grid_size = 20) {
  if (model_type == "xgboost") {
    # XGBoost tuning grid
    param_grid <- dials::grid_latin_hypercube(
      trees(),
      tree_depth(),
      learn_rate(),
      loss_reduction(),
      sample_size = sample_prop(),
      finalize(mtry(), select(your_data, -target_variable)),
      size = grid_size
    )
  } else if (model_type == "gam") {
    # GAM tuning grid
    param_grid <- dials::grid_regular(
      select_features(),
      degree(),
      size = grid_size
    )
  } else {
    stop("Unsupported model type for tuning.")
  }

  return(param_grid)
}

# Generate Tuning Grids
xgb_tuning_grid <- define_tuning_grid("xgboost", "random", grid_size = 20)
gam_tuning_grid <- define_tuning_grid("gam", "grid", grid_size = 10)

# Explanation:
# This function, `define_tuning_grid()`, creates tuning grids for hyperparameters based on model type
# and chosen tuning strategy. `xgboost` uses a random grid with 20 combinations, while `gam` uses a regular grid.


# Perform Hyperparameter Tuning with Cross-Validation
# ----------------------------------------------------------------------------

#' Run Hyperparameter Tuning
#'
#' @param workflow A workflow object with recipe and model.
#' @param resamples A resample object (e.g., cross-validation folds).
#' @param grid A grid object containing hyperparameter values for tuning.
#'
#' @return Tuning results with performance metrics.
#' @export
run_tuning <- function(workflow, resamples, grid) {
  tune_grid(
    workflow,
    resamples = resamples,
    grid = grid,
    metrics = metric_set(roc_auc, accuracy, recall, rmse, rsq)
  )
}

# Run tuning for each model type
tuned_xgb_class <- run_tuning(workflow_xgb_class, cv_strategy_class, xgb_tuning_grid)
tuned_xgb_regr <- run_tuning(workflow_xgb_regr, cv_strategy_regr, xgb_tuning_grid)
tuned_gam_class <- run_tuning(workflow_gam_class, cv_strategy_class, gam_tuning_grid)
tuned_gam_regr <- run_tuning(workflow_gam_regr, cv_strategy_regr, gam_tuning_grid)

# Explanation:
# This section sets up tuning using `tune_grid()` for each model workflow. It evaluates performance across
# metrics such as ROC AUC, accuracy, recall for classification models, and RMSE, R-squared for regression.


# Evaluate Tuning Results
# ----------------------------------------------------------------------------

#' Evaluate and Visualize Tuning Results
#'
#' @param tuning_results Tuning results from `tune_grid`.
#' @param metric Metric to select best model, e.g., "roc_auc" for classification, "rmse" for regression.
#'
#' @return A plot showing performance metrics across tuning parameters.
#' @export
evaluate_tuning_results <- function(tuning_results, metric) {
  best_results <- select_best(tuning_results, metric = metric)

  # Visualization of tuning results
  autoplot(tuning_results) +
    labs(title = paste("Tuning Results - Best", metric, ":", round(best_results[[metric]], 4))) +
    theme_minimal()
}

# Visualize results for each tuned model
plot_xgb_class <- evaluate_tuning_results(tuned_xgb_class, "roc_auc")
plot_xgb_regr <- evaluate_tuning_results(tuned_xgb_regr, "rmse")
plot_gam_class <- evaluate_tuning_results(tuned_gam_class, "roc_auc")
plot_gam_regr <- evaluate_tuning_results(tuned_gam_regr, "rmse")

# Explanation:
# The `evaluate_tuning_results()` function selects the best model based on the specified metric,
# and visualizes the tuning process, showing metric trends across hyperparameter settings.



# 8. Model Selection ------------------------------------------------------

# Load necessary libraries
library(tidymodels)

# Function to Select and Finalize Best Model
# ----------------------------------------------------------------------------
#' Select Best Model from Tuning Results and Finalize Workflow
#'
#' @param tuning_results A tuning results object.
#' @param metric Character, the performance metric to select the best model (e.g., "roc_auc" or "rmse").
#'
#' @return A finalized workflow with the best hyperparameters.
#' @export
finalize_best_model <- function(tuning_results, metric) {
  best_params <- tuning_results %>%
    select_best(metric)           # Select best hyperparameters based on the chosen metric

  finalize_workflow(tuning_results %>% workflow(), best_params)
}

# Finalize each model with best parameters
final_workflow_xgb_class <- finalize_best_model(tuned_xgb_class, "roc_auc")
final_workflow_xgb_regr <- finalize_best_model(tuned_xgb_regr, "rmse")
final_workflow_gam_class <- finalize_best_model(tuned_gam_class, "roc_auc")
final_workflow_gam_regr <- finalize_best_model(tuned_gam_regr, "rmse")

# Explanation:
# `finalize_best_model()` takes tuning results and identifies the best hyperparameters based on the specified
# metric. It then updates the model's workflow with these parameters, producing a finalized model ready for training.



# 9. Train the Final Model on the Full Training Set -----------------------

# Load necessary libraries
library(tidymodels)

# Function to Fit Final Model on Full Training Set
# ----------------------------------------------------------------------------
#' Fit Final Model on the Full Training Set
#'
#' @param workflow A finalized workflow with best hyperparameters.
#' @param data A data frame containing the full training dataset.
#'
#' @return A fitted workflow object with the trained model.
#' @export
fit_final_model <- function(workflow, data) {
  workflow %>% fit(data = data)
}

# Fit each final model on the full training set
final_fit_xgb_class <- fit_final_model(final_workflow_xgb_class, your_training_data)
final_fit_xgb_regr <- fit_final_model(final_workflow_xgb_regr, your_training_data)
final_fit_gam_class <- fit_final_model(final_workflow_gam_class, your_training_data)
final_fit_gam_regr <- fit_final_model(final_workflow_gam_regr, your_training_data)

# Function to Save Trained Model
# ----------------------------------------------------------------------------
#' Save Trained Model to Disk
#'
#' @param model A fitted workflow object containing the trained model.
#' @param path File path to save the trained model.
#'
#' @return None. Saves the model to the specified path.
#' @export
save_trained_model <- function(model, path) {
  saveRDS(model, path)
  cat("Model saved to:", path, "\n")
}

# Define file paths for saving each model
model_paths <- list(
  xgb_class = "models/final_xgb_class_model.rds",
  xgb_regr = "models/final_xgb_regr_model.rds",
  gam_class = "models/final_gam_class_model.rds",
  gam_regr = "models/final_gam_regr_model.rds"
)

# Save each fitted model
save_trained_model(final_fit_xgb_class, model_paths$xgb_class)
save_trained_model(final_fit_xgb_regr, model_paths$xgb_regr)
save_trained_model(final_fit_gam_class, model_paths$gam_class)
save_trained_model(final_fit_gam_regr, model_paths$gam_regr)

# Explanation:
# `fit_final_model()` trains the finalized workflow on the entire training dataset, ensuring each model has access to the
# complete data for training. The `save_trained_model()` function saves the fitted model to an RDS file for future use,
# preserving the trained state for reproducibility, deployment, or further evaluation.



# 10. Evaluate Model on the Test Set --------------------------------------
# Load necessary libraries
library(tidymodels)
library(yardstick)

# Function to Generate Predictions and Calculate Metrics
# ----------------------------------------------------------------------------
#' Evaluate Model on Test Set
#'
#' @param model A fitted model object.
#' @param test_data A data frame containing the test set.
#' @param target_var The name of the target variable in test data.
#' @param is_classification Logical, TRUE if the model is for classification, FALSE for regression.
#'
#' @return A list containing the predictions, metrics, and (if classification) confusion matrix.
#' @export
evaluate_model <- function(model, test_data, target_var, is_classification = TRUE) {

  # Generate predictions
  predictions <- model %>%
    predict(test_data) %>%
    bind_cols(test_data %>% select(all_of(target_var)))

  # Classification Evaluation
  if (is_classification) {
    metrics <- predictions %>%
      metrics(truth = !!sym(target_var), estimate = .pred_class) %>%
      bind_rows(
        predictions %>%
          roc_auc(truth = !!sym(target_var), .pred_class) %>%
          rename(.metric = "roc_auc")
      )

    confusion <- predictions %>%
      conf_mat(truth = !!sym(target_var), estimate = .pred_class)

    return(list(predictions = predictions, metrics = metrics, confusion_matrix = confusion))

    # Regression Evaluation
  } else {
    metrics <- predictions %>%
      metrics(truth = !!sym(target_var), estimate = .pred)

    return(list(predictions = predictions, metrics = metrics))
  }
}

# Define target variable and test set
target_variable <- "your_target_variable"  # Replace with your actual target variable
test_set <- your_test_data                 # Replace with your actual test set

# Evaluate each model on the test set
xgb_class_eval <- evaluate_model(final_fit_xgb_class, test_set, target_variable, is_classification = TRUE)
xgb_regr_eval <- evaluate_model(final_fit_xgb_regr, test_set, target_variable, is_classification = FALSE)
gam_class_eval <- evaluate_model(final_fit_gam_class, test_set, target_variable, is_classification = TRUE)
gam_regr_eval <- evaluate_model(final_fit_gam_regr, test_set, target_variable, is_classification = FALSE)

# Explanation:
# `evaluate_model()` takes a fitted model, the test set, and evaluates performance based on the model type.
# For classification models, it calculates metrics (accuracy, precision, recall, F1, ROC AUC) and provides a confusion matrix.
# For regression models, it calculates metrics like RMSE, MAE, and R-squared.
# Results are stored for each model, including predictions and metrics for detailed evaluation.



# 11. Save Model and Results ----------------------------------------------

# Load necessary libraries
library(tidyverse)

# Function to Save Model
# ----------------------------------------------------------------------------
#' Save Model Object
#'
#' @param model A trained model object.
#' @param filepath File path to save the model as an RDS file.
#'
#' @return None. Saves the model to the specified path.
#' @export
save_model <- function(model, filepath) {
  saveRDS(model, filepath)
  cat("Model saved to:", filepath, "\n")
}

# Function to Save Evaluation Metrics
# ----------------------------------------------------------------------------
#' Save Evaluation Metrics
#'
#' @param metrics A data frame or tibble containing evaluation metrics.
#' @param filepath File path to save metrics as a CSV file.
#'
#' @return None. Saves the metrics to the specified path.
#' @export
save_metrics <- function(metrics, filepath) {
  write_csv(metrics, filepath)
  cat("Metrics saved to:", filepath, "\n")
}

# Function to Save Tuning Results (if applicable)
# ----------------------------------------------------------------------------
#' Save Tuning Results
#'
#' @param tuning_results A tuning results object.
#' @param filepath File path to save tuning results as a CSV file.
#'
#' @return None. Saves the tuning results to the specified path.
#' @export
save_tuning_results <- function(tuning_results, filepath) {
  tuning_results %>%
    collect_metrics() %>%
    write_csv(filepath)
  cat("Tuning results saved to:", filepath, "\n")
}

# Define File Paths
model_paths <- list(
  xgb_class = "models/final_xgb_class_model.rds",
  xgb_regr = "models/final_xgb_regr_model.rds",
  gam_class = "models/final_gam_class_model.rds",
  gam_regr = "models/final_gam_regr_model.rds"
)

metrics_paths <- list(
  xgb_class = "results/xgb_class_metrics.csv",
  xgb_regr = "results/xgb_regr_metrics.csv",
  gam_class = "results/gam_class_metrics.csv",
  gam_regr = "results/gam_regr_metrics.csv"
)

tuning_paths <- list(
  xgb_class = "results/xgb_class_tuning.csv",
  xgb_regr = "results/xgb_regr_tuning.csv",
  gam_class = "results/gam_class_tuning.csv",
  gam_regr = "results/gam_regr_tuning.csv"
)

# Save Final Models
save_model(final_fit_xgb_class, model_paths$xgb_class)
save_model(final_fit_xgb_regr, model_paths$xgb_regr)
save_model(final_fit_gam_class, model_paths$gam_class)
save_model(final_fit_gam_regr, model_paths$gam_regr)

# Save Evaluation Metrics
save_metrics(xgb_class_eval$metrics, metrics_paths$xgb_class)
save_metrics(xgb_regr_eval$metrics, metrics_paths$xgb_regr)
save_metrics(gam_class_eval$metrics, metrics_paths$gam_class)
save_metrics(gam_regr_eval$metrics, metrics_paths$gam_regr)

# Save Tuning Results (if applicable)
save_tuning_results(results_xgb_class, tuning_paths$xgb_class)
save_tuning_results(results_xgb_regr, tuning_paths$xgb_regr)
save_tuning_results(results_gam_class, tuning_paths$gam_class)
save_tuning_results(results_gam_regr, tuning_paths$gam_regr)

# Explanation:
# This section provides functions to save models, metrics, and tuning results for future use.
# Each function saves the specified object to a defined file path, ensuring consistency and reusability.
# Final models are saved as RDS files, evaluation metrics as CSV files, and tuning results are stored if applicable.


# 12. Generate a Model Report ---------------------------------------------

# Load necessary libraries
library(tidyverse)
library(tidymodels)
library(vip)  # For variable importance plots (if applicable)

# Function to Summarize Model Performance
# ----------------------------------------------------------------------------
#' Summarize Model Performance
#'
#' @param metrics A data frame containing model evaluation metrics.
#'
#' @return None. Prints a summary of model performance.
#' @export
summarize_performance <- function(metrics) {
  cat("\nModel Performance Summary:\n")
  metrics %>%
    summarise(
      accuracy = mean(accuracy, na.rm = TRUE),
      roc_auc = mean(roc_auc, na.rm = TRUE),
      rmse = mean(rmse, na.rm = TRUE),
      rsq = mean(rsq, na.rm = TRUE)
    ) %>%
    print()
}

# Summarize performance for each model
summarize_performance(xgb_class_eval$metrics)
summarize_performance(xgb_regr_eval$metrics)
summarize_performance(gam_class_eval$metrics)
summarize_performance(gam_regr_eval$metrics)

# Explanation: This function takes model evaluation metrics and prints a summary, including accuracy,
# ROC AUC (for classification models), RMSE, and R-squared (for regression models).


# Function for Variable Importance Analysis
# ----------------------------------------------------------------------------
#' Plot Variable Importance (if applicable)
#'
#' @param model A trained model object (e.g., xgboost, random forest).
#'
#' @return A ggplot object displaying the variable importance plot.
#' @export
plot_variable_importance <- function(model) {
  if ("vip" %in% installed.packages()[, "Package"]) {
    vip::vip(model) +
      labs(title = "Variable Importance",
           subtitle = paste("Model:", class(model)[1])) +
      theme_minimal()
  } else {
    cat("The 'vip' package is required for variable importance plots.\n")
  }
}

# Generate variable importance plots for interpretable models
plot_variable_importance(final_fit_xgb_class)
plot_variable_importance(final_fit_xgb_regr)
plot_variable_importance(final_fit_gam_class)
plot_variable_importance(final_fit_gam_regr)

# Explanation: This function generates a variable importance plot for models that support this analysis.
# It uses the 'vip' package, which provides clear visualizations of feature importance.


# Function to Document Key Insights
# ----------------------------------------------------------------------------
#' Document Model Insights and Observations
#'
#' @param insights A character vector of key insights, observations, or recommendations.
#' @param filepath File path to save the insights as a text file.
#'
#' @return None. Saves insights to the specified path.
#' @export
document_insights <- function(insights, filepath) {
  writeLines(insights, filepath)
  cat("Insights saved to:", filepath, "\n")
}

# Define insights based on model performance
model_insights <- c(
  "1. XGBoost (Classification) achieved the highest accuracy and ROC AUC on the test set, suggesting it may generalize well.",
  "2. GAM (Regression) showed lower RMSE but higher variance, indicating potential overfitting.",
  "3. Key features identified in XGBoost models include predictor1, predictor2, and predictor3.",
  "4. Future improvements could explore additional regularization or tuning for the GAM models to improve stability.",
  "5. Class imbalance in the classification dataset may require SMOTE or other sampling methods for better performance."
)

# Save insights to a text file
document_insights(model_insights, "reports/model_insights.txt")

# Explanation: This function writes key observations, insights, and suggestions to a text file for
# documentation. The provided insights can be customized based on actual model results and interpretations.






