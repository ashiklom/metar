#' Translations between Table Schema types and readr column specifications.
schema_type_dict <- c(
  "string" = "character",
  "integer" = "integer",
  "number" = "number",
  "factor" = "factor",
  "date" = "date",
  "datetime" = "datetime",
  "boolean" = "logical"
)

#' Translations from readr classes to base R classes
base_to_readr_class_dict <- c(
  "character" = "character",
  "integer" = "integer",
  "numeric" = "number",
  "factor" = "factor",
  "Date" = "date",
  "POSIXct" = "datetime"
)
