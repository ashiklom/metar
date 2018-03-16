#' Convert list to data.frame with list columns where appropriate
#'
#' @param l List to convert to a data.frame
#' @return `tbl` form of the list, with list columns where appropriate
#' @export
list2df <- function(l) {
  list_cols <- purrr::map(l, find_list_cols) %>%
    purrr::reduce(union)
  purrr::map(l, set_list_cols, list_cols) %>%
    dplyr::bind_rows()
}

find_list_cols <- function(l) {
  lgl <- purrr::map_lgl(l, ~length(.) > 1 || is.list(.))
  out <- names(which(lgl))
  if (is.null(out) || any(is.na(out))) {
    stop("All list columns must be named, because order can be ambiguous.")
  }
  out
}

set_list_cols <- function(l, inds) {
  purrr::map_at(l, inds, ~list(.))
}
