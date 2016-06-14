
is_string <- function(x) {
  is.character(x) && length(x) == 1 && !is.na(x)
}

is_count <- function(x) {
  is_integerish(x) && length(x) == 1 && !is.na(x)
}

is_integerish <- function(x) {
  is.integer(x) || (is.numeric(x) && all(x == as.integer(x)))
}

random_id <- function() {
  paste(
    sample(c(0:9, "a", "b", "c", "d", "e", "f"), 16, replace = TRUE),
    collapse = ""
  )
}
