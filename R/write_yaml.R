#' Write list as YAML file
#'
#' @param l List to write out to file
#' @param file Path to target file
#' @param comment Comment string with which to prefix file. Default = "#".
#' @param ... Additional arguments to [yaml::as.yaml]
#' @return `NULL`, invisibly
#' @export
write_yaml <- function(l, file, comment = "#", ...) {
  text1 <- yaml::as.yaml(l, ...)
  text2 <- gsub("\n", paste0("\n", comment), text1)
  yaml_bar <- paste0(comment, "---")
  out_text <- c(yaml_bar, paste0(comment, text2), yaml_bar)
  cat(out_text, file = file, sep = "\n")
  invisible(NULL)
}
