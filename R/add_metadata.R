#' Add metadata to an object
#'
#' @param .data Object to which to add metadata
#' @param ... List of metadata in the form `attr1 = value1, attr2 = value2`
#' @return Data as a [sticky][sticky::sticky] object, with metadata stored in `attributes`
#' @export
add_metadata <- function(.data, ...) {
  dots <- rlang::list2(...)
  rlang::set_attrs(.data, !!!dots) %>%
    sticky::sticky()
}

#' Add metadata to columns of a data frame
#'
#' @param .data A `data.frame` or `tbl`
#' @param ... List of metadata in the form `column = list(attr1 = value1, attr2 = value2)`
#' @param .root List of metadata fields to be applied to data frame itself
#' @return Data, as a [sticky][sticky::sticky] object with metadata stored in `attributes`
#' @export
add_column_metadata <- function(.data, ..., .root = list()) {
  dots <- rlang::list2(...)
  columns <- names(dots)
  for (i in seq_along(dots)) {
    if (!length(dots[[i]]) > 0) next
    column <- columns[i]
    metadata(.data[[column]]) <- dots[[i]]
  }
  if (length(.root) > 0) {
    metadata(.data) <- .root
  }
  # Make attributes of columns and data frame itself persistent
  sticky::sticky(.data)
}
