#' Translations between Table Schema types and R's types
schema_type_dict <- c(
  "string" = "character",
  "integer" = "integer",
  "number" = "numeric",
  "factor" = "factor",
  "date" = "Date",
  "datetime" = "POSIXct",
  "boolean" = "logical"
)
