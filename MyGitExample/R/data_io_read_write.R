# Data Input/Output (IO): Functions for reading, writing, and handling data files.
# read_file, write_file, etc.
# functions with Roxygen2-style documentation



#' Read a File Based on Extension
#'
#' @description This function reads a file from a specified directory based on its extension.
#' @param data_dir Character. Directory path where the file is located.
#' @param file_name Character. Name of the file to read.
#' @return A tibble or data frame with the file contents.
#' @examples
#' read_file("data", "file.csv")
#'
read_file <- function(data_dir, file_name) {
  file_path <- file.path(data_dir, file_name)
  extension <- tools::file_ext(file_name)
  switch(extension,
         csv = read_csv(file_path),
         rds = readRDS(file_path),
         xlsx = read_excel(file_path),
         stop("Unsupported file type")
  )
}



#' Write Data to a File
#'
#' @description This function writes data to a specified file.
#' @param data A data frame or tibble to save.
#' @param data_dir Character. Directory path where the file will be saved.
#' @param file_name Character. Name of the file to save.
#' @return None. Saves data to a file.
#' @examples
#' write_file(data, "data", "output.csv")
#'
write_file <- function(data, data_dir, file_name) {
  file_path <- file.path(data_dir, file_name)
  extension <- tools::file_ext(file_name)
  switch(extension,
         csv = write_csv(data, file_path),
         rds = saveRDS(data, file_path),
         stop("Unsupported file type")
  )
}
