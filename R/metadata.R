#' Access and set object metadata
#'
#' @inheritParams add_metadata
#' @param ... Unquoted values to extract from metadata
#' @param value_list List of value-name pairs to be passed to `add_metadata`
#' @export
metadata <- function(.data, ...) {
  attrs <- attributes(.data)
  tags <- rlang::list2(...) %>% unlist()
  if (!length(tags) > 0) {
    drop_attrs <- c("names", "row.names", "class")
    tags <- setdiff(names(attrs), drop_attrs)
  }
  out <- attrs[tags]
  names(out) <- tags
  out
}

#' @rdname metadata
#' @export
`metadata<-` <- function(.data, value_list) {
  if (is.null(names(value_list))) {
    stop("Metadata values must be named.")
  }
  add_metadata(.data, !!!value_list)
}

