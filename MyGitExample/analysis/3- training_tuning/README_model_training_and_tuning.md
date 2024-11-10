
# Tip: Complementary, model-specific feature engineering
**Recommended Approach of FE**
Typically, general feature engineering (e.g., encoding, basic transformations) is best kept in the data preparation file, while model-specific feature engineering can be flexible and added in model_training_and_tuning.R using recipes, allowing easy adjustments during model development.

This way, data_evaluation_preparation.R provides a standardized, cleaned dataset that is ready for model-specific feature tweaking in model_training_and_tuning.R.




# 1. Initial Setup --------------------------------------------------------
This code loads essential libraries (tidymodels for modeling, yardstick for evaluation metrics) and sets a seed to ensure reproducibility across random processes. 


# 2. Data Loading and Preparation ---------------------------------------------

- **Load Prepared Data**: Load the processed dataset from `data_evaluation_preparation.R`.
- **Data Splitting**: Use `initial_split` to create an 80/20 train-test split, ensuring stratification by target variable for balanced distribution.
- **Create Datasets**: Extract training and testing datasets using `training()` and `testing()`. 

# 3. Define a Preprocessing Recipe --------------------------------------------

1. **Identify Target and Predictors**: The target variable (`target_variable`) is specified separately from predictors (`predictor_variables`), making it flexible to adjust target and predictor selections as needed.

2. **Preprocessing Steps**:
   - **Impute Missing Values**: `step_impute_mean` and `step_impute_mode` handle missing values for numeric and categorical variables, respectively.
   - **Encode Categorical Variables**: One-hot encoding is applied to all nominal predictors, transforming them into binary columns using `step_dummy`.
   - **Scale/Normalize Numeric Variables**: `step_normalize` standardizes numerical features, setting them to a mean of 0 and a standard deviation of 1.
   - **Feature Engineering**: Polynomial interactions (`step_interact`) and log transformations (`step_log`) are included as optional model-specific transformations. Box-Cox transformation (`step_BoxCox`) is added to normalize numeric data if required.

3. **Save Recipe Structure**: Finally, `saveRDS` saves the prepped recipe structure, allowing it to be reused in model workflows.


# 4. Specify a Model Type -----------------------------------------------------

1. **Choose a Model Type**: 
   - This step selects a suitable model type based on the problem (classification or regression). Here, **XGBoost** and **Generalized Additive Models (GAM)** are chosen, providing a mix of tree-based and smooth-curve approaches.
   
2. **Define Model Engine and Mode**:
   - Each model specifies a computational engine and mode to ensure compatibility with `tidymodels`. For example, **XGBoost** uses the `"xgboost"` engine, and **GAM** uses `"mgcv"` for smooth functions. The mode (`classification` or `regression`) is set based on the target's data type.

3. **Set Hyperparameters**:
   - Initial hyperparameters, such as the number of trees and tree depth for XGBoost, are defined here to provide a starting point. These can be adjusted later during tuning. 
   - For GAM, options like `select_features` and `degree` are set to control the smoothness and flexibility of the model.
   
   
# 5. Build a Workflow -----------------------------------------------------

1. **Function Definition**:
   - The `create_and_inspect_workflow()` function takes a recipe and a model specification as inputs, combines them into a workflow, and prints the workflow to verify its structure. This helps ensure the workflow integrates the correct preprocessing and model components.

2. **Workflow Creation**:
   - The workflows for each model (XGBoost Classification, XGBoost Regression, GAM Classification, GAM Regression) are created using `create_and_inspect_workflow()`, each with the specified recipe and model.

3. **Review Workflow Structure**:
   - The `print()` function within `create_and_inspect_workflow()` outputs the workflow structure, allowing a review to confirm that each workflow correctly includes the desired recipe and model specifications.

# 6. Define Resampling Strategy for Cross-Validation ----------------------

1. **Function Definition**:
   - The `define_cv_strategy()` function sets up cross-validation with a specified number of folds and optional stratification on the target variable. Stratification ensures each fold has a similar distribution of the target, which is particularly useful for imbalanced classification problems.

2. **Applying Resampling Strategy**:
   - The code sets up two cross-validation strategies:
     - `cv_strategy_class` for classification tasks, with stratification on the target.
     - `cv_strategy_regr` for regression tasks, where stratification is not required.
   
3. **Customization Options**:
   - This setup allows flexibility to adjust the number of folds or stratification based on the target variable, making the resampling strategy adaptable for different types of models and datasets.


# 7. Hyperparameter Tuning ------------------------------------------------

1. **Define Tuning Grid**:
   - `define_tuning_grid()` specifies hyperparameters for tuning based on the model type. For XGBoost, it uses a random grid search, while for GAM it uses a regular grid.

2. **Run Hyperparameter Tuning**:
   - `run_tuning()` performs tuning for each workflow and cross-validation strategy, evaluating model performance on metrics such as ROC AUC, accuracy, recall for classification, and RMSE, R-squared for regression.

3. **Evaluate Tuning Results**:
   - `evaluate_tuning_results()` selects the best model based on a specific metric and provides a visualization of performance across hyperparameter values, helping identify optimal configurations visually.


# 8. Model Selection ------------------------------------------------------

1. **Select Best Model**:
   - The `finalize_best_model()` function identifies the best hyperparameter configuration from tuning results by selecting the highest performance metric (e.g., "roc_auc" for classification and "rmse" for regression).

2. **Finalize Model Workflow**:
   - Using `finalize_workflow()`, each model's workflow is updated with the selected best hyperparameters, producing finalized workflows that can be directly used for training on the full dataset.


# 9. Train the Final Model on the Full Training Set -----------------------

1. **Fit Final Model Workflow**:
   - The `fit_final_model()` function takes the finalized workflow (with the best hyperparameters) and trains it on the entire training set to produce a fully trained model.

2. **Save Final Model for Future Use**:
   - Each fitted model is saved as an `.rds` file using `save_trained_model()` to ensure reproducibility. This makes the model available for deployment, future evaluations, or additional analysis.


# 10. Evaluate Model on the Test Set --------------------------------------

1. **Generate Predictions on Test Set**:
   - The `evaluate_model()` function generates predictions on the test set for each model. It also combines predictions with actual target values from the test set.

2. **Calculate Evaluation Metrics**:
   - For classification models, the function computes common classification metrics, including accuracy, precision, recall, F1, and ROC AUC.
   - For regression models, the function calculates metrics like RMSE, MAE, and R-squared.

3. **Analyze Confusion Matrix (if applicable)**:
   - For classification models, the confusion matrix is generated to review class-level performance.

# 11. Save Model and Results ----------------------------------------------

1. **Save Final Model Object**:
   - Each trained model is saved as an RDS file. This ensures that the models are stored in a way that allows for easy reloading and use in future sessions without needing to retrain.

2. **Save Evaluation Metrics**:
   - The evaluation metrics for each model are saved as CSV files, providing a record of model performance on the test set. This can be useful for reporting, comparison, or analysis.

3. **Save Tuning Results**:
   - If hyperparameter tuning was conducted, the tuning results are saved as CSV files. This keeps a record of the parameter grid search results and allows for review and future tuning adjustments.

# 12. Generate a Model Report ---------------------------------------------

1. **Summarize Model Performance**:
   - The `summarize_performance` function consolidates key metrics across models for both training and test sets. This overview provides quick insights into model accuracy, ROC AUC, RMSE, and R-squared, highlighting the models' overall performance.

2. **Variable Importance Analysis**:
   - The `plot_variable_importance` function generates importance rankings for models that allow this analysis (e.g., tree-based models). Feature importance helps identify which predictors are most influential, supporting interpretability and potential model refinement.

3. **Document Key Insights and Observations**:
   - This function creates a structured file for insights based on model performance. Observations might include standout models, issues with certain variables, or recommendations for future model improvements. This documentation is essential for communicating findings and supporting iterative model development. 





