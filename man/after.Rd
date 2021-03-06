% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/package.R
\name{after}
\alias{after}
\alias{after$cancel}
\alias{after$info}
\alias{after$list}
\title{Run Code in the Background}
\usage{
after(ms, fun, args = list(), redo = 0)

## task <- after(ms, fun, args = list())
## after$info(task)
## after$list()
## after$cancel(task)
}
\arguments{
\item{ms}{Amount of time to wait before running the function, in
milliseconds. An integer scalar. Use zero for immediate execution.}

\item{fun}{Function to run. Note that the function is run in the
global environment, so it is good practice not to use functions
from packages directly. See the examples below.}

\item{args}{Arguments to pass to the function, a list. As the function
runs in the global environment, it does not have access to the objects
in the calling environment. But you can pass arguments to it here.}

\item{redo}{How many times to re-run the function. Zero means running
it only once, and \code{Inf} means re-running it continuously, until
the R session is closed, the task is canceled, or the \code{after}
package is unloaded.}

\item{task}{Task id.}
}
\value{
A task id that you can use in \code{after$info} and
  \code{after$cancel}. It is returned invisibly.
}
\description{
Run an R function in the background, possibly after a delay. The current
version uses the Tcl event loop. It was inspired by similar
functionality in the \code{tcltk2} package.
}
\details{
Note that this does not mean parallelism. The scheduled function runs
in the main R process, after the specified time, whenever R is free of
other work. Also, while the scheduled function runs, no other R
computation can be done. If you use R interactively, then your command
prompt will \dQuote{freeze} while the scheduled function runs.

Thus, \code{after} is best for running very short processes, at least
for interactive use.
}
\section{Additional methods}{


\code{after$info(task)} will display some information about the task.

\code{after$list()} lists all scheduled tasks.

\code{after$cancel(task)} cancels a task.
}
\examples{

# simple example, runs after a second
after(1000, function() cat("Here I am!\\n"))

# supplying arguments
x <- "print me!"
after(1000, function(x) print(x), args = list(x))
# we can remove x now, it is already stored in the timer
rm(x)

# calling functions in packages
# Instead of after(1000, utils::alarm) use
after(1000, function() utils::alarm())
# in case utils::alarm() uses other functions from the
# utils package.

# repeat a task
x <- after(1000, function() print("still here"), redo = 5)
Sys.sleep(3)

# list tasks
after$list()

# cancel a task
after$cancel(x)
}

