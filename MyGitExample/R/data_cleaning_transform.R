# Functions for data exploration, cleaning, reshaping, preparation, and validation.
# all data treatments, from prep to FE, correlation, and feature selection
# functions with Roxygen2-style documentation


#' Find Conversion Rate
#'
#' @description Calculates the total count, sum, and conversion rate (percentage) of a list of numeric values.
#'
#' @param lst A numeric vector representing conversions (e.g., 1 for success and 0 for failure).
#'
#' @return A tibble with three columns:
#' \item{total_count}{The total number of entries in the list.}
#' \item{conversion_sum}{The sum of the values in the list, rounded to the nearest whole number.}
#' \item{conversion_rate}{The conversion rate as a percentage, rounded to two decimal places.}
#'
#' @examples
#' lst <- c(0, 1, 1, 0, 1)
#' find_conversion_rate(lst)
#'
#' @export
find_conversion_rate <- function(lst) {
  tibble(value = as.numeric(lst)) %>%
    summarize(
      total_count = n(),
      conversion_sum = sum(value, na.rm = TRUE) %>% round(),
      conversion_rate = (100 * conversion_sum / total_count) %>% round(2)
    )
}


# tibble(value = as.numeric(lst)): Converts the input lst to a numeric vector wrapped in a tibble, which enables tidyverse functions.
# summarize: Calculates the total count, sum, and conversion rate in a single summarization block.
# round and na.rm: Used to ensure accurate rounding and handle any potential NA values gracefully.













# EXAMPLE
# # In R/data_cleaning_transform.R
# preprocess_data <- function(data) {
#   # Data preprocessing steps (e.g., handle missing values)
#   data %>%
#     mutate(across(where(is.numeric), ~ replace_na(., 0)))  # Example imputation
# }
#
# feature_engineering <- function(data) {
#   # Feature engineering (e.g., create new variables)
#   data %>%
#     mutate(sales_per_customer = total_sales / total_customers)
# }
#
# select_features <- function(data) {
#   # Feature selection logic
#   data %>%
#     select(-unimportant_column)  # Remove irrelevant features
# }
#

