
is_count <- function(x) {
  is.integer(x) && length(x) == 1 && !is.na(x)
}
