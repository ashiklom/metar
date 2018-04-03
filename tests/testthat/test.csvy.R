context("Reading and writing CSVY files")

test_that(
  "Reading simple CSVY file works",
  {
    example_file <- system.file("examples/example1.csvy", package = "metar")

    expect_warning(read_csvy(example_file), "Mismatches in column classes")
    test_in <- read_csvy(example_file, verbose = FALSE)

    expect_equal(metadata(test_in, "name"), list(name = "example-dataset-1"))
    expect_equal(metadata(test_in, "description"), list(description = "An example dataset"))
    expect_equal(metadata(test_in$var1, "label"), list(label = "First variable"))
    expect_equal(metadata(test_in$var2, "label"), list(label = "Second variable"))
    expect_equal(metadata(test_in$var3, "label"), list(label = "Third variable"))

    # Test stickiness
    expect_equal(metadata(test_in$var1[1], "label"), list(label = "First variable"))
    expect_equal(metadata(test_in[[1]], "label"), list(label = "First variable"))
    expect_equal(metadata(test_in[1,]$var1, "label"), list(label = "First variable"))
    expect_equal(metadata(test_in[1,], "description"), list(description = "An example dataset"))

    # Test formats
    expect_is(test_in$var1, "character")
    expect_is(test_in$var2, "integer")
    expect_is(test_in$var3, "numeric")
    expect_is(test_in$var4, "logical")
    expect_is(test_in$var5, "factor")
  }
)

test_that(
  "Reading and writing CSVY files works",
  {
    iris_tbl <- tibble::as_tibble(iris)
    iris_md <- add_column_metadata(
      iris_tbl,
      Sepal.Length = list(unit = "cm", description = "Obvious"),
      Sepal.Width = list(unit = "in", description = "Duh!"),
      .root = list(description = "Famous data", author = "Alexey")
    )
    iris_md$testfactor <- factor(sample(letters[1:3], nrow(iris_md), TRUE), c("c", "b", "a"))
    meta <- get_all_metadata(iris_md)
    expect_true("description" %in% names(meta))
    expect_true("author" %in% names(meta))
    expect_true("resources" %in% names(meta))
    resources <- meta$resources
    expect_is(resources, "list")
    expect_true("fields" %in% names(resources))
    fields <- resources$fields
    field_cols <- purrr::map_chr(fields, "name")
    expect_equal(field_cols, names(iris_md))

    tmp <- tempfile()
    write_csvy(iris_md, tmp)
    test_iris <- read_csvy(tmp, verbose = FALSE)
    expect_equivalent(iris_md, test_iris)
  }
)
