
#' Run Code in the Background
#'
#' Run an R function in the background, possibly after a delay. The current
#' version uses the Tcl event loop. It was inspired by similar
#' functionality in the \code{tcltk2} package.
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
#' \code{after$info(task)} will display some information about the task.
#'
#' \code{after$list()} lists all scheduled tasks.
#'
#' \code{after$cancel(task)} cancels a task.
#'
#' @usage
#' after(ms, fun, args = list(), redo = 0)
#'
#' ## task <- after(ms, fun, args = list())
#' ## after$info(task)
#' ## after$list()
#' ## after$cancel(task)
#'
#' @param ms Amount of time to wait before running the function, in
#'   milliseconds. An integer scalar. Use zero for immediate execution.
#' @param fun Function to run. Note that the function is run in the
#'   global environment, so it is good practice not to use functions
#'   from packages directly. See the examples below.
#' @param args Arguments to pass to the function, a list. As the function
#'   runs in the global environment, it does not have access to the objects
#'   in the calling environment. But you can pass arguments to it here.
#' @param redo How many times to re-run the function. Zero means running
#'   it only once, and \code{Inf} means re-running it continuously, until
#'   the R session is closed, the task is canceled, or the \code{after}
#'   package is unloaded.
#' @param task Task id.
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
#'
#' # repeat a task
#' x <- after(1000, function() print("still here"), redo = 5)
#' Sys.sleep(3)
#'
#' # list tasks
#' after$list()
#'
#' # cancel a task
#' after$cancel(x)
NULL

after_tasks <- new.env()

after <- function(ms, fun, args = list(), redo = 0) {

  ## Argument checks and coercions
  stopifnot(is_count(ms <- as.integer(ms)))
  if (ms <= 0) ms <- "idle"
  stopifnot(is.function(fun))
  environment(fun) <- .GlobalEnv
  stopifnot(is.list(args))
  stopifnot(identical(redo, Inf) || is_count(redo))

  id <- random_id()

  task <- list(
    ## Arguments
    ms = ms, fun = fun, args = args, redo = redo,
    ## Timekeeping
    scheduled = Sys.time(), last_run = NULL,
    ## Ids
    id = id, tcl_id = tcl("after", ms, after_factory(id))
  )
  class(task) <- "after_task"

  assign(task$id, task, envir = after_tasks)

  invisible(task)
}

class(after) <- "after_package"

after_factory <- function(id) {
  function() {
    after_runner(id)
  }
}

after_runner <- function(id) {
  ## Run it
  task <- get(id, envir = after_tasks)
  do.call(task$fun, task$args)

  ## Re-schedule or remove
  if (task$redo >= 1) {
    task$redo <- task$redo - 1L
    task$last_run <- Sys.time()
    task$tcl_id <- tcl("after", task$ms, after_factory(id))
    assign(task$id, task, envir = after_tasks)

  } else {
    rm(list = task$id, envir = after_tasks)
  }
}

#' @export

print.after_task <- function(x, ...) {
  cat(
    sep = "",
    "Task ", x$id, "\n",
    "  scheduled: ", format(x$scheduled), "\n",
    "  last: ", format(x$last_run), "\n",
    "  redo: ", x$redo, "\n"
  )

  invisible(x)
}

#' @export

`$.after_package` <- function(x, name) {
  if (name %in% names(after_functions)) {
    after_functions[[name]]
  } else {
    stop("Unknown 'after' function")
  }
}

#' @export

names.after_package <- function(x) {
  names(after_functions)
}

after_cancel <- function(id) {
  id <- task_id(id)
  x <- tryCatch(
    {
      task <- get(id, envir = after_tasks)
      rm(list = id, envir = after_tasks)
      tcl("after", "cancel", task$tcl_id)
    },
    error = function(e) e
  )
  invisible(x)
}

after_info <- function(id) {
  id <- task_id(id)
  get(id, envir = after_tasks)
}

after_list <- function() {
  ids <- ls(after_tasks)
  mget(ids, envir = after_tasks)
}

after_functions <- list(
  "cancel" = after_cancel,
  "info" = after_info,
  "list" = after_list
)

cancel_all_tasks <- function() {
  lapply(ls(after_tasks), after_cancel)
}

task_id <- function(id) {
  if (inherits(id, "after_task")) {
    id$id

  } else {
    id <- as.character(id)
    stopifnot(is_string(id))
    id
  }
}
