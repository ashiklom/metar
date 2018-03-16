#' Convert list to data.frame with list columns where appropriate
#'
#' @param l List to convert to a data.frame
#' @return `tbl` form of the list, with list columns where appropriate
#' @export
list2df <- function(l) {
  purrr::map(l, make_list_cols) %>%
    dplyr::bind_rows()
}

make_list_cols <- function(l) {
  purrr::map_if(l, is.list, ~list(.))
}
