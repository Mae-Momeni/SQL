
# 1. Load Required Libraries ----------------------------------------------
1. **Load Required Libraries**: Loads essential libraries (`tidyverse` for data manipulation, `yardstick` for model performance metrics, and `lubridate` for time-based analysis).

# 2. Load Production Model and Data ---------------------------------------
**Load Production Model and Data**:
   - **Load the Model**: The production model is loaded from an RDS file.
   - **Load and Preprocess New Data**: The most recent production data is imported and processed with the same preprocessing recipe as the training data, ensuring consistency.
   - **Define Monitoring Period**: Specifies a period for monitoring, allowing regular analysis within a defined time range. 


# 3. Set Up Model Monitoring Metrics --------------------------------------
1. **Define Metrics**:
   - `calculate_performance_metrics`: A flexible function for calculating model performance metrics, adapting to either classification or regression models.
   
2. **Define Drift Detection Metrics**:
   - `calculate_psi`: This function calculates the Population Stability Index (PSI), which is used to detect distributional drift in features by comparing proportions between old and new data distributions.

# 4. Generate Predictions on New Data -------------------------------------
1. **Predict and Evaluate**:
   - `generate_predictions_and_metrics`: This function generates predictions on the new data and computes relevant metrics for monitoring.
   - `log_metrics`: Appends the calculated metrics with a timestamp and model version to a log file, aiding in trend analysis over time.

2. **Check for Drift**:
   - `detect_drift`: Checks if there’s a significant deviation in performance (e.g., accuracy) between recent and historical predictions, alerting if drift is detected.

# 5. Log and Store Monitoring Metrics -------------------------------------
1. **Save Metrics for Analysis**:
   - `log_monitoring_metrics`: This function saves the current performance metrics with a timestamp to a CSV file, maintaining a historical record for long-term monitoring.

2. **Automate Alerts**:
   - `check_alert_thresholds`: This function checks if the latest metrics meet predefined thresholds. If any metric (e.g., accuracy, drift) falls outside acceptable limits, it issues an alert to prompt attention.

# 6. Generate Monitoring Report -------------------------------------------
1. **Summarize Performance and Drift**:
   - The function aggregates daily performance and drift metrics, providing an overview of trends over the monitoring period.
   -  - Performance: Average accuracy has been r mean(metrics$accuracy, na.rm = TRUE), with a maximum observed drift of r max(metrics$drift, na.rm = TRUE).

2. **Document Observations and Actions**:
   - An actions log allows tracking specific responses to performance changes, such as tuning or retraining, with dates and observations.
   - - Actions: Actions logged for significant drift include retraining and parameter adjustments. Refer to actions log for detailed actions by date. "

3. **Save or Export Report**:
   - The report is generated using a temporary R Markdown template, then saved as an HTML document in the specified path, making it accessible for business and technical stakeholders. 

# 7. Plan for Model Retraining and Updates --------------------------------
1. **Define Retraining Triggers**:
   - `check_retraining_criteria` checks recent metrics against defined thresholds for accuracy and drift. If these thresholds are breached, it signals that retraining is required.

2. **Retrain Model**:
   - When retraining criteria are met, the code sources `model_training_and_tuning.R`, where the retraining process takes place. After retraining, the new model is saved for future use.

3. **Update Production Model**:
   - After deploying the retrained model, the monitoring metrics are reset, ensuring that the new cycle begins with the updated model.


