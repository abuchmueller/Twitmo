#' Converts Twitter stream data (JSON file) into parsed data frame
#' @description Parse JSON files of collected Tweets
#' @details This function replaces \link[rtweet]{parse_stream} which has been
#' deprecated in rtweet 0.7 but is included here to ensure backwards compatibility
#' for data streamed with older versions of \code{rtweet}.
#' Alternatively \link[jsonlite]{stream_in} in conjunction with \link[rtweet]{tweets_with_users}
#' and \link[rtweet]{lat_lng} can be used if data has been collected with rtweet 0.7 or newer.
#' @usage load_tweets(file_name)
#' @param file_name Character string. Name of JSON file with data collected by
#' \link[rtweet]{stream_tweets} or \code{get_tweets()}.
#' @return A data frame of tweets data with additional meta data
#'
#' @seealso \link[rtweet]{parse_stream}, \link[jsonlite]{stream_in}, \link[rtweet]{tweets_with_users}
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' library(Twitmo)
#'
#' # load tweets (included in package)
#' raw_path <- system.file("extdata", "tweets_20191027-141233.json", package = "Twitmo")
#' mytweets <- load_tweets(raw_path)
#' }

load_tweets <- function(file_name) {

  # this code is mostly from rtweet <0.7.0
  # since this package relies on the json files pulled with twitters api
  # to be in a certain format this is here to ensure parsing works
  # in case there are changes to the way rtweet parses json files
  # in the future.
  # ref: https://github.com/ropensci/rtweet/blob/112f757be3d9a4ed2834547d74d22a95c9c48e7b/R/stream.R
  # COPYRIGHT HOLDER: Michael W. Kearney

  if (!identical(getOption("encoding"), "UTF-8")) {
    op <- getOption("encoding")
    options(encoding = "UTF-8")
    on.exit(options(encoding = op), add = TRUE)
  }
  s <- tryCatch(jsonlite::stream_in(file(file_name)), error = function(e)
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
  r <- rtweet::tweets_with_users(s)

  # add single-point latitude and longitude variables to tweets data
  rtweet::lat_lng(r)

}

# from rtweet 0.6.7: Ensures only complete lines are read.
# Less aggressive than good_lines2() from rtweet 0.7.0.
# Used to ensure backwards compatibility to earlier rtweet versions since
# rtweet does not store incomplete lines from 1.0 onward and deprecated
# parse_stream() so data streamed before not parseable.

good_lines <- function(x) {
  grep("^\\{\"created.*ms\":\"\\d+\"\\}$", x, value = TRUE)
}

