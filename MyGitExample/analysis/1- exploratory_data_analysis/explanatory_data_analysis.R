
# instruction:
# transform the code into a more advanced style, leveraging pipes (%>%), mutate, summarize,
# and other tidyverse techniques. Make sure the code is modular and efficient. Take best R coding
# practices for data science and ML projects to make the code readable, modular, and scalable.
# Write function when tasks are repetitive, complex, or require flexibility, improving readability, reusability, and consistency. Avoid functions for one-off code, simple transformations, or linear workflows, as they may add unnecessary complexity.
# if writing function, use Roxygen2-style comments to make the functions readable and modular.


# Read data ---------------------------------------------------------------




# 1. Initial Data Overview ------------------------------------------------

# Load necessary libraries
library(tidyverse)

# Assume 'data' is your dataset

#' Display Structure of the Dataset
#'
#' Provides an overview of column types and sample values using glimpse.
#'
#' @param data A data frame to display structure for.
#' @return None. Prints the data structure to the console.
#' @export
display_structure <- function(data) {
  cat("Data Structure (Using glimpse):\n")
  glimpse(data)
}

# Display data structure
display_structure(data)

#' Get Data Dimensions
#'
#' Computes and displays the number of rows and columns in the dataset.
#'
#' @param data A data frame to compute dimensions for.
#' @return A tibble with the number of rows and columns.
#' @export
get_data_dimensions <- function(data) {
  tibble(
    rows = nrow(data),
    columns = ncol(data)
  )
}

# Display data dimensions
cat("\nData Dimensions:\n")
print(get_data_dimensions(data))

#' List Column Names and Data Types
#'
#' Summarizes column names and data types in the dataset.
#'
#' @param data A data frame to summarize column names and types.
#' @return A tibble with column names and data types.
#' @export
list_column_types <- function(data) {
  data %>%
    summarise(across(everything(), ~ class(.x)[1])) %>%
    pivot_longer(everything(), names_to = "column_name", values_to = "data_type")
}

# Display column names and data types
cat("\nColumn Names and Data Types:\n")
print(list_column_types(data))

#' Summary Statistics for Numeric Variables
#'
#' Computes summary statistics (mean, median, sd, min, max) for numeric variables.
#'
#' @param data A data frame with numeric variables.
#' @return A tibble with summary statistics for each numeric variable.
#' @export
numeric_summary_stats <- function(data) {
  data %>%
    select(where(is.numeric)) %>%
    summarise(across(everything(), list(
      mean = ~ mean(.x, na.rm = TRUE),
      median = ~ median(.x, na.rm = TRUE),
      sd = ~ sd(.x, na.rm = TRUE),
      min = ~ min(.x, na.rm = TRUE),
      max = ~ max(.x, na.rm = TRUE)
    )))
}

# Display summary statistics for numeric variables
cat("\nSummary Statistics for Numeric Variables:\n")
print(numeric_summary_stats(data))

#' Frequency Counts for Categorical Variables
#'
#' Generates frequency counts for each categorical variable.
#'
#' @param data A data frame with categorical variables.
#' @return A list of tables with frequency counts for each categorical variable.
#' @export
categorical_frequency_counts <- function(data) {
  data %>%
    select(where(is.factor)) %>%
    map(~ table(.))
}

# Display frequency counts for categorical variables
cat("\nFrequency Counts for Categorical Variables:\n")
print(categorical_frequency_counts(data))



# 2. Missing Data Analysis ------------------------------------------------

# Load necessary libraries
library(tidyverse)
library(naniar)      # For missing data visualizations
library(UpSetR)      # For visualizing combinations of missing values with upset plots

# Assume 'data' is your dataset

#' Count Missing Values per Column
#'
#' @param data A data frame to analyze for missing values.
#' @return A tibble with column names, missing counts, and missing percentages.
#' @export
count_missing_values <- function(data) {
  data %>%
    summarise(across(everything(), ~ sum(is.na(.)))) %>%
    pivot_longer(everything(), names_to = "column_name", values_to = "missing_count") %>%
    mutate(missing_percentage = (missing_count / nrow(data)) * 100)
}

# Display missing values summary
cat("Missing Values per Column:\n")
missing_summary <- count_missing_values(data)
print(missing_summary)

# 2. Visualize Missing Data Patterns (one-off visualizations, no function needed)
cat("\nVisualizing Missing Data Patterns:\n")

# Heatmap of missing data
naniar::vis_miss(data)  # Heatmap-style visualization of missing values per column

# Bar plot showing percentage of missing values per column
missing_summary %>%
  ggplot(aes(x = reorder(column_name, -missing_percentage), y = missing_percentage)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  coord_flip() +
  labs(title = "Percentage of Missing Values by Column", x = "Column", y = "Percentage of Missing Values")

#' Identify Combinations of Missing Values Across Columns
#'
#' @param data A data frame to analyze for missing value combinations.
#' @param missing_summary A tibble with column names and missing counts.
#' @return A plot of missing value combinations across columns.
#' @export
visualize_missing_combinations <- function(data, missing_summary) {
  missing_cols <- missing_summary %>%
    filter(missing_count > 0) %>%
    pull(column_name)

  upset(data[missing_cols], nsets = length(missing_cols), order.by = "freq")
}

# Display combinations of missing values
cat("\nCombinations of Missing Values Across Columns:\n")
visualize_missing_combinations(data, missing_summary)

#' Check Rows with Excessive Missing Values
#'
#' @param data A data frame to analyze for rows with excessive missing values.
#' @param threshold Numeric, threshold for missing values (default is 50%).
#' @return A tibble with rows containing missing counts exceeding the threshold.
#' @export
check_excessive_missing_rows <- function(data, threshold = 0.5 * ncol(data)) {
  data %>%
    mutate(missing_count = rowSums(is.na(.))) %>%
    filter(missing_count > threshold) %>%
    select(missing_count)
}

# Display rows with excessive missing values
cat("\nRows with Excessive Missing Values:\n")
rows_excessive_missing <- check_excessive_missing_rows(data)
print(rows_excessive_missing)



# 3. Univariate Analysis --------------------------------------------------

# Load necessary libraries
library(tidyverse)
library(ggplot2)
library(e1071)  # For skewness and kurtosis calculations

# Assume 'data' is your dataset

# 1. Univariate Analysis for Numeric Variables
cat("Univariate Analysis for Numeric Variables:\n")

#' Summary Statistics for Numeric Variables
#'
#' @param data A data frame with numeric variables.
#' @return A tibble with summary statistics for numeric variables, including mean, median, sd, min, max, skewness, and kurtosis.
#' @export
numeric_summary <- function(data) {
  data %>%
    select(where(is.numeric)) %>%
    summarise(across(everything(), list(
      mean = ~ mean(.x, na.rm = TRUE),
      median = ~ median(.x, na.rm = TRUE),
      sd = ~ sd(.x, na.rm = TRUE),
      min = ~ min(.x, na.rm = TRUE),
      max = ~ max(.x, na.rm = TRUE),
      skewness = ~ e1071::skewness(.x, na.rm = TRUE),
      kurtosis = ~ e1071::kurtosis(.x, na.rm = TRUE)
    )))
}

# Display numeric summary statistics
print(numeric_summary(data))

# Histograms and density plots for numeric variables (one-off visualization, no function needed)
cat("\nHistograms and Density Plots for Numeric Variables:\n")
data %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(x = value)) +
  geom_histogram(aes(y = ..density..), bins = 30, fill = "skyblue", color = "black", alpha = 0.6) +
  geom_density(color = "red", size = 1) +
  facet_wrap(~ variable, scales = "free") +
  labs(title = "Histograms and Density Plots of Numeric Variables", x = "Value", y = "Density")

#' Identify Outliers Using the IQR Method
#'
#' @param data A data frame with numeric variables.
#' @return A tibble identifying outliers based on the IQR method.
#' @export
identify_outliers <- function(data) {
  data %>%
    select(where(is.numeric)) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
    group_by(variable) %>%
    mutate(
      Q1 = quantile(value, 0.25, na.rm = TRUE),
      Q3 = quantile(value, 0.75, na.rm = TRUE),
      IQR = Q3 - Q1,
      lower_bound = Q1 - 1.5 * IQR,
      upper_bound = Q3 + 1.5 * IQR,
      is_outlier = value < lower_bound | value > upper_bound
    ) %>%
    filter(is_outlier) %>%
    select(variable, value, is_outlier)
}

# Display identified outliers
print(identify_outliers(data))

# 2. Univariate Analysis for Categorical Variables
cat("\nUnivariate Analysis for Categorical Variables:\n")

# Frequency counts for categorical variables (simple operation, no function needed)
categorical_counts <- data %>%
  select(where(is.factor)) %>%
  map(~ table(.))  # Generate frequency counts for each categorical variable
print(categorical_counts)

# Bar plots for categorical variables (one-off visualization, no function needed)
cat("\nBar Plots for Categorical Variables:\n")
data %>%
  select(where(is.factor)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(x = value)) +
  geom_bar(fill = "skyblue", color = "black") +
  facet_wrap(~ variable, scales = "free") +
  labs(title = "Bar Plots of Categorical Variables", x = "Category", y = "Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#' Identify Low-Frequency Categories
#'
#' @param data A data frame with categorical variables.
#' @param threshold A numeric value representing the minimum count threshold.
#' @return A tibble with low-frequency categories below the threshold.
#' @export
identify_low_freq_categories <- function(data, threshold = 0.05 * nrow(data)) {
  data %>%
    select(where(is.factor)) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
    group_by(variable, value) %>%
    summarise(count = n(), .groups = "drop") %>%
    mutate(percentage = (count / nrow(data)) * 100) %>%
    filter(count < threshold)
}

# Display low-frequency categories
print(identify_low_freq_categories(data))



# 4. Bivariate Analysis ---------------------------------------------------

# Load necessary libraries
library(tidyverse)
library(ggplot2)
library(corrplot)   # For correlation plots

# Assume 'data' is your dataset

#' Create and Print Correlation Matrix for Numeric Variables
#'
#' @param data A data frame containing numeric variables.
#' @return A correlation matrix of numeric variables.
#' @export
correlation_matrix <- function(data) {
  numeric_data <- data %>% select(where(is.numeric))
  cor(numeric_data, use = "complete.obs")
}

# Display and visualize the correlation matrix
cat("Correlation Matrix for Numeric Variables:\n")
cor_matrix <- correlation_matrix(data)
print(cor_matrix)

# Correlation matrix heatmap (one-off visualization)
cat("\nCorrelation Matrix Heatmap:\n")
corrplot(cor_matrix, method = "color", type = "lower", tl.cex = 0.8, tl.col = "black",
         title = "Correlation Matrix of Numeric Variables")

#' Scatter Plots for Pairs of Key Numeric Variables
#'
#' @param data A data frame containing numeric variables.
#' @param variables A character vector of key numeric variables for scatter plots.
#' @return A ggplot object of scatter plots for each pair of key numeric variables.
#' @export
scatter_plots <- function(data, variables) {
  data %>%
    select(all_of(variables)) %>%
    pivot_longer(everything(), names_to = "variable1", values_to = "value1") %>%
    ggplot(aes(x = value1)) +
    facet_wrap(~ variable1, scales = "free") +
    labs(title = "Scatter Plots for Key Numeric Variables")
}

# Replace `key_numeric_vars` with relevant variable names
key_numeric_vars <- c("variable1", "variable2", "variable3")  # Example placeholders
cat("\nScatter Plots for Pairs of Key Numeric Variables:\n")
print(scatter_plots(data, key_numeric_vars))

# Boxplots of Categorical vs. Numeric Variables (one-off visualization)
cat("\nBoxplots for Categorical vs. Numeric Variables:\n")
data %>%
  pivot_longer(cols = where(is.numeric), names_to = "numeric_variable", values_to = "numeric_value") %>%
  ggplot(aes(x = categorical_variable, y = numeric_value, fill = categorical_variable)) +  # Replace `categorical_variable`
  geom_boxplot() +
  facet_wrap(~ numeric_variable, scales = "free") +
  labs(title = "Boxplots of Categorical vs. Numeric Variables", x = "Category", y = "Numeric Value") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#' Generate Contingency Tables for Pairs of Categorical Variables
#'
#' @param data A data frame containing categorical variables.
#' @return A list of contingency tables for each pair of categorical variables.
#' @export
contingency_tables <- function(data) {
  categorical_pairs <- combn(data %>% select(where(is.factor)), 2, simplify = FALSE)
  map(categorical_pairs, ~ table(.x[[1]], .x[[2]]))
}

# Display contingency tables for categorical pairs
cat("\nContingency Tables for Pairs of Categorical Variables:\n")
print(contingency_tables(data))

# Stacked Bar Chart of Categorical Variables (one-off visualization)
cat("\nStacked Bar Charts for Categorical vs. Categorical Variables:\n")
data %>%
  ggplot(aes(x = category1, fill = category2)) +  # Replace with relevant variable names
  geom_bar(position = "fill") +
  labs(title = "Stacked Bar Chart of Categorical Variables", x = "Category 1", y = "Proportion", fill = "Category 2") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



# 5. Multivariate Analysis ------------------------------------------------

# Load necessary libraries
library(tidyverse)
library(GGally)       # For pair plots
library(car)          # For VIF calculation

# Assume 'data' is your dataset

#' Create Pair Plots for Key Numeric Variables
#'
#' @param data A data frame with numeric variables.
#' @param variables A character vector of key numeric variables.
#' @return A ggpairs plot showing relationships between pairs of numeric variables.
#' @export
create_pair_plots <- function(data, variables) {
  data %>%
    select(all_of(variables)) %>%
    GGally::ggpairs(title = "Pair Plot of Key Numeric Variables")
}

# Specify key numeric variables for pair plots (replace with actual variable names)
key_numeric_vars <- c("variable1", "variable2", "variable3")
cat("Pair Plots for Key Variables:\n")
create_pair_plots(data, key_numeric_vars)

# Faceted Plots for Conditional Distributions (one-off visualization)
cat("\nFaceted Histograms by Category:\n")
data %>%
  select(where(is.numeric), category_variable) %>%  # Add categorical variable to dataset
  pivot_longer(cols = where(is.numeric), names_to = "numeric_variable", values_to = "value") %>%
  ggplot(aes(x = value)) +
  geom_histogram(bins = 30, fill = "skyblue", color = "black") +
  facet_wrap(~ numeric_variable + category_variable, scales = "free") +
  labs(title = "Faceted Histograms by Category", x = "Value", y = "Frequency")

cat("\nFaceted Density Plots by Category:\n")
data %>%
  select(where(is.numeric), category_variable) %>%  # Add categorical variable to dataset
  pivot_longer(cols = where(is.numeric), names_to = "numeric_variable", values_to = "value") %>%
  ggplot(aes(x = value, color = category_variable)) +
  geom_density() +
  facet_wrap(~ numeric_variable, scales = "free") +
  labs(title = "Density Plots by Category", x = "Value", y = "Density") +
  theme(legend.position = "bottom")

#' Calculate Variance Inflation Factor (VIF) for Multicollinearity Assessment
#'
#' @param data A data frame with numeric predictors.
#' @return A named vector of VIF values for each numeric predictor.
#' @export
calculate_vif <- function(data) {
  numeric_data <- data %>%
    select(where(is.numeric)) %>%
    drop_na()

  vif_model <- lm(numeric_data[, 1] ~ ., data = numeric_data)  # Temporarily using first column as target
  car::vif(vif_model)
}

# Display VIF for numeric predictors
cat("\nVariance Inflation Factor (VIF) for Numeric Predictors:\n")
print(calculate_vif(data))

#' Create Interaction Terms Between Numeric and Categorical Variables
#'
#' @param data A data frame with variables to create interactions.
#' @param numeric_vars A character vector of numeric variables.
#' @param category_var A categorical variable to interact with numeric variables.
#' @return A data frame with interaction terms added as new columns.
#' @export
create_interaction_terms <- function(data, numeric_vars, category_var) {
  data %>%
    mutate(across(all_of(numeric_vars), ~ . * as.numeric(data[[category_var]]), .names = "{.col}_interaction"))
}

# Create and visualize interaction terms (replace placeholders with actual variable names)
cat("\nExploring Interactions and Higher-Order Effects:\n")
interaction_data <- create_interaction_terms(data, key_numeric_vars, "category_variable")

interaction_data %>%
  select(ends_with("_interaction")) %>%
  pivot_longer(everything(), names_to = "interaction_term", values_to = "value") %>%
  ggplot(aes(x = value)) +
  geom_histogram(bins = 30, fill = "skyblue", color = "black") +
  facet_wrap(~ interaction_term, scales = "free") +
  labs(title = "Distribution of Interaction Terms", x = "Value", y = "Frequency")


# 6. Outlier Detection and Analysis ---------------------------------------

# Load necessary libraries
library(tidyverse)

# Assume 'data' is your dataset

#' Create Boxplots for Outlier Detection
#'
#' @param data A data frame with numeric variables.
#' @return A ggplot object showing boxplots for each numeric variable to detect outliers.
#' @export
create_boxplots <- function(data) {
  data %>%
    select(where(is.numeric)) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
    ggplot(aes(x = variable, y = value)) +
    geom_boxplot(outlier.color = "red", outlier.shape = 1) +
    labs(title = "Boxplots for Outlier Detection", x = "Variable", y = "Value") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

# Display boxplots for outlier detection
cat("Boxplots for Outlier Detection in Numeric Variables:\n")
print(create_boxplots(data))

#' Calculate Z-scores for Outlier Detection
#'
#' @param data A data frame with numeric variables.
#' @return A tibble with Z-scores and an indicator for extreme outliers (beyond +/- 3 SD).
#' @export
calculate_z_scores <- function(data) {
  data %>%
    select(where(is.numeric)) %>%
    mutate(across(everything(), ~ (. - mean(.)) / sd(.), .names = "z_{.col}")) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "z_score") %>%
    mutate(is_outlier = abs(z_score) > 3) %>%
    filter(is_outlier)
}

# Display Z-scores for outlier detection
cat("\nZ-scores for Outlier Detection:\n")
z_scores <- calculate_z_scores(data)
print(z_scores)

# Visualize Outliers Within Variable Distributions (one-off visualization)
cat("\nVisualizing Outliers Within Variable Distributions:\n")
data %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(x = value)) +
  geom_histogram(bins = 30, fill = "skyblue", color = "black", alpha = 0.7) +
  geom_vline(data = z_scores, aes(xintercept = z_score, color = variable), linetype = "dashed", size = 0.5) +
  facet_wrap(~ variable, scales = "free") +
  labs(title = "Distribution of Numeric Variables with Outliers Highlighted", x = "Value", y = "Frequency") +
  theme(legend.position = "none")



# 7. Distributional Analysis ----------------------------------------------

# Load necessary libraries
library(tidyverse)
library(ggplot2)
library(car)    # For Box-Cox transformations
library(e1071)  # For skewness calculation

# Assume 'data' is your dataset

#' Perform Shapiro-Wilk Normality Test for Each Numeric Variable
#'
#' @param data A data frame with numeric variables.
#' @return A tibble with variable names and p-values from the Shapiro-Wilk test.
#' @export
normality_test <- function(data) {
  data %>%
    select(where(is.numeric)) %>%
    map(~ shapiro.test(.x)$p.value) %>%
    enframe(name = "variable", value = "shapiro_p_value")
}

# Display results of Shapiro-Wilk normality tests
cat("Normality Check for Numeric Variables:\n")
normality_tests <- normality_test(data)
print(normality_tests)

# QQ Plots for Normality Assessment (one-off visualization)
cat("\nQQ Plots for Numeric Variables:\n")
data %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(sample = value)) +
  stat_qq() +
  stat_qq_line(color = "red") +
  facet_wrap(~ variable, scales = "free") +
  labs(title = "QQ Plots for Numeric Variables", x = "Theoretical Quantiles", y = "Sample Quantiles")

#' Identify Skewed Variables Based on Skewness Threshold
#'
#' @param data A data frame with numeric variables.
#' @param threshold Numeric, threshold for skewness indicating significant skew (default: 1).
#' @return A tibble with variable names and skewness values above the threshold.
#' @export
identify_skewed_vars <- function(data, threshold = 1) {
  data %>%
    select(where(is.numeric)) %>%
    summarise(across(everything(), ~ e1071::skewness(.x, na.rm = TRUE))) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "skewness") %>%
    filter(abs(skewness) > threshold)
}

# Display skewed variables
cat("\nChecking Skewness for Numeric Variables:\n")
skewed_vars <- identify_skewed_vars(data)
print(skewed_vars)

#' Apply Log and Square Root Transformations to Skewed Variables
#'
#' @param data A data frame with numeric variables.
#' @param skewed_vars A character vector of skewed variable names to transform.
#' @return A data frame with log and square root transformed variables.
#' @export
apply_transformations <- function(data, skewed_vars) {
  data %>%
    mutate(across(all_of(skewed_vars), ~ ifelse(min(.x) > 0, log(.x), .), .names = "{.col}_log")) %>%
    mutate(across(all_of(skewed_vars), ~ sqrt(.x), .names = "{.col}_sqrt"))
}

# Apply transformations to skewed variables
transformed_data <- apply_transformations(data, skewed_vars$variable)

# Compare original and transformed distributions (one-off visualization)
cat("\nHistograms of Original and Transformed Variables:\n")
transformed_data %>%
  select(ends_with("_log"), ends_with("_sqrt")) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(x = value)) +
  geom_histogram(bins = 30, fill = "skyblue", color = "black") +
  facet_wrap(~ variable, scales = "free") +
  labs(title = "Histograms of Transformed Variables", x = "Value", y = "Frequency")



# 8. Target Variable Analysis  --------------------------------------------

# Load necessary libraries
library(tidyverse)
library(ggplot2)

# Assume 'data' is your dataset, and 'target' is your target variable

#' Plot the Distribution of the Target Variable
#'
#' @param data A data frame containing the target variable.
#' @param target The target variable to plot.
#' @return A ggplot object showing the distribution of the target variable.
#' @export
plot_target_distribution <- function(data, target) {
  if (is.numeric(data[[target]])) {
    ggplot(data, aes(x = .data[[target]])) +
      geom_histogram(bins = 30, fill = "skyblue", color = "black") +
      labs(title = "Distribution of Continuous Target Variable", x = "Target Value", y = "Frequency")
  } else {
    ggplot(data, aes(x = .data[[target]])) +
      geom_bar(fill = "skyblue", color = "black") +
      labs(title = "Distribution of Categorical Target Variable", x = "Target Category", y = "Count")
  }
}

# Display target distribution plot
cat("Distribution of the Target Variable:\n")
print(plot_target_distribution(data, "target"))

#' Examine Relationship Between Target Variable and Key Predictors
#'
#' @param data A data frame containing the target and predictor variables.
#' @param target The target variable.
#' @param predictors A character vector of predictor variables to analyze.
#' @return A ggplot object showing the relationship between the target and predictors.
#' @export
examine_target_relationships <- function(data, target, predictors) {
  if (is.numeric(data[[target]])) {
    data %>%
      pivot_longer(cols = all_of(predictors), names_to = "predictor", values_to = "value") %>%
      ggplot(aes(x = value, y = .data[[target]])) +
      geom_point(alpha = 0.5, color = "skyblue") +
      facet_wrap(~ predictor, scales = "free_x") +
      labs(title = "Relationship Between Continuous Target and Numeric Predictors", x = "Predictor Value", y = "Target Value")
  } else {
    data %>%
      pivot_longer(cols = all_of(predictors), names_to = "predictor", values_to = "value") %>%
      ggplot(aes(x = .data[[target]], y = value, fill = .data[[target]])) +
      geom_boxplot() +
      facet_wrap(~ predictor, scales = "free_y") +
      labs(title = "Relationship Between Categorical Target and Numeric Predictors", x = "Target Category", y = "Predictor Value")
  }
}

# Display relationship between target and key predictors
cat("\nRelationship Between Target Variable and Key Predictors:\n")
print(examine_target_relationships(data, "target", c("predictor1", "predictor2", "predictor3")))

#' Generate Summary Statistics for the Target Variable by Group
#'
#' @param data A data frame containing the target and group variables.
#' @param target The target variable.
#' @param group_var A categorical variable for grouping.
#' @return A tibble with summary statistics or frequency counts by group.
#' @export
generate_target_summary_by_group <- function(data, target, group_var) {
  if (is.numeric(data[[target]])) {
    data %>%
      group_by(!!sym(group_var)) %>%
      summarise(
        mean = mean(.data[[target]], na.rm = TRUE),
        median = median(.data[[target]], na.rm = TRUE),
        sd = sd(.data[[target]], na.rm = TRUE),
        min = min(.data[[target]], na.rm = TRUE),
        max = max(.data[[target]], na.rm = TRUE)
      )
  } else {
    data %>%
      group_by(!!sym(group_var), .data[[target]]) %>%
      summarise(count = n(), .groups = "drop") %>%
      mutate(percentage = (count / sum(count)) * 100)
  }
}

# Display summary statistics or frequency counts by group
cat("\nSummary Statistics of Target Variable by Groups:\n")
summary_by_group <- generate_target_summary_by_group(data, "target", "grouping_variable")
print(summary_by_group)

# Bar plot for categorical target variable by groups (one-off visualization)
if (!is.numeric(data$target)) {
  ggplot(summary_by_group, aes(x = !!sym("grouping_variable"), y = count, fill = .data[["target"]])) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(title = "Distribution of Categorical Target Variable by Group", x = "Group", y = "Count")
}



# 9. Feature Engineering Exploration --------------------------------------

# Load necessary libraries
library(tidyverse)
library(caret)  # For dummy encoding, scaling, and polynomial features

# Assume 'data' is your dataset

#' Generate Interaction Terms for Specified Variables
#'
#' @param data A data frame with numeric variables.
#' @param variables A character vector of variable names to generate interaction terms.
#' @return A data frame with the original data and interaction terms.
#' @export
generate_interaction_terms <- function(data, variables) {
  interactions <- data %>%
    select(all_of(variables)) %>%
    mutate(across(everything(), as.numeric)) %>%  # Ensure numeric format for interaction
    model.matrix(~ .^2, data = .) %>%
    as_tibble() %>%
    select(-1)  # Remove intercept column

  bind_cols(data, interactions)
}

# Generate interaction terms and combine with original data
cat("Exploring Interaction Terms:\n")
data_with_interactions <- generate_interaction_terms(data, c("variable1", "variable2", "variable3"))

#' Generate Polynomial Features for Numeric Variables
#'
#' @param data A data frame with numeric variables.
#' @param variables A character vector of numeric variable names to apply polynomial transformations.
#' @param degree Integer, degree of the polynomial transformation (default is 2).
#' @return A data frame with polynomial features added.
#' @export
generate_polynomial_features <- function(data, variables, degree = 2) {
  data %>%
    select(all_of(variables)) %>%
    mutate(across(everything(), ~ poly(.x, degree = degree, raw = TRUE), .names = "{.col}_poly{degree}")) %>%
    bind_cols(data, .)
}

# Generate polynomial features and combine with original data
cat("\nExploring Polynomial Features:\n")
data_with_polynomials <- generate_polynomial_features(data, c("variable1", "variable2", "variable3"))

#' Dummy Encode Categorical Variables
#'
#' @param data A data frame containing categorical variables.
#' @return A data frame with dummy-encoded variables.
#' @export
dummy_encode <- function(data) {
  dummy_model <- dummyVars(~ ., data = data, fullRank = TRUE)
  predict(dummy_model, newdata = data) %>%
    as_tibble()
}

# Apply dummy encoding to categorical variables
cat("\nDummy Encoding Categorical Variables:\n")
data_encoded <- dummy_encode(data)

#' Scale Numeric Variables
#'
#' @param data A data frame with numeric variables.
#' @return A data frame with scaled numeric variables.
#' @export
scale_numeric_vars <- function(data) {
  data %>%
    mutate(across(where(is.numeric), scale))
}

# Apply standard scaling to numeric variables
cat("\nScaling and Normalization of Numeric Variables:\n")
data_scaled <- scale_numeric_vars(data)

#' Normalize Numeric Variables to [0, 1] Range
#'
#' @param data A data frame with numeric variables.
#' @return A data frame with normalized numeric variables.
#' @export
normalize_numeric_vars <- function(data) {
  data %>%
    mutate(across(where(is.numeric), ~ (. - min(.)) / (max(.) - min(.))))
}

# Apply normalization to numeric variables
data_normalized <- normalize_numeric_vars(data)

# Binning of Continuous Variables (example inline transformations)
cat("\nBinning Continuous Variables:\n")

# Example: Binning 'age' into categories
data_binned <- data %>%
  mutate(age_group = case_when(
    age < 25 ~ "Under 25",
    age >= 25 & age < 45 ~ "25-44",
    age >= 45 & age < 65 ~ "45-64",
    age >= 65 ~ "65+"
  ))

# Example: Binning 'income' into quantile-based buckets
data_binned <- data_binned %>%
  mutate(income_group = ntile(income, 4))  # Creates quartiles for 'income'

print(data_binned %>% select(age_group, income_group))



# 10. Data Quality Checks -------------------------------------------------

# Load necessary libraries
library(tidyverse)
library(lubridate)

# Assume 'data' is your dataset

#' Check Unique Values per Column
#'
#' @param data A data frame.
#' @return A list with columns having a single unique value and columns with high cardinality.
#' @export
check_unique_values <- function(data) {
  unique_values <- data %>%
    summarise(across(everything(), n_distinct)) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "unique_count")

  list(
    single_value_vars = unique_values %>% filter(unique_count == 1),
    high_cardinality_vars = unique_values %>% filter(unique_count > 0.9 * nrow(data))
  )
}

# Display unique values per column
cat("Unique Values per Column:\n")
unique_values_check <- check_unique_values(data)
print("Columns with a Single Unique Value:")
print(unique_values_check$single_value_vars)
print("Columns with High Cardinality (90% or more unique values):")
print(unique_values_check$high_cardinality_vars)

#' Detect Near-Constant Variables Based on Coefficient of Variation
#'
#' @param data A data frame with numeric variables.
#' @return A tibble with near-constant variables and their coefficients of variation.
#' @export
detect_near_constant_vars <- function(data) {
  data %>%
    select(where(is.numeric)) %>%
    summarise(across(everything(), ~ sd(.x, na.rm = TRUE) / mean(.x, na.rm = TRUE), .names = "cv_{.col}")) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "coefficient_of_variation") %>%
    filter(coefficient_of_variation < 0.01 | is.na(coefficient_of_variation))
}

# Display near-constant variables
cat("\nConstant or Near-Constant Variables:\n")
near_constant_vars <- detect_near_constant_vars(data)
print(near_constant_vars)

#' Identify Duplicate Rows in Dataset
#'
#' @param data A data frame.
#' @return A data frame containing duplicate rows.
#' @export
identify_duplicate_rows <- function(data) {
  data %>%
    filter(duplicated(.))
}

# Display duplicate rows
cat("\nDuplicate Rows:\n")
duplicate_rows <- identify_duplicate_rows(data)
print(paste("Number of duplicate rows:", nrow(duplicate_rows)))
print(duplicate_rows)

# Inconsistent or Erroneous Values (inline checks)
cat("\nInconsistent or Erroneous Values:\n")

# Check for negative values where they don’t make sense
negative_values <- data %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  filter(value < 0)

print("Variables with Negative Values (if not expected):")
print(negative_values)

# Detect dates outside expected ranges (inline check)
start_date <- ymd("2000-01-01")
end_date <- ymd("2023-01-01")

if ("date" %in% names(data)) {
  date_out_of_range <- data %>%
    select(date) %>%
    filter(date < start_date | date > end_date)

  print("Dates Outside Expected Range:")
  print(date_out_of_range)
}

#' Check Date Consistency for Sequential Order in Time Series
#'
#' @param data A data frame with a date column.
#' @return A data frame indicating non-sequential dates for time series consistency.
#' @export
check_date_consistency <- function(data) {
  if ("date" %in% names(data)) {
    data %>%
      arrange(date) %>%
      mutate(is_sequential = date == lag(date, default = first(date)) + days(1)) %>%
      filter(is_sequential == FALSE)
  } else {
    tibble()
  }
}

# Display non-sequential dates for consistency check
cat("\nDate and Time Consistency Check:\n")
date_consistency <- check_date_consistency(data)
print("Non-Sequential Dates Detected (for time series consistency):")
print(date_consistency)




# 11. Automated EDA Report ------------------------------------------------

# Load the DataExplorer library
library(DataExplorer)

# Assume 'data' is your dataset

# Create an automated EDA report
create_report(data,
              output_file = "EDA_Report.html",  # Name of the output file
              output_dir = getwd(),             # Directory for saving the report
              y = "target_variable"             # Optional: Specify target variable if applicable
)

# This will generate an HTML report with sections for all the sections above.




