#' Converts Twitter stream data (JSON file) into parsed data frame
#' @description This function has been deprecated in rtweet 1.0.0 but is
#' included here so ensure backwards compatibility data streamed with older versions of \code{rtweet}.
#' @param file_name Character string. Name of JSON file with data collected by
#' \code{rtweet::stream_tweets()} or \code{get_tweets()}.
#' @export

load_tweets <- function(file_name, ...) {
  # from rtweet 0.7.0
  if (!identical(getOption("encoding"), "UTF-8")) {
    op <- getOption("encoding")
    options(encoding = "UTF-8")
    on.exit(options(encoding = op), add = TRUE)
  }
  s <- tryCatch(jsonlite::stream_in(file(file_name), ...), error = function(e)
    return(NULL))
  if (is.null(s)) {
    d <- readr::read_lines(file_name)
    if (length(d) > 0) {
      tmp <- tempfile()
      on.exit(file.remove(tmp), add = TRUE)
      d <- good_lines(d)
    }
    if (length(d) > 0) {
      dd <- sapply(d, function(x) {
        o <- tryCatch(jsonlite::fromJSON(x),
                      error = function(e) return(FALSE))
        if (identical(o, FALSE)) return(FALSE)
        return(TRUE)
      }, USE.NAMES = FALSE)
      writeLines(d[dd], tmp)
      s <- jsonlite::stream_in(file(tmp, "rb"))
    }
  }
  if (length(s) == 0L) s <- NULL
  rtweet::tweets_with_users(s)
}

# from rtweet 0.6.7: Ensures only complete lines are read.
# Less aggressive than good_lines2() from rtweet 0.7.0.
# Used to ensure backwards compatibility to earlier rtweet versions since
# rtweet does not store incomplete lines from 1.0 onward and deprecated
# parse_stream() so data streamed before not parseable.

good_lines <- function(x) {
  grep("^\\{\"created.*ms\":\"\\d+\"\\}$", x, value = TRUE)
}

