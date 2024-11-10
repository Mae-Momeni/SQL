# Functions related to model fitting, evaluation, and prediction.
# fit_model, evaluate_model, predict_model, score with model
# functions with Roxygen2-style documentation


# R/modeling_fit_evaluate.R

# Function for training a model
train_model <- function(data, formula, method = "xgboost") {
  model <- caret::train(
    formula, data = data,
    method = method
  )
  return(model)
}

# Function for hyperparameter tuning
tune_model <- function(data, formula, method = "xgboost", tune_grid) {
  model <- caret::train(
    formula, data = data,
    method = method,
    tuneGrid = tune_grid
  )
  return(model)
}

# Function for scoring
score_model <- function(model, new_data) {
  predictions <- predict(model, newdata = new_data)
  return(predictions)
}

# Function for evaluating model performance
evaluate_model <- function(predictions, actuals) {
  results <- caret::confusionMatrix(predictions, actuals)
  return(results)
}


