# example content:

# R/data_extraction.R

library(DBI)
library(here)

# Function to connect to the database and execute a query
data_extraction <- function() {
  # Connect to the database
  con <- dbConnect(
    odbc::odbc(),
    Driver   = "your_database_driver",
    Server   = "your_server_address",
    Database = "your_database_name",
    UID      = Sys.getenv("DB_USER"),
    PWD      = Sys.getenv("DB_PASS"),
    Port     = 1433
  )

  # Load SQL query from file
  sales_query <- readLines(here("data", "extraction", "queries", "sales_data.sql")) %>%
    paste(collapse = "\n")

  # Execute the query
  extracted_data <- dbGetQuery(con, sales_query)

  # Close the connection
  dbDisconnect(con)

  return(extracted_data)
}


