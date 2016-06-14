
#' Run Code in the Background
#'
#' Run an R function in the background, possibly after a delay. The current
#' version uses the Tcl event loop. It was inspired by similar
#' functionality in the \code{tcltk} package.
#'
#' Note that this does not mean parallelism. The scheduled function runs
#' in the main R process, after the specified time, whenever R is free of
#' other work. Also, while the scheduled function runs, no other R
#' computation can be done. If you use R interactively, then your command
#' prompt will \dQuote{freeze} while the scheduled function runs.
#'
#' Thus, \code{after} is best for running very short processes, at least
#' for interactive use.
#'
#' @section Additional methods:
#'
#' \code{after$list()} lists all scheduled tasks.
#'
#' \code{after$info(task)} will display some information about the task.
#' Currently this is only useful to decide if the task has been executed
#' already: if this happened then \code{after$info()} will throw an error.
#'
#' \code{after$cancel(task)} cancels a task. It is a good idea to
#' put it in a \code{tryCatch} block, since it will fail for tasks that
#' already completed.
#'
#' @usage
#' after(ms, fun, args = list())
#'
#' ## task <- after(ms, fun, args = list())
#' ## after$cancel(task)
#' ## after$info(task)
#' ## after$list()
#'
#' @param ms Amount of time to wait before running the function, in
#'   milliseconds. An integer scalar. Use zero for immediate execution.
#' @param fun Function to run. Note that the function is run in the
#'   global environment, so it is good practice not to use functions
#'   from packages directly. See the examples below.
#' @param args Arguments to pass to the function, a list. As the function
#'   runs in the global environment, it does not have access to the objects
#'   in the calling environment. But you can pass arguments to it here.
#' @param task Task id, as returned by \code{after()}.
#' @return A task id that you can use in \code{after$info} and
#'   \code{after$cancel}. It is returned invisibly.
#'
#' @export
#' @importFrom tcltk tcl
#' @name after
#' @aliases after$cancel after$info after$list
#' @examples
#'
#' # simple example, runs after a second
#' after(1000, function() cat("Here I am!\n"))
#'
#' # supplying arguments
#' x <- "print me!"
#' after(1000, function(x) print(x), args = list(x))
#' # we can remove x now, it is already stored in the timer
#' rm(x)
#'
#' # calling functions in packages
#' # Instead of after(1000, utils::alarm) use
#' after(1000, function() utils::alarm())
#' # in case utils::alarm() uses other functions from the
#' # utils package.
NULL

after <- function(ms, fun, args = list()) {
  stopifnot(is_count(ms <- as.integer(ms)))
  if (ms <= 0) ms <- "idle"
  stopifnot(is.function(fun))
  stopifnot(is.list(args))

  environment(fun) <- .GlobalEnv
  fun2 <- function() {
    my_args <- args
    do.call(fun, my_args)
  }

  invisible(tcl("after", ms, fun2))
}

class(after) <- "after_package"

#' @export

`$.after_package` <- function(x, name) {
  switch(
    name,
    "cancel" = after_cancel,
    "info" = after_info,
    "list" = after_list,
    stop("Unknown 'after' function")
  )
}

#' @export

names.after_package <- function(x) {
  c("cancel", "info", "list")
}

#' @importFrom tcltk tcl is.tclObj

after_cancel <- function(task) {
  stopifnot(is.tclObj(task))
  tcl("after", "cancel", task)
}

after_info <- function(task) {
  tcl("after", "info", task)
}

after_list <- function() {
  tcl("after", "info")
}
