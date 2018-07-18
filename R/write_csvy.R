#' Write data and its metadata to a CSVY file
#'
#' @param .data `data.frame` with metadata
#' @param filename Output file name
#' @inheritParams write_yaml
#' @param ... Additional arguments to [data.table::fwrite]
#' @export
write_csvy <- function(.data, filename, comment = "#", ...) {
  meta_data <- get_all_metadata(.data)
  write_yaml(meta_data, filename, comment = comment)
  data.table::fwrite(.data, filename, col.names = TRUE, append = TRUE, ...)
}

#' Extract all metadata from a data.frame and format for YAML header
#'
#' @param .data Data frame from which to extract metadata
#' @export
get_all_metadata <- function(.data) {
  self_md <- metadata(.data)
  col_md <- purrr::map(.data, metadata)

  col_types <- get_readr_col_types(.data)

  col_yaml_types <- col_types %>%
    purrr::map(~list(type = .)) %>%
    purrr::map2(names(.), ~c(name = .y, .x))

  col_all_md <- purrr::map2(col_yaml_types, col_md, c) %>%
    unname()

  c(self_md, list(resources = list(fields = col_all_md)))
}

#' Get the column specification of an existing data frame
#'
#' Effectively, does the same thing as [readr::spec], but works on
#' in-memory data frames.
#'
#' See also [readr::spec] and [readr::cols].
#' @param .data Any `data.frame` or `tbl_df`
#' @return Column specification, just like [readr::spec]
get_readr_col_types <- function(.data) {
  col_types <- .data %>%
    purrr::map(sticky::unsticky) %>%
    purrr::map(class) %>%
    purrr::map_chr(1)  # Dates can have multiple classes
  readr_col_types <- base_to_readr_class_dict[col_types]
  if (any(is.na(readr_col_types))) {
    bad_col_types <- col_types[is.na(readr_col_types)]
    stop("Unknown column types: ", paste(bad_col_types, sep = ", "))
  }
  names(readr_col_types) <- colnames(.data)
  readr_col_types
}
