#' Add metadata to a data frame
#'
#' @param .data A `data.frame` or `tbl`
#' @param ... List of metadata in the form `column = list(attr1 = value1, attr2 = value2)`
#' @param .root List of metadata fields to be applied to data frame itself
#' @return Data, as a [sticky][sticky::sticky] object with metadata applied
#' @export
add_metadata <- function(.data, ..., .root = list()) {
  dots <- rlang::list2(...)
  columns <- names(dots)
  for (i in seq_along(dots)) {
    column <- columns[i]
    .data[[column]] <- rlang::set_attrs(.data[[column]], !!!dots[[i]])
  }
  if (length(.root) > 0) {
    .data <- rlang::set_attrs(.data, !!!.root)
  }
  sticky::sticky_all(.data)
}
