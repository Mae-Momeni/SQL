
### Data Evaluation Steps (to assess data quality, structure, and is --------

#### 1. Initial Data Overview -------------------------------------------------

1. **Data Structure**: Uses `glimpse(data)` to display column types and sample values, providing a concise overview of the data structure.
2. **Dimensions**: Checks the number of rows and columns, storing this information in `data_dimensions`.
3. **Column Names and Data Types**:
   - Lists each column and its data type.
   - Identifies the target variable if specified by marking it in the `is_target` column.
4. **Summary Statistics for Numeric Variables**: 
   - Computes `mean`, `median`, `standard deviation (sd)`, `min`, and `max` for each numeric variable.
   - Reshapes the output for better readability using `pivot_longer`.
5. **Frequency Counts for Categorical Variables**:
   - Creates frequency tables for each categorical variable.
   - Uses `map(~ table(.))` to apply `table()` to each categorical variable, storing the results in a tibble.


#### 2. Missing Data Analysis ----------------------------------------------

1. **Count Missing Values per Column**:
   - Uses `summarise(across(..., ~ sum(is.na(.))))` to count missing values for each column.
   - Calculates the percentage of missing values for each column and organizes results in `missing_summary`.

2. **Visualize Missing Data Patterns**:
   - **Heatmap of Missing Data**: Uses `naniar::vis_miss(data)` to visualize missing data across columns.
   - **Bar Plot of Missing Percentages**: Creates a bar plot to show the percentage of missing values per column, sorted from highest to lowest.

3. **Identify Combinations of Missing Values with UpSet Plot**:
   - Filters columns with any missing values.
   - Uses `UpSetR::upset()` to show combinations of missing values across multiple columns, providing insight into overlapping missing data patterns.

4. **Flag Rows with Excessive Missing Values**:
   - Defines `missing_threshold` as 50% of the total columns.
   - Flags rows with missing values exceeding this threshold and stores them in `high_missing_rows` for review.


#### 3. Outlier Detection --------------------------------------------------

1. **Boxplots for Outliers in Numeric Variables**:
   - Generates boxplots for each numeric variable to visually detect outliers, highlighted in red. Boxplots provide a quick overview of possible outliers based on values beyond the whiskers.

2. **Z-score Analysis for Outlier Detection**:
   - **Function `calculate_z_scores()`**: This function calculates Z-scores for each numeric variable, flagging values as outliers if they exceed the specified threshold (default = 3). It provides flexibility if you want to adjust the threshold in different contexts.
   - **Output**: Returns a tibble with variables, values, Z-scores, and outlier flags for outliers detected beyond the Z-score threshold.

3. **Impact Assessment of Outliers on Distributions**:
   - **Overlay Outliers on Histograms**: Merges the original data with the flagged outliers, highlighting outliers in red over histograms of each numeric variable. This helps visualize the extent of outliers within the distribution and assess their impact.


#### 4. Distributional Analysis --------------------------------------------

1. **Normality Checks with Shapiro-Wilk Test**:
   - **Function `perform_normality_test()`**: Applies the Shapiro-Wilk test to each numeric variable, returning p-values. A p-value > 0.05 suggests normality.
   - **Output**: A tibble showing each variable’s p-value and a flag (`is_normal`) indicating normality.

2. **QQ Plots for Visual Normality Assessment**:
   - Generates QQ plots for each numeric variable, allowing a visual assessment of normality. Deviations from the red line indicate departures from a normal distribution.

3. **Skewness and Kurtosis Calculation**:
   - **Function `calculate_skewness_kurtosis()`**: Calculates skewness and kurtosis for each numeric variable. Skewness values indicate symmetry, while kurtosis values show “peakedness” relative to a normal distribution.
   - **Output**: A tibble with skewness and kurtosis values for each numeric variable.

4. **Identify Variables for Potential Transformation**:
   - Flags variables with absolute skewness greater than 1, suggesting they may benefit from transformation (e.g., log or square root). These flagged variables are stored in `high_skew_vars` for further action.


#### 5. Data Quality Checks ------------------------------------------------

1. **Unique Values per Column**:
   - **Function `count_unique_values()`**: Counts unique values in each column to identify high-cardinality and single-value columns.
   - Flags columns with high cardinality (> 90% unique values) and single unique values, which may indicate limited value for modeling.

2. **Constant or Near-Constant Variables**:
   - **Function `detect_low_variance()`**: Calculates the coefficient of variation (CV) for numeric variables, flagging those with a CV below 0.01 as near-constant.
   - Low-variance variables may add limited predictive value and can be considered for removal.

3. **Duplicate Rows Check**:
   - Checks for duplicate rows, reporting their count and displaying them. High numbers of duplicates could indicate redundant data.

4. **Inconsistent or Erroneous Values**:
   - Checks for unexpected negative values in numeric columns and dates outside of specified ranges.
   - **Date Range Check**: Filters date columns outside of the expected date range (`start_date` to `end_date`).

5. **Date and Time Consistency**:
   - Checks if dates in `date_column` are sequentially ordered without unexpected gaps. This is helpful in time series data to ensure completeness.



### Data Cleaning and Preparation Steps (to address identified issue --------


#### 6. Missing Data Treatment ---------------------------------------------

1. **Impute Missing Values**:
   - **Function `impute_missing()`**: Imputes missing values based on the specified method (`"mean"`, `"median"`, or `"mode"`).
     - Numeric variables are imputed with mean or median values.
     - Categorical variables are imputed with mode (most frequent level).
   - The function applies the specified imputation method using `mutate(across(...))`.

2. **Drop Rows with Excessive Missing Values**:
   - **Function `drop_high_missing_rows()`**: Removes rows where the number of missing values exceeds a specified threshold (default: 50% of columns).
   - Uses `rowSums(is.na(.))` to count missing values per row and filters out rows exceeding the threshold.

3. **Remove Columns with High Missingness**:
   - **Function `drop_high_missing_cols()`**: Drops columns with missing values exceeding a specified threshold (default: 40% of rows).
   - Uses `select(where(...))` to retain only columns with fewer missing values than the threshold.


Here’s the **Outlier Treatment** code, structured for flexibility with modular functions to handle different outlier treatments, including capping, transformations, imputation, and removal.


#### 7. Outlier Treatment -------------------------------------------------------

1. **Capping/Clipping Outliers**:
   - **Function `cap_outliers()`**: Caps values below the specified lower percentile and above the upper percentile to reduce the influence of extreme values.
   - Default percentiles are set at 1st and 99th, but they can be adjusted.

2. **Transformation for Outliers**:
   - **Function `transform_outliers()`**: Applies log or square root transformations to reduce the impact of high values. 
   - Log transformation is applied only if values are positive, while square root works for non-negative values.

3. **Impute Outliers**:
   - **Function `impute_outliers()`**: Identifies outliers based on a Z-score threshold (default: 3) and imputes them using the mean or median of non-outliers.
   - Outliers are replaced with either the mean or median of the column, based on the specified method.

4. **Remove Extreme Outliers**:
   - **Function `remove_outliers()`**: Filters out rows where any numeric variable has a Z-score beyond the specified threshold.
   - This removes extreme outliers that may be erroneous or overly influential.


#### 8. Variable Transformations -------------------------------------------

1. **Normalize/Scale Numeric Variables**:
   - **Function `scale_numeric()`**: Standardizes numeric variables (mean = 0, sd = 1) for z-score scaling or normalizes them to a [0,1] range using min-max scaling.
   - The method is specified by `method = "standard"` (z-score) or `method = "minmax"`.

2. **Apply Log or Square Root Transformations for Skewed Variables**:
   - **Function `transform_skewed()`**: Applies log or square root transformations to reduce skewness in specified variables.
   - Uses a list of `skewed_vars` (e.g., identified by skewness analysis) and a transformation method (either "log" or "sqrt").

3. **Box-Cox or Yeo-Johnson Transformations**:
   - **Function `apply_power_transformation()`**: Applies Box-Cox or Yeo-Johnson transformations to address skewness without requiring positive values.
   - Uses `caret::BoxCoxTrans()` for Box-Cox (requires all positive values) and `caret::YeoJohnsonTrans()` for Yeo-Johnson, which handles zero and negative values.


#### 9. Feature Engineering ------------------------------------------------

1. **Create Interaction Terms**:
   - **Function `create_interactions()`**: Generates pairwise interaction terms for specified variables using `model.matrix(~ .^2)`.
   - Only second-order interactions are created (no higher-order), and the intercept term is removed.

2. **Generate Polynomial Features**:
   - **Function `create_polynomial_features()`**: Adds polynomial terms for selected numeric variables up to a specified degree (default: 2).
   - Uses `poly()` for polynomial transformations, creating columns for each degree of the original variable.

3. **Binning Continuous Variables**:
   - **Function `bin_continuous_variable()`**: Converts a continuous variable into bins (e.g., quartiles) and labels them as categories.
   - Uses `cut()` to create the specified number of bins, labeled as "Bin1", "Bin2", etc.

4. **Dummy Encoding Categorical Variables**:
   - **Function `dummy_encode()`**: Converts categorical variables into dummy (one-hot encoded) variables using `caret::dummyVars()`.
   - `fullRank = TRUE` ensures no redundant columns are created, making it suitable for linear models.

5. **Create Aggregate Features**:
   - **Function `create_aggregate_features()`**: Computes aggregate features (e.g., mean, sum, max) for selected variables grouped by a specified variable.
   - Uses `group_by()` and `summarise(across(...))` for aggregation, then joins the results back to the original data for a consistent format.


#### 10. Feature Selection and Reduction -----------------------------------

1. **Remove Low-Variance Features**:
   - **Function `remove_low_variance()`**: Computes variance for each numeric variable and removes those with variance below a specified threshold (default: 0.01).
   - This helps eliminate features that add minimal information and are unlikely to improve model performance.

2. **Correlation Analysis for Feature Selection**:
   - **Function `remove_highly_correlated()`**: Computes pairwise correlations for numeric variables, identifies pairs with correlation above the specified threshold (default: 0.9), and removes one variable from each highly correlated pair to avoid multicollinearity.
   - Uses a flexible approach to identify redundant features in highly correlated pairs, improving model stability.

3. **Principal Component Analysis (PCA) for Dimensionality Reduction**:
   - **Function `perform_pca()`**: Applies PCA to reduce dimensionality, retaining only the specified number of principal components (`n_components`, default: 5).
   - Returns a data frame with original non-numeric columns and selected principal components as new features.


# Final Checks and Output for Pre-bake Dataset ----------------------------


#### 11. Final Checks for Modeling Readiness -------------------------------

1. **Check Data Types**:
   - **Function `check_data_types()`**: Ensures that all variables are in appropriate formats for modeling. Character variables are converted to factors, and logicals to integers to avoid compatibility issues.

2. **Verify Column Consistency**:
   - **Function `verify_column_consistency()`**: Ensures that only the expected columns required for modeling are retained, checking if any expected columns are missing.
   - If any expected columns are missing, it provides a warning, and returns only the expected columns from the dataset.

3. **Check for Any Remaining Missing Values**:
   - **Function `check_remaining_missing()`**: Summarizes remaining missing values, if any. It outputs a summary of columns with remaining missing values to confirm that all missing values have been handled.

4. **Check for Outliers and Skewness**:
   - **Function `check_outliers_skewness()`**: Re-evaluates skewness for each numeric variable to confirm that transformations have effectively reduced skewness and outliers.
   - Flags variables with skewness above a specified threshold (default: 1) to indicate potential need for further adjustment.


#### 12. Save the Pre-bake/Modeling Dataset --------------------------------

1. **Save Processed Dataset**:
   - **Function `save_processed_dataset()`**: Saves the final dataset in both CSV and RDS formats, making it accessible for different use cases.
   - File paths (`csv_path`, `rds_path`) are customizable, allowing flexibility in saving locations.

2. **Document Changes Made During Data Preparation**:
   - **Summary of Changes**: Provides a comprehensive outline of the key steps and transformations applied during data preparation. This summary can be updated as needed to reflect the specific transformations in your workflow.
   - **Function `save_data_prep_summary()`**: Saves the preparation summary to a text file for future reference, helping with reproducibility and transparency.




