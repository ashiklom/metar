#' Translations between Table Schema types and R's types
schema_type_dict <- c(
  "string" = "character",
  "integer" = "integer",
  "number" = "numeric",
  "factor" = "character",   # Convert to factor afterwards -- fread doesn't do factors
  "date" = "Date",
  "datetime" = "POSIXct",
  "boolean" = "logical"
)
