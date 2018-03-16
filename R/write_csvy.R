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

  col_types <- .data %>%
    purrr::map(sticky::unsticky) %>%
    purrr::map(class)

  inverse_dict <- names(schema_type_dict)
  names(inverse_dict) <- schema_type_dict

  col_yaml_types <- col_types %>%
    purrr::map(~inverse_dict[.]) %>%
    purrr::map(~list(type = .)) %>%
    purrr::map2(names(.), ~c(name = .y, .x))

  col_all_md <- purrr::map2(col_yaml_types, col_md, c) %>%
    unname()
  
  c(self_md, list(resources = list(fields = col_all_md)))
}
