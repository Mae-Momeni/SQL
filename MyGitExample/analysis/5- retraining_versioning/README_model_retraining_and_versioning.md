

# 1. Load Required Libraries ----------------------------------------------
**Load Required Libraries**: Essential libraries like `tidyverse` for data manipulation, `tidymodels` for modeling, and `rsample` for resampling are imported. The inclusion of libraries in a single section ensures that all necessary packages are loaded before starting.

# 2. Load Model, Data, and Recipes ----------------------------------------
**Load Model, Data, and Recipes**:
   - The function `load_model_data_recipe()` loads the production model, latest training data, and preprocessing recipe in a structured way.
   - These components are then stored in a `list` and accessed individually (`prod_model`, `training_data`, and `prod_recipe`) for clarity.

# 3. Define Retraining Criteria -------------------------------------------
1. **Set Retraining Triggers**:
   - `check_retraining_needed()` evaluates if retraining is necessary based on two conditions: model performance falling below a defined threshold or the lapse of a specific time interval since the last retraining.
   - The function returns `TRUE` if either trigger is met.

2. **Version Control Setup**:
   - `generate_version_tag()` generates a version tag based on the current date and model performance, making it easier to track model iterations.
   - This version tag can be used within a versioning system to keep an organized record of model retraining events.

# 4. Retrain the Model ----------------------------------------------------
1. **Use Cross-Validation for Retraining**:
   - `retrain_model()` handles cross-validation and (optionally) hyperparameter tuning. The function uses a Latin hypercube grid to optimize key hyperparameters if tuning is enabled, and it applies the specified recipe for consistent preprocessing.

2. **Tune Hyperparameters (if necessary)**:
   - Hyperparameter tuning, controlled by the `tune_params` argument, enables flexible model optimization for updated data. This process can be skipped for efficiency if tuning is not required.

3. **Evaluate Retrained Model**:
   - `evaluate_model_performance()` summarizes performance metrics, providing a direct comparison between the retrained model and the production model to assess improvement.

# 5. Compare and Validate Model Versions ----------------------------------
1. **Performance Comparison**:
   - `compare_model_performance()` combines metrics for the retrained and production models, computing the improvement for each metric. This gives a clear view of whether the new model outperforms the existing one.

2. **Select Model for Deployment**:
   - `select_model_for_deployment()` assesses whether the retrained model meets performance thresholds for each metric. If all conditions are met, it suggests deploying the new model; otherwise, it retains the production model. This allows controlled, criteria-based decision-making for model updates.

# 6. Version and Save the Model -------------------------------------------
1. **Update Model Version**:
   - `generate_version_id()` creates a versioned model identifier based on a timestamp, allowing each model to have a unique and identifiable version.

2. **Save Model to Versioned Directory**:
   - `save_versioned_model()` saves the model as an `.rds` file in a structured directory for versioning. It ensures the model is stored in a reproducible format with a clear version identifier.

3. **Log Model Metadata**:
   - Metadata, including metrics, version ID, and timestamp, is saved as a CSV file. This provides a detailed record of model versions, making it easy to audit or retrieve past versions if necessary.

# 7. Deploy the Retrained Model -------------------------------------------
1. **Deploy New Model to Production**:
   - The `deploy_model_to_production()` function handles model deployment, saving the retrained model to a production location (`production_model.rds`) if it’s selected for deployment.

2. **Update Monitoring Process**:
   - This function also updates or creates a monitoring log (`monitor_log.csv`) with details about the model, including deployment time, version, and key metrics. This ensures ongoing monitoring and an audit trail for tracking model performance.

# 8. Archive and Document Model Versions ----------------------------------
1. **Archive Previous Model Versions**:
   - The `archive_model()` function copies the current production model to an archive directory, creating a backup version with a timestamp. This step ensures that previous models are preserved for rollback or reproducibility.

2. **Document Retraining Process**:
   - The `document_retraining()` function writes key retraining details to a markdown file, including retraining criteria, any modifications, and performance comparisons. This documentation provides a clear reference for why the model was retrained and how it performed relative to the previous version.
