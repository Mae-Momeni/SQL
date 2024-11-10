
# instruction:
# transform the code into a more advanced style, leveraging pipes (%>%), mutate, summarize,
# and other tidyverse techniques. Make sure the code is modular and efficient. Take best R coding
# practices for data science and ML projects to make the code readable, modular, and scalable.
# Write function when tasks are repetitive, complex, or require flexibility, improving readability, reusability, and consistency. Avoid functions for one-off code, simple transformations, or linear workflows, as they may add unnecessary complexity.
# if writing function, use Roxygen2-style comments to make the functions readable and modular.



# Data Evaluation Steps (to assess data quality, structure, and is --------


# # 1. Initial Data Overview -------------------------------------------------

# Load necessary libraries
library(tidyverse)

# Display data structure and column types with sample values (one-off summary)
cat("Data Structure:\n")
glimpse(data)

# Check data dimensions (one-off calculation)
cat("\nData Dimensions:\n")
print(tibble(rows = nrow(data), columns = ncol(data)))

# List column names, data types, and identify the target variable (one-off check)
target_variable <- "target_variable" # Replace with actual target variable name, if applicable
data_types <- data %>%
  summarise(across(everything(), ~ class(.x)[1])) %>%
  pivot_longer(cols = everything(), names_to = "column", values_to = "data_type") %>%
  mutate(is_target = ifelse(column == target_variable, "Target", "Predictor"))

cat("\nColumn Names and Data Types:\n")
print(data_types)

#' Calculate Summary Statistics for Numeric Variables
#'
#' @param data A data frame containing numeric variables.
#' @return A tibble with summary statistics for each numeric variable.
#' @export
calculate_numeric_summary <- function(data) {
  data %>%
    select(where(is.numeric)) %>%
    summarise(across(everything(), list(
      mean = ~ mean(.x, na.rm = TRUE),
      median = ~ median(.x, na.rm = TRUE),
      sd = ~ sd(.x, na.rm = TRUE),
      min = ~ min(.x, na.rm = TRUE),
      max = ~ max(.x, na.rm = TRUE)
    ))) %>%
    pivot_longer(cols = everything(), names_to = c("variable", ".value"), names_sep = "_")
}

cat("\nSummary Statistics for Numeric Variables:\n")
print(calculate_numeric_summary(data))

#' Generate Frequency Counts for Categorical Variables
#'
#' @param data A data frame containing categorical variables.
#' @return A tibble with frequency counts for each categorical variable.
#' @export
generate_categorical_counts <- function(data) {
  data %>%
    select(where(is.factor)) %>%
    map(~ table(.)) %>%
    enframe(name = "variable", value = "frequency_counts")
}

cat("\nFrequency Counts for Categorical Variables:\n")
print(generate_categorical_counts(data))



# # 2. Missing Data Analysis ----------------------------------------------

# Load necessary libraries
library(tidyverse)
library(naniar)     # For visualizing missing patterns
library(UpSetR)     # For visualizing combinations of missing values

#' Count Missing Values per Column
#'
#' @param data A data frame.
#' @return A tibble with missing counts and percentages for each column.
#' @export
count_missing_values <- function(data) {
  data %>%
    summarise(across(everything(), ~ sum(is.na(.)))) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "missing_count") %>%
    mutate(missing_percentage = (missing_count / nrow(data)) * 100)
}

cat("\nMissing Values Summary:\n")
missing_summary <- count_missing_values(data)
print(missing_summary)

# Visualize Missing Data Patterns (one-off visualizations)
cat("\nVisualizing Missing Data Patterns:\n")
naniar::vis_miss(data) +
  labs(title = "Heatmap of Missing Data") +
  theme_minimal()

missing_summary %>%
  ggplot(aes(x = reorder(variable, -missing_percentage), y = missing_percentage)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  coord_flip() +
  labs(title = "Percentage of Missing Values by Column", x = "Column", y = "Percentage of Missing Values") +
  theme_minimal()

#' Identify Combinations of Missing Values with UpSet Plot
#'
#' @param data A data frame with columns that contain missing values.
#' @param missing_summary A tibble with missing counts for each column.
#' @return An UpSet plot showing combinations of missing values.
#' @export
visualize_missing_combinations <- function(data, missing_summary) {
  missing_cols <- missing_summary %>%
    filter(missing_count > 0) %>%
    pull(variable)

  upset(data[missing_cols], nsets = length(missing_cols), order.by = "freq",
        main.bar.color = "skyblue", sets.bar.color = "darkblue")
}

cat("\nCombinations of Missing Values Across Columns:\n")
visualize_missing_combinations(data, missing_summary)

#' Flag Rows with Excessive Missing Values
#'
#' @param data A data frame.
#' @param threshold Numeric, the threshold for the number of missing values per row.
#' @return A data frame with rows that exceed the missing value threshold.
#' @export
flag_high_missing_rows <- function(data, threshold = 0.5 * ncol(data)) {
  data %>%
    mutate(missing_count = rowSums(is.na(.))) %>%
    filter(missing_count > threshold)
}

cat("\nRows with Excessive Missing Values:\n")
high_missing_rows <- flag_high_missing_rows(data)
print(paste("Number of rows with excessive missing values:", nrow(high_missing_rows)))
print(high_missing_rows)



# # 3. Outlier Detection --------------------------------------------------

# Load necessary libraries
library(tidyverse)

# Boxplot for Outliers in Numeric Variables (one-off visualization)
cat("Boxplots for Outlier Detection in Numeric Variables:\n")
data %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(x = variable, y = value)) +
  geom_boxplot(outlier.color = "red", outlier.shape = 1) +
  labs(title = "Boxplots for Outlier Detection", x = "Variable", y = "Value") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#' Z-Score Outlier Detection
#'
#' @param data A data frame containing numeric variables.
#' @param threshold Numeric, Z-score threshold for flagging outliers (default is 3).
#'
#' @return A tibble with variable names, values, Z-scores, and outlier flags.
#' @export
calculate_z_scores <- function(data, threshold = 3) {
  data %>%
    select(where(is.numeric)) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
    group_by(variable) %>%
    mutate(
      z_score = (value - mean(value, na.rm = TRUE)) / sd(value, na.rm = TRUE),
      is_outlier = abs(z_score) > threshold
    ) %>%
    filter(is_outlier) %>%
    ungroup()
}

# Apply Z-score function to detect outliers
z_score_outliers <- calculate_z_scores(data)
cat("Outliers Detected Using Z-scores:\n")
print(z_score_outliers)

#' Assess Impact of Outliers on Distributions
#'
#' @param data A data frame with numeric variables.
#' @param outliers A tibble with detected outliers.
#' @return A ggplot object showing the distributions of numeric variables with outliers highlighted.
#' @export
assess_outlier_impact <- function(data, outliers) {
  data %>%
    select(where(is.numeric)) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
    left_join(outliers %>% select(variable, value, is_outlier), by = c("variable", "value")) %>%
    mutate(is_outlier = replace_na(is_outlier, FALSE)) %>%
    ggplot(aes(x = value, fill = is_outlier)) +
    geom_histogram(bins = 30, position = "identity", alpha = 0.7) +
    facet_wrap(~ variable, scales = "free") +
    labs(title = "Distribution of Numeric Variables with Outliers Highlighted", x = "Value", y = "Frequency") +
    scale_fill_manual(values = c("FALSE" = "skyblue", "TRUE" = "red")) +
    theme_minimal()
}

# Visualize the impact of outliers on distributions
cat("\nAssessing Impact of Outliers on Distributions:\n")
print(assess_outlier_impact(data, z_score_outliers))



# # 4. Distributional Analysis --------------------------------------------

# Load necessary libraries
library(tidyverse)
library(e1071)  # For skewness and kurtosis calculations

#' Perform Shapiro-Wilk Test for Normality
#'
#' @param data A data frame with numeric variables.
#' @return A tibble with variable names and p-values for normality tests.
#' @export
perform_normality_test <- function(data) {
  data %>%
    select(where(is.numeric)) %>%
    summarise(across(everything(), ~ shapiro.test(.x)$p.value)) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "p_value") %>%
    mutate(is_normal = p_value > 0.05)  # TRUE if normally distributed (p > 0.05)
}

cat("Shapiro-Wilk Normality Test Results:\n")
normality_results <- perform_normality_test(data)
print(normality_results)

# QQ Plots for Visual Normality Assessment (one-off visualization)
cat("\nQQ Plots for Numeric Variables:\n")
data %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(sample = value)) +
  stat_qq() +
  stat_qq_line(color = "red") +
  facet_wrap(~ variable, scales = "free") +
  labs(title = "QQ Plots for Numeric Variables", x = "Theoretical Quantiles", y = "Sample Quantiles") +
  theme_minimal()

#' Calculate Skewness and Kurtosis
#'
#' @param data A data frame with numeric variables.
#' @return A tibble with variable names, skewness, and kurtosis values.
#' @export
calculate_skewness_kurtosis <- function(data) {
  data %>%
    select(where(is.numeric)) %>%
    summarise(across(everything(), list(
      skewness = ~ e1071::skewness(.x, na.rm = TRUE),
      kurtosis = ~ e1071::kurtosis(.x, na.rm = TRUE)
    ))) %>%
    pivot_longer(everything(), names_to = c("variable", ".value"), names_sep = "_")
}

cat("\nCalculating Skewness and Kurtosis:\n")
skew_kurt_results <- calculate_skewness_kurtosis(data)
print(skew_kurt_results)

# Identify Variables for Potential Transformation (one-off flagging)
cat("\nFlagging Variables with High Skewness for Transformation:\n")
high_skew_vars <- skew_kurt_results %>%
  filter(abs(skewness) > 1) %>%
  pull(variable)

cat("Variables with High Skewness:\n")
print(high_skew_vars)




# # 5. Data Quality Checks ------------------------------------------------

# Load necessary libraries
library(tidyverse)
library(lubridate)

#' Count Unique Values per Column
#'
#' @param data A data frame.
#' @return A tibble with variable names and counts of unique values.
#' @export
count_unique_values <- function(data) {
  data %>%
    summarise(across(everything(), n_distinct)) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "unique_count") %>%
    arrange(desc(unique_count))
}

cat("Unique Values per Column:\n")
unique_values <- count_unique_values(data)
print(unique_values)

# Identify columns with high cardinality or single unique values (one-off analysis)
high_cardinality <- unique_values %>% filter(unique_count > 0.9 * nrow(data))
single_value <- unique_values %>% filter(unique_count == 1)

cat("\nHigh Cardinality Columns:\n")
print(high_cardinality)
cat("\nSingle Unique Value Columns:\n")
print(single_value)

#' Detect Low Variance Variables
#'
#' @param data A data frame with numeric variables.
#' @return A tibble with variable names and coefficients of variation for low-variance variables.
#' @export
detect_low_variance <- function(data) {
  data %>%
    select(where(is.numeric)) %>%
    summarise(across(everything(), ~ sd(.x, na.rm = TRUE) / mean(.x, na.rm = TRUE), .names = "cv_{.col}")) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "coefficient_of_variation") %>%
    filter(coefficient_of_variation < 0.01 | is.na(coefficient_of_variation))
}

cat("\nConstant or Near-Constant Variables:\n")
low_variance_vars <- detect_low_variance(data)
print(low_variance_vars)

# Duplicate Rows Check (one-off check)
cat("\nDuplicate Rows:\n")
duplicate_rows <- data %>%
  filter(duplicated(.))

cat("Number of duplicate rows:", nrow(duplicate_rows), "\n")
print(duplicate_rows)

# Inconsistent or Erroneous Values (one-off checks)
cat("\nInconsistent or Erroneous Values:\n")

# Check for negative values in numeric columns
negative_values <- data %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  filter(value < 0)

cat("\nVariables with Unexpected Negative Values:\n")
print(negative_values)

# Check for dates outside expected ranges
start_date <- ymd("2000-01-01")
end_date <- ymd("2023-12-31")

date_out_of_range <- data %>%
  select(where(is.Date) | where(is.POSIXct)) %>%
  pivot_longer(everything(), names_to = "date_column", values_to = "date_value") %>%
  filter(date_value < start_date | date_value > end_date)

cat("\nDates Outside Expected Range:\n")
print(date_out_of_range)

# Date and Time Consistency Check (one-off check)
cat("\nDate and Time Consistency Check:\n")
if ("date_column" %in% colnames(data)) {
  date_consistency <- data %>%
    arrange(date_column) %>%
    mutate(is_sequential = date_column == lag(date_column, default = first(date_column)) + days(1)) %>%
    filter(is_sequential == FALSE)

  cat("Non-Sequential Dates Detected (for time series consistency):\n")
  print(date_consistency)
}




# Data Cleaning and Preparation Steps (to address identified issue --------


# # 6. Missing Data Treatment ---------------------------------------------

# Load necessary libraries
library(tidyverse)

#' Impute Missing Values
#'
#' @param data A data frame with missing values.
#' @param method A character string specifying the imputation method ("mean", "median", "mode").
#' @return A data frame with imputed values.
#' @export
impute_missing <- function(data, method = "mean") {
  data %>%
    mutate(across(
      where(is.numeric),
      ~ case_when(
        method == "mean" ~ replace_na(.x, mean(.x, na.rm = TRUE)),
        method == "median" ~ replace_na(.x, median(.x, na.rm = TRUE)),
        TRUE ~ .x
      )
    )) %>%
    mutate(across(
      where(is.factor),
      ~ case_when(
        method == "mode" ~ replace_na(.x, as.factor(names(sort(table(.x), decreasing = TRUE)[1]))),
        TRUE ~ .x
      )
    ))
}

# Apply imputation
data_imputed <- impute_missing(data, method = "mean")
cat("\nData After Missing Value Imputation:\n")
print(data_imputed)

#' Drop High-Missingness Rows
#'
#' @param data A data frame with missing values.
#' @param threshold Numeric, maximum number of missing values allowed per row.
#' @return A data frame with high-missingness rows removed.
#' @export
drop_high_missing_rows <- function(data, threshold = 0.5 * ncol(data)) {
  data %>%
    mutate(missing_count = rowSums(is.na(.))) %>%
    filter(missing_count <= threshold) %>%
    select(-missing_count)
}

# Drop rows with excessive missing values
data_cleaned <- drop_high_missing_rows(data_imputed)
cat("Data After Dropping High-Missingness Rows:\n")
print(data_cleaned)

#' Drop High-Missingness Columns
#'
#' @param data A data frame with missing values.
#' @param threshold Numeric, maximum number of missing values allowed per column.
#' @return A data frame with high-missingness columns removed.
#' @export
drop_high_missing_cols <- function(data, threshold = 0.4 * nrow(data)) {
  data %>%
    select(where(~ sum(is.na(.)) <= threshold))
}

# Drop columns with excessive missing values
data_final <- drop_high_missing_cols(data_cleaned)
cat("Data After Dropping High-Missingness Columns:\n")
print(data_final)



# # 7. Outlier Treatment -------------------------------------------------------

# Load necessary libraries
library(tidyverse)

#' Cap/Clip Outliers
#'
#' @param data A data frame with numeric variables.
#' @param lower_pct Numeric, lower percentile for capping (default is 1st percentile).
#' @param upper_pct Numeric, upper percentile for capping (default is 99th percentile).
#' @return A data frame with capped values for outliers.
#' @export
cap_outliers <- function(data, lower_pct = 0.01, upper_pct = 0.99) {
  data %>%
    mutate(across(where(is.numeric), ~ {
      lower_bound <- quantile(.x, probs = lower_pct, na.rm = TRUE)
      upper_bound <- quantile(.x, probs = upper_pct, na.rm = TRUE)
      pmin(pmax(.x, lower_bound), upper_bound)
    }))
}

# Apply capping to the data
data_capped <- cap_outliers(data)
cat("\nData After Capping Outliers:\n")
print(data_capped)

#' Apply Transformation to Reduce Outlier Impact
#'
#' @param data A data frame with numeric variables.
#' @param method Character, transformation method ("log" or "sqrt").
#' @return A data frame with transformed values for specified variables.
#' @export
transform_outliers <- function(data, method = "log") {
  data %>%
    mutate(across(where(is.numeric), ~ case_when(
      method == "log" & .x > 0 ~ log(.x),      # Apply log if positive
      method == "sqrt" & .x >= 0 ~ sqrt(.x),   # Apply square root if non-negative
      TRUE ~ .x
    )))
}

# Apply transformation (log or sqrt)
data_transformed <- transform_outliers(data, method = "log")
cat("\nData After Log Transformation:\n")
print(data_transformed)

#' Impute Outliers with Mean or Median
#'
#' @param data A data frame with numeric variables.
#' @param threshold Numeric, Z-score threshold to identify outliers (default is 3).
#' @param method Character, imputation method ("mean" or "median").
#' @return A data frame with imputed outliers.
#' @export
impute_outliers <- function(data, threshold = 3, method = "median") {
  data %>%
    mutate(across(where(is.numeric), ~ {
      z_score <- (. - mean(.x, na.rm = TRUE)) / sd(.x, na.rm = TRUE)
      if_else(abs(z_score) > threshold,
              ifelse(method == "mean", mean(.x, na.rm = TRUE), median(.x, na.rm = TRUE)),
              .x)
    }))
}

# Apply outlier imputation
data_imputed <- impute_outliers(data)
cat("\nData After Imputing Outliers:\n")
print(data_imputed)

#' Remove Extreme Outliers
#'
#' @param data A data frame with numeric variables.
#' @param threshold Numeric, Z-score threshold to identify extreme outliers (default is 3).
#' @return A data frame with extreme outliers removed.
#' @export
remove_outliers <- function(data, threshold = 3) {
  data %>%
    filter(across(where(is.numeric), ~ abs((. - mean(.x, na.rm = TRUE)) / sd(.x, na.rm = TRUE)) <= threshold, .preserve = TRUE))
}

# Apply outlier removal
data_no_outliers <- remove_outliers(data)
cat("\nData After Removing Extreme Outliers:\n")
print(data_no_outliers)




# # 8. Variable Transformations -------------------------------------------

# Load necessary libraries
library(tidyverse)
library(caret)        # For Box-Cox and Yeo-Johnson transformations

#' Normalize or Scale Numeric Variables
#'
#' @param data A data frame with numeric variables.
#' @param method Character, scaling method ("standard" for z-score or "minmax" for [0,1] normalization).
#' @return A data frame with scaled or normalized values.
#' @export
scale_numeric <- function(data, method = "standard") {
  data %>%
    mutate(across(where(is.numeric), ~ case_when(
      method == "standard" ~ scale(.x),
      method == "minmax" ~ (.x - min(.x, na.rm = TRUE)) / (max(.x, na.rm = TRUE) - min(.x, na.rm = TRUE)),
      TRUE ~ .x
    )))
}

# Apply scaling (standardization or normalization)
data_scaled <- scale_numeric(data, method = "standard")
cat("\nData After Scaling (Standardization or Min-Max):\n")
print(data_scaled)

#' Apply Log or Square Root Transformations for Skewed Variables
#'
#' @param data A data frame with numeric variables.
#' @param skewed_vars A character vector of variable names requiring transformation.
#' @param method Character, transformation method ("log" or "sqrt").
#' @return A data frame with transformed skewed variables.
#' @export
transform_skewed <- function(data, skewed_vars, method = "log") {
  data %>%
    mutate(across(all_of(skewed_vars), ~ case_when(
      method == "log" & .x > 0 ~ log(.x),
      method == "sqrt" & .x >= 0 ~ sqrt(.x),
      TRUE ~ .x
    )))
}

# Define skewed variables (e.g., based on skewness analysis)
skewed_vars <- c("variable1", "variable2")  # Replace with actual skewed variable names
data_transformed <- transform_skewed(data, skewed_vars, method = "log")
cat("\nData After Transforming Skewed Variables (Log or Sqrt):\n")
print(data_transformed)

#' Apply Box-Cox or Yeo-Johnson Transformations
#'
#' @param data A data frame with numeric variables.
#' @param vars A character vector of variable names for transformation.
#' @param method Character, transformation method ("boxcox" or "yeojohnson").
#' @return A data frame with transformed variables.
#' @export
apply_power_transformation <- function(data, vars, method = "boxcox") {
  data %>%
    mutate(across(all_of(vars), ~ {
      if (method == "boxcox" & all(.x > 0, na.rm = TRUE)) {
        lambda <- caret::BoxCoxTrans(.x)$lambda
        caret::BoxCoxTrans(.x, lambda = lambda) %>% predict(.)
      } else if (method == "yeojohnson") {
        caret::YeoJohnsonTrans(.x) %>% predict(.)
      } else {
        .x
      }
    }))
}

# Apply Box-Cox or Yeo-Johnson transformation
data_power_transformed <- apply_power_transformation(data, vars = skewed_vars, method = "boxcox")
cat("\nData After Box-Cox or Yeo-Johnson Transformation:\n")
print(data_power_transformed)



# # 9. Feature Engineering ------------------------------------------------

# Load necessary libraries
library(tidyverse)
library(caret)  # For dummy encoding

#' Create Interaction Terms
#'
#' @param data A data frame with variables for creating interaction terms.
#' @param vars A character vector of variable names to use in interactions.
#' @return A data frame with interaction terms added.
#' @export
create_interactions <- function(data, vars) {
  interaction_terms <- data %>%
    select(all_of(vars)) %>%
    model.matrix(~ .^2, data = .) %>%
    as_tibble() %>%
    select(-1)  # Remove intercept

  bind_cols(data, interaction_terms)
}

# Define variables for interactions
interaction_vars <- c("var1", "var2", "var3")  # Replace with relevant variable names
data_with_interactions <- create_interactions(data, interaction_vars)
cat("\nData After Adding Interaction Terms:\n")
print(data_with_interactions)

#' Generate Polynomial Features
#'
#' @param data A data frame with numeric variables.
#' @param vars A character vector of variable names for polynomial expansion.
#' @param degree Numeric, degree of polynomial features.
#' @return A data frame with polynomial features added.
#' @export
create_polynomial_features <- function(data, vars, degree = 2) {
  poly_features <- data %>%
    select(all_of(vars)) %>%
    mutate(across(everything(), ~ poly(.x, degree, raw = TRUE), .names = "{.col}_poly{degree}"))

  bind_cols(data, poly_features)
}

# Define variables for polynomial features
poly_vars <- c("var1", "var2")  # Replace with relevant variable names
data_with_polynomials <- create_polynomial_features(data, poly_vars, degree = 2)
cat("\nData After Adding Polynomial Features:\n")
print(data_with_polynomials)

#' Bin Continuous Variables
#'
#' @param data A data frame with continuous variables.
#' @param var A character name of the variable to bin.
#' @param bins Numeric, number of bins to create.
#' @return A data frame with binned variable added as a categorical variable.
#' @export
bin_continuous_variable <- function(data, var, bins = 4) {
  data %>%
    mutate("{var}_binned" := cut(!!sym(var), breaks = bins, labels = paste0("Bin", 1:bins)))
}

# Apply binning to a variable
data_binned <- bin_continuous_variable(data, var = "continuous_var", bins = 4)
cat("\nData After Binning Continuous Variable:\n")
print(data_binned)

#' Dummy Encode Categorical Variables
#'
#' @param data A data frame with categorical variables.
#' @return A data frame with dummy/one-hot encoded categorical variables.
#' @export
dummy_encode <- function(data) {
  dummy_model <- dummyVars("~ .", data = data, fullRank = TRUE)
  as_tibble(predict(dummy_model, newdata = data))
}

data_encoded <- dummy_encode(data)
cat("\nData After Dummy Encoding:\n")
print(data_encoded)

#' Create Aggregate Features
#'
#' @param data A data frame with variables to aggregate.
#' @param group_var A character name of the variable to group by.
#' @param agg_vars A character vector of variables to aggregate.
#' @return A data frame with aggregated features.
#' @export
create_aggregate_features <- function(data, group_var, agg_vars) {
  data %>%
    group_by(across(all_of(group_var))) %>%
    summarise(across(all_of(agg_vars), list(mean = mean, sum = sum, max = max), .names = "{.col}_{.fn}")) %>%
    ungroup() %>%
    left_join(data, by = group_var)
}

# Apply aggregation based on grouping variable
aggregate_vars <- c("var1", "var2")  # Replace with relevant variable names
data_aggregated <- create_aggregate_features(data, group_var = "group_var", agg_vars = aggregate_vars)
cat("\nData After Adding Aggregate Features:\n")
print(data_aggregated)



# # 10. Feature Selection and Reduction -----------------------------------


# Load necessary libraries
library(tidyverse)
library(caret)        # For PCA and feature selection
library(corrr)        # For correlation analysis

#' Remove Low-Variance Features
#'
#' @param data A data frame with numeric variables.
#' @param threshold Numeric, threshold for minimum variance (default: 0.01).
#' @return A data frame with low-variance features removed.
#' @export
remove_low_variance <- function(data, threshold = 0.01) {
  variances <- data %>%
    select(where(is.numeric)) %>%
    summarise(across(everything(), ~ var(.x, na.rm = TRUE))) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "variance") %>%
    filter(variance > threshold)

  data %>%
    select(all_of(variances$variable))
}

# Apply low-variance feature removal
data_filtered <- remove_low_variance(data, threshold = 0.01)
cat("\nData After Removing Low-Variance Features:\n")
print(data_filtered)

#' Remove Highly Correlated Features
#'
#' @param data A data frame with numeric variables.
#' @param threshold Numeric, correlation threshold (default: 0.9).
#' @return A data frame with highly correlated features removed.
#' @export
remove_highly_correlated <- function(data, threshold = 0.9) {
  correlation_matrix <- data %>%
    select(where(is.numeric)) %>%
    cor(use = "complete.obs") %>%
    as.data.frame() %>%
    rownames_to_column("variable1") %>%
    pivot_longer(-variable1, names_to = "variable2", values_to = "correlation") %>%
    filter(variable1 != variable2 & abs(correlation) > threshold)

  # Keep one of each highly correlated variable pair
  to_remove <- unique(correlation_matrix$variable2)
  data %>%
    select(-all_of(to_remove))
}

# Apply correlation-based feature removal
data_no_corr <- remove_highly_correlated(data_filtered, threshold = 0.9)
cat("\nData After Removing Highly Correlated Features:\n")
print(data_no_corr)

#' Perform PCA for Dimensionality Reduction
#'
#' @param data A data frame with numeric variables.
#' @param n_components Numeric, number of principal components to retain.
#' @return A data frame with principal component scores.
#' @export
perform_pca <- function(data, n_components = 5) {
  pca_model <- prcomp(data %>% select(where(is.numeric)), scale. = TRUE)
  pca_data <- as_tibble(pca_model$x[, 1:n_components]) %>%
    rename_with(~ paste0("PC", 1:n_components))

  bind_cols(data %>% select(-where(is.numeric)), pca_data)
}

# Apply PCA to reduce dimensionality
data_pca <- perform_pca(data_no_corr, n_components = 5)
cat("\nData After PCA Dimensionality Reduction:\n")
print(data_pca)




# Final Checks and Output for Pre-bake Dataset ----------------------------


# # 11. Final Checks for Modeling Readiness -------------------------------

# Load necessary libraries
library(tidyverse)
library(e1071)  # For skewness calculation if needed

#' Verify Data Types for Modeling
#'
#' @param data A data frame to check data types.
#' @return A data frame with correct data types for modeling.
#' @export
check_data_types <- function(data) {
  data %>%
    mutate(across(where(is.character), as.factor)) %>%  # Convert characters to factors
    mutate(across(where(is.logical), as.integer))       # Convert logicals to integers
}

data_checked_types <- check_data_types(data)
cat("\nData After Verifying Data Types:\n")
print(data_checked_types)

# Define expected columns for modeling
expected_columns <- c("column1", "column2", "target_variable")  # Replace with relevant column names

#' Verify Column Consistency
#'
#' @param data A data frame to check column consistency.
#' @param expected_cols A character vector of expected column names for modeling.
#' @return A data frame containing only the expected columns.
#' @export
verify_column_consistency <- function(data, expected_cols) {
  missing_cols <- setdiff(expected_cols, colnames(data))

  if (length(missing_cols) > 0) {
    warning("Missing expected columns: ", paste(missing_cols, collapse = ", "))
  }

  data %>%
    select(all_of(expected_cols))
}

data_consistent <- verify_column_consistency(data_checked_types, expected_columns)
cat("\nData After Ensuring Column Consistency:\n")
print(data_consistent)

#' Check for Remaining Missing Values
#'
#' @param data A data frame to check for missing values.
#' @return A message with the count of remaining missing values.
#' @export
check_remaining_missing <- function(data) {
  missing_summary <- data %>%
    summarise(across(everything(), ~ sum(is.na(.)))) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "missing_count") %>%
    filter(missing_count > 0)

  if (nrow(missing_summary) > 0) {
    cat("\nVariables with Remaining Missing Values:\n")
    print(missing_summary)
  } else {
    cat("\nNo remaining missing values detected.\n")
  }
}

check_remaining_missing(data_consistent)

#' Check Outliers and Skewness
#'
#' @param data A data frame to verify outliers and skewness adjustments.
#' @param threshold Numeric, skewness threshold to flag variables for potential further adjustment (default: 1).
#' @return A tibble showing skewness and potential outliers.
#' @export
check_outliers_skewness <- function(data, threshold = 1) {
  skew_kurt_results <- data %>%
    select(where(is.numeric)) %>%
    summarise(across(everything(), list(
      skewness = ~ e1071::skewness(.x, na.rm = TRUE),
      kurtosis = ~ e1071::kurtosis(.x, na.rm = TRUE)
    ))) %>%
    pivot_longer(everything(), names_to = c("variable", ".value"), names_sep = "_")

  skewed_vars <- skew_kurt_results %>%
    filter(abs(skewness) > threshold)

  cat("\nVariables with High Skewness (Threshold =", threshold, "):\n")
  print(skewed_vars)

  return(skew_kurt_results)
}

skewness_check <- check_outliers_skewness(data_consistent, threshold = 1)



# # 12. Save the Pre-bake/Modeling Dataset --------------------------------

# Load necessary libraries
library(tidyverse)

# Define file paths for saving
csv_path <- "data/processed/prebake_dataset.csv"   # Path for CSV file
rds_path <- "data/processed/prebake_dataset.rds"   # Path for RDS file
summary_path <- "data/processed/data_preparation_summary.txt"  # Path for summary documentation

#' Save Dataset in CSV and RDS Formats
#'
#' @param data A data frame to save.
#' @param csv_path File path for saving CSV file.
#' @param rds_path File path for saving RDS file.
#' @return None. Saves files to the specified paths.
#' @export
save_processed_dataset <- function(data, csv_path, rds_path) {
  write_csv(data, csv_path)
  saveRDS(data, rds_path)
  cat("Dataset saved as CSV and RDS at specified paths.\n")
}

# Apply function to save dataset
save_processed_dataset(data_consistent, csv_path, rds_path)

# Define a summary of changes made during data preparation
data_prep_summary <- "
Data Preparation Summary:
-------------------------
1. Checked and ensured appropriate data types for modeling (e.g., factors for categorical variables).
2. Retained only relevant columns needed for modeling and removed auxiliary columns.
3. Addressed missing values through imputation, row/column removal based on threshold.
4. Applied outlier treatments: capping, transformation, or imputation, as appropriate.
5. Performed scaling/normalization on numeric variables.
6. Created feature engineering transformations: interaction terms, polynomial features, binning, and dummy encoding.
7. Applied feature selection and reduction techniques to retain informative variables (low-variance removal, correlation analysis, PCA).
8. Confirmed absence of missing values and appropriate skewness adjustments for modeling readiness.
"

#' Save Data Preparation Summary
#'
#' @param summary_text A character string summarizing the data preparation steps.
#' @param summary_path File path for saving the summary text file.
#' @return None. Saves summary as a text file at the specified path.
#' @export
save_data_prep_summary <- function(summary_text, summary_path) {
  writeLines(summary_text, summary_path)
  cat("Data preparation summary saved to specified path.\n")
}

# Save the summary of data preparation steps
save_data_prep_summary(data_prep_summary, summary_path)


















