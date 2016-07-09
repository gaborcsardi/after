
# nocov start
.onUnload <- function(libpath) {
  cancel_all_tasks()
}
# nocov end
