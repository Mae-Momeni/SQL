
### **EDA Cheat Sheet**

#### **1. Initial Data Overview**
- **Purpose**: Understand dataset structure, check for missing values, view variable types, and get basic statistics.

```r
library(tidyverse)

# Display structure and types
glimpse(data)

# Check dimensions
cat("Data dimensions:\n")
print(dim(data))

# Get data types and summary stats
data_summary <- data %>%
  summarise(across(everything(), list(class = ~ class(.), n_missing = ~ sum(is.na(.)))))
print(data_summary)
```

---

#### **2. Missing Data Analysis**
- **Purpose**: Identify and visualize missing data patterns and decide on treatment.

```r
library(naniar)

# Count and percentage of missing values per column
missing_summary <- data %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "missing_count") %>%
  mutate(missing_percentage = (missing_count / nrow(data)) * 100)
print(missing_summary)

# Visualize missing data heatmap
vis_miss(data)

# Rows with excessive missing data (>50% missing)
high_missing_rows <- data %>%
  mutate(missing_count = rowSums(is.na(.))) %>%
  filter(missing_count > (0.5 * ncol(data)))
print(high_missing_rows)
```

---

#### **3. Duplicate Rows Check**
- **Purpose**: Identify and optionally remove duplicated rows.

```r
# Check for duplicate rows
duplicate_rows <- data %>% filter(duplicated(.))
cat("Number of duplicate rows:\n")
print(nrow(duplicate_rows))
print(duplicate_rows)
```

---

#### **4. Summary Statistics for Numeric Variables**
- **Purpose**: View basic statistics (mean, median, SD) and distribution shape (skewness, kurtosis).

```r
library(e1071)

# Summary statistics
numeric_summary <- data %>%
  select(where(is.numeric)) %>%
  summarise(across(everything(), list(
    mean = ~ mean(.x, na.rm = TRUE),
    median = ~ median(.x, na.rm = TRUE),
    sd = ~ sd(.x, na.rm = TRUE),
    min = ~ min(.x, na.rm = TRUE),
    max = ~ max(.x, na.rm = TRUE),
    skewness = ~ skewness(.x, na.rm = TRUE),
    kurtosis = ~ kurtosis(.x, na.rm = TRUE)
  )))
print(numeric_summary)
```

---

#### **5. Distributional Analysis for Numeric Variables**
- **Purpose**: Check variable distribution and normality.

```r
# Histograms and density plots
data %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(x = value)) +
  geom_histogram(aes(y = ..density..), bins = 30, fill = "skyblue", color = "black", alpha = 0.6) +
  geom_density(color = "red", size = 1) +
  facet_wrap(~ variable, scales = "free") +
  labs(title = "Histograms and Density Plots", x = "Value", y = "Density")

# QQ Plot for normality
data %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(sample = value)) +
  stat_qq() +
  stat_qq_line(color = "red") +
  facet_wrap(~ variable, scales = "free") +
  labs(title = "QQ Plots", x = "Theoretical Quantiles", y = "Sample Quantiles")
```

---

#### **6. Categorical Variables: Frequency Counts & Visualization**
- **Purpose**: Check for low-frequency levels or potential data quality issues.

```r
# Frequency counts for categorical variables
categorical_summary <- data %>%
  select(where(is.factor)) %>%
  summarise(across(everything(), ~ n_distinct(.x)))
print(categorical_summary)

# Bar plots for categorical variables
data %>%
  select(where(is.factor)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(x = value)) +
  geom_bar(fill = "skyblue") +
  facet_wrap(~ variable, scales = "free") +
  labs(title = "Bar Plots for Categorical Variables", x = "Category", y = "Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

---

#### **7. Outlier Detection in Numeric Variables**
- **Purpose**: Identify and assess the impact of outliers.

```r
# Boxplot to identify potential outliers
data %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(x = variable, y = value)) +
  geom_boxplot(outlier.color = "red") +
  labs(title = "Boxplots for Outlier Detection", x = "Variable", y = "Value") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Calculate Z-scores to detect extreme outliers
z_scores <- data %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  mutate(z_score = (value - mean(value, na.rm = TRUE)) / sd(value, na.rm = TRUE)) %>%
  filter(abs(z_score) > 3)
print(z_scores)
```

---

#### **8. Correlation Analysis for Numeric Variables**
- **Purpose**: Identify relationships between numeric variables.

```r
# Correlation matrix
cor_matrix <- data %>%
  select(where(is.numeric)) %>%
  cor(use = "complete.obs")
print(cor_matrix)

# Visualize correlation heatmap
library(corrplot)
corrplot(cor_matrix, method = "color", type = "lower", title = "Correlation Matrix")
```

---

#### **9. Relationship Analysis Between Variables**
- **Purpose**: Explore relationships between categorical and numeric variables.

```r
# Boxplot of categorical vs numeric variable
data %>%
  pivot_longer(cols = where(is.numeric), names_to = "numeric_variable", values_to = "value") %>%
  ggplot(aes(x = categorical_variable, y = value, fill = categorical_variable)) + # Replace with variable name
  geom_boxplot() +
  facet_wrap(~ numeric_variable, scales = "free") +
  labs(title = "Boxplots of Categorical vs Numeric Variables", x = "Category", y = "Value")

# Scatter plot for pairs of numeric variables
key_vars <- c("variable1", "variable2") # Specify variables
data %>%
  select(all_of(key_vars)) %>%
  GGally::ggpairs(title = "Pair Plot of Key Variables")
```

