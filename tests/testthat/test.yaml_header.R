context("YAML header I/O")

test_that(
  "read/write yaml work correctly for example list",
  {
    test_data <- list(
      a = 5,
      b = "hello",
      c = TRUE,
      d = list(
        d1 = 1:5,
        d2 = letters[1:10],
        d3 = list(
          d31 = "a",
          d32 = "b"
        )
      )
    )
    tmp <- tempfile()
    write_yaml(test_data, tmp, comment = "#")
    yaml_test <- read_yaml_header(tmp)
    expect_equivalent(test_data, yaml_test)
    expect_equal(attr(yaml_test, "nlines"), 27)
  }
)

test_that(
  "YAML list gets correctly converted to a data.frame",
  {
    test_data <- list(
      list(a = 3, b = 6, c = 9, d = 1:5),
      list(a = 4, b = 7, c = 10, d = 1:10),
      list(a = 5, c = 11:15, d = 8, f = 12)
    )
    tmp <- tempfile()
    write_yaml(test_data, tmp)
    yaml_test <- read_yaml_header(tmp)
    df <- list2df(yaml_test)
    expect_equal(df$a, 3:5)
    expect_equal(df$b, c(6, 7, NA))
    expect_equal(df$c, list(9, 10, 11:15))
    expect_equal(df$d, list(1:5, 1:10, 8))
    expect_equal(df$f, c(NA, NA, 12))
  }
)
