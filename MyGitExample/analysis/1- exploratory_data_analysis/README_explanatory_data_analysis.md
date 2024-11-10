
# 1. Initial Data Overview ------------------------------------------------

1. **Display Structure of the Dataset**:
   - Uses `glimpse(data)` to provide a compact overview of each column’s data type and sample values. This inline usage is simple and straightforward, so no function is needed here.

2. **Check Dimensions of the Data**:
   - Calculates the number of rows and columns with `nrow()` and `ncol()`, storing the result in `data_dimensions`. Since this is a one-off check, it’s implemented inline.

3. **List Column Names and Data Types**:
   - Lists column names and their data types by applying `class(.x)[1]` to each column. The results are reshaped with `pivot_longer()` for readability. Given the one-time execution, no function is necessary.

4. **Summary Statistics for Numeric Variables**:
   - For each numeric variable, calculates mean, median, standard deviation, minimum, and maximum, with the results stored in `numeric_summary`. Since it’s specific to numeric variables and only used here, this is kept inline.

5. **Frequency Counts for Categorical Variables**:
   - Uses `map(~ table(.))` to calculate frequency counts for each categorical variable. This concise approach provides the necessary information without needing a function, as it’s not a repetitive task.


# 2. Missing Data Analysis ------------------------------------------------

1. **Count the Number and Percentage of Missing Values per Column**:
   - Calculates the count and percentage of missing values for each column. Since this is a one-time task specific to this dataset, it’s implemented inline without a function.

2. **Visualize Missing Data Patterns**:
   - **Heatmap**: Uses `naniar::vis_miss(data)` to generate a heatmap-style visualization showing where missing values are located across columns.
   - **Bar Plot**: Creates a bar plot to show the percentage of missing values for each column, sorted in descending order. This provides a clear view of columns with the most missing values.

3. **Identify Combinations of Missing Values Across Columns**:
   - Uses an UpSet plot to visualize the combinations of missing values across columns. The `upset()` function from the `UpSetR` package is applied directly, as it’s a simple visualization setup specific to this analysis step.

4. **Check for Rows with Excessive Missing Values**:
   - Calculates the count of missing values in each row and filters rows that exceed a specified threshold (default: 50%). This inline implementation is effective for highlighting rows that may require further treatment without needing a function.


# 3. Univariate Analysis --------------------------------------------------

1. **Summary Statistics for Numeric Variables**:
   - **Function `numeric_summary()`**: Computes summary statistics for numeric variables, including skewness and kurtosis. The function provides flexibility if further analysis needs summary statistics.

2. **Histograms and Density Plots for Numeric Variables**:
   - This one-off visualization provides a visual overview of numeric variables' distributions with histograms and density plots. No function is needed because it’s a single use.

3. **Identify Outliers Using the IQR Method**:
   - **Function `identify_outliers()`**: Identifies potential outliers for each numeric variable using the IQR method. The function enables reusability if outlier detection is needed in multiple steps of the analysis pipeline.

4. **Frequency Counts for Categorical Variables**:
   - Computes frequency counts for categorical variables using `map(~ table(.))`, implemented inline as it’s a one-time summary operation.

5. **Bar Plots for Categorical Variables**:
   - Creates bar plots for categorical variables, showing category distributions in a faceted layout. Since this is a single-use visualization, no function is required.

6. **Identify Low-Frequency Categories**:
   - **Function `identify_low_freq_categories()`**: Flags categories with counts below a given threshold, making it flexible for re-use with different thresholds in various datasets.


# 4. Bivariate Analysis ---------------------------------------------------

1. **Create and Print Correlation Matrix for Numeric Variables**:
   - **Function `correlation_matrix()`**: Generates a correlation matrix for numeric variables using `cor()`. This function is modular and can be reused if correlation analysis is required at multiple steps.
   - **Heatmap**: A one-off visualization for the correlation matrix using `corrplot` to provide an intuitive visual of correlations.

2. **Scatter Plots for Pairs of Key Numeric Variables**:
   - **Function `scatter_plots()`**: Creates scatter plots for selected key numeric variables, making it flexible to customize the variables being compared. Reusable in cases where different variable subsets need to be analyzed.
   - **Example Use**: The variable names are placeholders (`"variable1"`, etc.) and should be replaced with actual column names.

3. **Boxplots of Categorical vs. Numeric Variables**:
   - Generates boxplots to display the distribution of numeric variables by categorical levels. Since this is a single visualization step, it’s implemented inline. Replace `categorical_variable` with the actual variable name.

4. **Generate Contingency Tables for Pairs of Categorical Variables**:
   - **Function `contingency_tables()`**: Creates contingency tables for each pair of categorical variables, enhancing reusability if required for other categorical analyses.

5. **Stacked Bar Chart of Categorical Variables**:
   - A one-off visualization of categorical relationships using a stacked bar chart. This chart illustrates the distribution of one categorical variable within each level of another, implemented inline for simplicity. Replace `category1` and `category2` with actual variable names.


# 5. Multivariate Analysis ------------------------------------------------

1. **Create Pair Plots for Key Numeric Variables**:
   - **Function `create_pair_plots()`**: Generates a pair plot using `GGally::ggpairs` for selected numeric variables, allowing for flexibility in choosing variables. Useful for exploring relationships in subsets of numeric data.

2. **Faceted Plots for Conditional Distributions**:
   - **Faceted Histograms and Density Plots**: Show conditional distributions of numeric variables by a categorical variable. Implemented inline as they are one-off visualizations. Replace `category_variable` with the actual categorical variable.

3. **Calculate Variance Inflation Factor (VIF) for Multicollinearity Assessment**:
   - **Function `calculate_vif()`**: Calculates VIF to assess multicollinearity among numeric predictors. The model temporarily uses the first column as the target variable and can be adapted based on analysis needs.

4. **Create Interaction Terms Between Numeric and Categorical Variables**:
   - **Function `create_interaction_terms()`**: Creates interaction terms between numeric variables and a categorical variable, with interaction terms added as new columns. This function enables reusability if multiple interaction analyses are needed.
   - **Visualization of Interaction Terms**: Histograms of the interaction terms show the distribution of each created interaction term.


# 6. Outlier Detection and Analysis ---------------------------------------

1. **Create Boxplots for Outlier Detection**:
   - **Function `create_boxplots()`**: Generates boxplots for each numeric variable, highlighting potential outliers in red. This function provides modularity and flexibility if boxplot-based outlier detection is needed repeatedly.

2. **Calculate Z-scores for Outlier Detection**:
   - **Function `calculate_z_scores()`**: Calculates Z-scores for each numeric variable and flags values exceeding +/- 3 standard deviations as outliers. This modular function can be reused for statistical outlier detection.

3. **Visualize Outliers Within Variable Distributions**:
   - **Overlay Outliers on Histograms**: Displays the distribution of each numeric variable with Z-score outliers highlighted as dashed vertical lines. This is a single-use visualization to provide a clear view of where outliers lie within distributions, so it is implemented inline.


# 7. Distributional Analysis ----------------------------------------------

1. **Perform Shapiro-Wilk Normality Test for Each Numeric Variable**:
   - **Function `normality_test()`**: Conducts Shapiro-Wilk tests on each numeric variable, returning a tibble with p-values to assess normality. Reusable if needed for multiple normality checks in different sections.

2. **QQ Plots for Normality Assessment**:
   - **QQ Plot Visualization**: Uses `ggplot2` to display QQ plots for numeric variables, with red lines as reference lines for normality. This visualization is one-off, so it remains inline.

3. **Identify Skewed Variables Based on Skewness Threshold**:
   - **Function `identify_skewed_vars()`**: Calculates skewness for each numeric variable and flags variables that exceed a specified skewness threshold (default: 1). This function adds flexibility for different skewness thresholds.

4. **Apply Log and Square Root Transformations to Skewed Variables**:
   - **Function `apply_transformations()`**: Applies log transformations for positively skewed variables and square root transformations for others. The function is modular, allowing different transformations to be applied as needed.

5. **Compare Original and Transformed Distributions**:
   - **Histogram Visualization**: Displays histograms of the transformed variables to assess the impact of transformations. This is a single-use visualization, so it remains inline.
   
   
# 8. Target Variable Analysis  --------------------------------------------

1. **Plot the Distribution of the Target Variable**:
   - **Function `plot_target_distribution()`**: Checks if the target is continuous or categorical and creates a histogram or bar plot accordingly. This function provides flexibility in handling different types of target variables.

2. **Examine Relationship Between Target Variable and Key Predictors**:
   - **Function `examine_target_relationships()`**: Creates scatter plots for continuous targets and boxplots for categorical targets, visualizing the relationship with specified predictors. This function is modular and reusable, supporting both numeric and categorical targets.

3. **Generate Summary Statistics for the Target Variable by Group**:
   - **Function `generate_target_summary_by_group()`**: Provides summary statistics for a continuous target or frequency counts for a categorical target, grouped by a specified variable. This function is flexible, supporting different target types and grouping variables.

4. **Bar Plot for Categorical Target Variable by Groups**:
   - **Inline Bar Plot Visualization**: For categorical targets, displays the count distribution by groups in a bar plot. This one-off visualization remains inline for simplicity.


# 9. Feature Engineering Exploration --------------------------------------

1. **Generate Interaction Terms for Specified Variables**:
   - **Function `generate_interaction_terms()`**: Creates pairwise interaction terms for specified numeric variables. This function supports modularity by allowing flexible variable selection and reusability.

2. **Generate Polynomial Features for Numeric Variables**:
   - **Function `generate_polynomial_features()`**: Generates polynomial features of a specified degree for given numeric variables, useful for modeling non-linear relationships. This function can handle any degree of polynomial specified by the user.

3. **Dummy Encode Categorical Variables**:
   - **Function `dummy_encode()`**: Applies dummy encoding to categorical variables in the dataset, returning a data frame with one-hot encoded columns, which is useful for preparing data for machine learning models.

4. **Scale Numeric Variables**:
   - **Function `scale_numeric_vars()`**: Standardizes numeric variables to a mean of 0 and standard deviation of 1. The function makes it easy to apply consistent scaling across datasets.

5. **Normalize Numeric Variables to [0, 1] Range**:
   - **Function `normalize_numeric_vars()`**: Normalizes numeric variables to a [0,1] range, making data consistent across different scaling needs.

6. **Binning of Continuous Variables**:
   - **Inline Binning Example**: Bins `age` into fixed categories and `income` into quantile-based buckets, shown inline as these are specific examples. Replace with relevant variables as needed for your data.


# 10. Data Quality Checks -------------------------------------------------

1. **Check Unique Values per Column**:
   - **Function `check_unique_values()`**: Calculates unique value counts for each column, then identifies columns with a single unique value or high cardinality (more than 90% unique values). This function modularizes checks for unique values, allowing flexibility.

2. **Detect Near-Constant Variables Based on Coefficient of Variation**:
   - **Function `detect_near_constant_vars()`**: Identifies near-constant variables based on a coefficient of variation threshold of 0.01. This function is useful for repeated analysis, making it easy to adjust thresholds.

3. **Identify Duplicate Rows in Dataset**:
   - **Function `identify_duplicate_rows()`**: Detects duplicate rows in the dataset, a common quality check. This function simplifies repeated use in various datasets.

4. **Inconsistent or Erroneous Values**:
   - **Inline Checks for Negative Values and Date Range**: Checks for negative values in numeric variables and dates outside a specified range. These are kept inline as they’re specific checks that may vary depending on the dataset.

5. **Check Date Consistency for Sequential Order in Time Series**:
   - **Function `check_date_consistency()`**: Checks for sequential dates in a time series, detecting any gaps in the expected daily order. Useful for time series data where date consistency is critical.


# 11. Automated EDA Report ------------------------------------------------

1. **`data`**: Your dataset, which will be used for the automated EDA report.
2. **`output_file`**: Sets the name of the HTML file generated. Here, it’s named `"EDA_Report.html"`.
3. **`output_dir`**: Specifies the directory where the report will be saved. Using `getwd()` will save it to the current working directory.
4. **`y` (Optional)**: Specifies the target variable (e.g., "target_variable") if applicable. This helps DataExplorer generate additional insights related to the target, such as relationships with other variables.

### Generated Report

The HTML report generated by `create_report()` includes sections such as:
- **Data Structure**: Overview of data types and missing values.
- **Data Summaries**: Summary statistics and frequency distributions.
- **Correlation Analysis**: Correlation matrix and visualizations for numeric variables.
- **Outlier Detection**: Identification and summary of potential outliers.
- **Feature Relationships**: Insights on relationships between variables and the target variable if specified.
- etc






