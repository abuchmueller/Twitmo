#' Sample tweets by streaming or searching
#' @description Collect Tweets via streaming or searching.
#' @details A function that calls on \link[rtweet]{stream_tweets} and \link[rtweet]{search_tweets}
#' (depending on the specified method) and is specifically tailored for sampling geo-tagged data.
#' This function provides supports additional arguments like location for convenient
#' sampling of geo-tagged Tweets. Tweets can be searched up to 9 days into the past.
#' @param method Character string. Supported methods are streaming and searching.
#' The default method is streaming \code{method = 'stream'}. This is the recommended method as it allows
#' to collect larger volumes of data over time.
#' Use \code{method = 'search'} if you want to collect Tweets from the past 9 days.
#' @param keywords Character string of keywords provided via a comma separated character string.
#' Only for searching Tweets.If you want to stream Tweets for a certain location AND filter by keywords use the location parameter and after sampling use the \link[Twitmo]{filter_tweets} function.
#' If you are using the search method instead of streaming keywords WILL work together with a location but will yield only a very limited number of Tweets.
#' @param location Character string of location to sample from. Can be a three letter country code i.e. "USA" or a city name like "berlin".
#' Use \code{Twitmo:::bbox_country} for all supported country locations or \code{rtweet:::citycoords} for a list of supported cities.
#' Alternatively, use a vector of doubles with four latitude/longitude bounding box points provided via a vector of length 4, in the following format c(sw.long, sw.lat, ne.long, ne.lat) e.g., c(-125, 26, -65, 49).
#' @param timeout Integer. Limit streaming time in seconds. By default will stream indefinitely until user interrupts by pressing [ctrl + c].
#' @param file_name Character string of desired file path and file name where Tweets will be saved.
#' If not specified, will write to stream_tweets.json in the current working directory.
#' @param n_max Integer value. Only applies to the \code{search} method. Limit how many Tweets are collected.
#' @param ... Additional arguments passed to \link[rtweet]{stream_tweets} or \link[rtweet]{search_tweets}.
#' @return Either a json file in the specified directory.
#' @references \url{https://developer.twitter.com/en/docs/twitter-api/v1/tweets/search/api-reference/get-search-tweets}
#' \url{https://developer.twitter.com/en/docs/twitter-api/v1/tweets/sample-realtime/api-reference/get-statuses-sample}
#' @seealso \link[rtweet]{stream_tweets}, \link[rtweet]{search_tweets}
#' @export
#'
#' @examples
#' \dontrun{
#'
#' # live stream tweets from Germany for 60 seconds and save to current working directory
#' get_tweets(method = "stream",
#'            location = "DEU",
#'            timeout = 60,
#'            file_name = "german_tweets.json")
#'
#' # OR
#' # live stream tweets from berlin for an hour
#' get_tweets(method = "stream",
#'            location = "berlin",
#'            timeout = 3600,
#'            file_name = "berlin_tweets.json")
#'
#' # OR
#' # use your own bounding box coordinates to strean tweets indefinitely (interrupt to stop)
#' get_tweets(method = 'stream',
#'            location = c(-125, 26, -65, 49),
#'            timeout = Inf)
#'
#' }

get_tweets <- function(method = 'stream',
                       location = c(-180, -90, 180, 90),
                       timeout = Inf,
                       keywords = "",
                       n_max = 100L,
                       file_name = NULL,
                       ...) {

  if (method == 'stream') {

    stopifnot(is.double(location)|is.character(location))

    # pass bbox coordinates to rtweet if user enters vector of doubles
    if (is.double(location)) rtweet::stream_tweets(q = location,
                                                   timeout = timeout,
                                                   parse = FALSE,
                                                   file_name = file_name,
                                                   ...)

    # check if location can be found in Twitmo or rtweet if user enters character string
    if (is.character(location)) {

      # check for location in country bbox db
      if (location %in% row.names(bbox_country)) {

        # pass bbox coordinates if location is found
        location <- as.double(bbox_country[location, ])

        # stream at location
        rtweet::stream_tweets(q = location,
                              timeout = timeout,
                              parse = FALSE,
                              file_name = file_name,
                              ...)
      } else if (!location %in% row.names(bbox_country)) {

        #look up location coords in rtweet if not found in Twitmo
        tryCatch(location <- rtweet::lookup_coords(location)$box,
                 error = function(e) {
                   e$message <- paste("Could not find coordinates for your location or a Google Maps API key.
  The `location` parameter requires a valid character string or Google Maps API key.
  Use Twitmo:::bbox_country and rtweet:::citycoords for a full list of supported character strings for locations or
  use supply your own bounding box coordinates in the following format: c(sw.long, sw.lat, ne.long, ne.lat)", sep = " ")
                   stop(e)
                 }
                   )

        location <- as.double(location)

        # stream at location if location was found or API key given
        rtweet::stream_tweets(q = location,
                              timeout = timeout,
                              parse = FALSE,
                              file_name = file_name,
                              ...)
      }

    }

  }

  if (method == 'search') {

    message("You're using the search endpoint.
  For search this package includes 250 cities worldwide (type rtweet::citycoords to see a list).
  If you want to use your a custom location with the search endpoint use rtweet::search_tweets()")

    stopifnot(is.character(location)|NULL)

    # look up location in rtweet
    if (is.character(location)) {

      location <- rtweet::lookup_coords(location)$point

      # convert point coordinates to valid geocode schema for search endpoint
      # for the search endpoint coordinates need to be "latitude,longitude,radius"
      location <- paste(paste(location, collapse = ",", sep = ","), "50mi", collapse = ",", sep = ",")

    }

    rtweet::search_tweets(q = keywords,
                          n = n_max,
                          retryonratelimit = TRUE,
                          geocode = location,
                          parse = TRUE,
                          ...)



  }

}



