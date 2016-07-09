
context("after")

test_that("after works", {

  ## Temporary file, does not exist yet
  tmp <- tempfile()
  on.exit(try(unlink(tmp), silent = TRUE), add = TRUE)
  expect_false(file.exists(tmp))

  ## We'll create it in one second
  after(1000, function(x) cat("hello", file = x), args = list(tmp))

  ## Wait half a second, it should not exist just yet
  Sys.sleep(0.5)
  expect_false(file.exists(tmp))

  ## But after another second, it should
  Sys.sleep(1)
  expect_true(file.exists(tmp))
})

test_that("periodic scheduler", {

  ## We'll run this three times. We pass an environment to it,
  ## so we can keep track of the state
  env <- new.env()
  env$counter <- 0
  after(1000, args = list(env), redo = 2, function(x) {
    x$counter <- x$counter + 1
  })

  Sys.sleep(1.5)
  expect_equal(env$counter, 1)

  Sys.sleep(1)
  expect_equal(env$counter, 2)

  Sys.sleep(1)
  expect_equal(env$counter, 3)

  Sys.sleep(1)
  expect_equal(env$counter, 3)
})

test_that("manipulating tasks", {

  env <- new.env()
  env$counter <- 0
  after(500, args = list(env), function(x) {
    x$counter <- x$counter + 1
  })

  ## List, info, cancel and list
  l <- after$list()
  i <- after$info(names(l)[1])
  i2 <- after$info(l[[1]])
  after$cancel(names(l)[1])
  l2 <- after$list()

  expect_equal(length(l), 1)
  expect_null(l[[1]]$last)
  expect_equal(l[[1]]$redo, 0)

  expect_equal(l[[1]], i)
  expect_equal(i, i2)

  expect_equal(l2, structure(list(), names = character()))

  expect_equal(env$counter, 0)

  Sys.sleep(1)
  expect_equal(env$counter, 0)

  expect_output(print(l), "scheduled")

  expect_equal(names(after), c("cancel", "info", "list"))
})

test_that("error handling", {
  expect_error(after$foobar, "Unknown")
})

test_that("cancel_all_tasks", {

  after(500, function() print("foobar"))
  cancel_all_tasks()
  expect_equal(length(after$list()), 0)
})
