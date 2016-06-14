


# after

> Run Code in the Background

[![Linux Build Status](https://travis-ci.org/gaborcsardi/after.svg?branch=master)](https://travis-ci.org/gaborcsardi/after)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/gaborcsardi/after?svg=true)](https://ci.appveyor.com/project/gaborcsardi/after)
[![](http://www.r-pkg.org/badges/version/after)](http://www.r-pkg.org/pkg/after)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/after)](http://www.r-pkg.org/pkg/after)

Run an R function in the background, possibly after a delay. The current
version uses the Tcl event loop and was ported from the 'tcltk2' package.

## Installation


```r
source("https://install-github.me/gaborcsardi/after")
```

## Usage

```r
library(after)
```

Run a function five seconds later:

```r
after(5000, function() cat("Here I am!\n"))
```

Call a function in a package. It is good practice to create an
anonymous function for this:

```r
after(5000, function() utils::alarm())
```

Re-schedule a function, and run it every five seconds:

```r
fun <- function(run = TRUE) {
  print(Sys.time())
  after(5000, fun)
  }
fun(run = FALSE)
```

Cancel it:


## License

LGPL-3 © Gábor Csárdi
