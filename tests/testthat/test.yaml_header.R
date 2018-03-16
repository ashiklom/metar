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
