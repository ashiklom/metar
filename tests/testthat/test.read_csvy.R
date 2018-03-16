context("Reading and writing CSVY files")

test_that(
  "Reading simple CSVY file works",
  {
    example_file <- system.file("examples/example1.csvy", package = "metar")
    test_in <- read_csvy(example_file)
    expect_equal(attr(test_in, "name"), "example-dataset-1")
    expect_equal(attr(test_in, "description"), "An example dataset")
    expect_equal(attr(test_in$var1, "label"), "First variable")
    expect_equal(attr(test_in$var2, "label"), "Second variable")
    expect_equal(attr(test_in$var3, "label"), "Third variable")
    # Test stickiness
    expect_equal(attr(test_in$var1[1], "label"), "First variable")
    expect_equal(attr(test_in[[1]], "label"), "First variable")
    expect_equal(attr(test_in[1,]$var1, "label"), "First variable")
    expect_equal(attr(test_in[1,], "description"), "An example dataset")
  }
)

#test_that(
  #"Reading and writing CSVY files works",
  #{
    #iris_tbl <- tibble::as_tibble(iris)
    #iris_md <- add_metadata(
      #iris_tbl,
      #Sepal.Length = list(unit = "cm", description = "Obvious"),
      #Sepal.Width = list(unit = "in", description = "Duh!"),
      #.root = list(description = "Famous data", author = "Alexey")
    #)
  #}
#)
