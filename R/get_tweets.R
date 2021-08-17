#' Sample tweets by streaming or searching
#' @description A wrapper function that calls on rtweet::stream_tweets() and rtweet::search_tweets() (depending on the specified method).
#' This function provides additional arguments for convenient sampling of geo-tagged tweets.
#' Tweets can be searched up to 9 days into the past.
#' @param query Search query (optional). Use if you want to filter incoming tweets
#' by keyword. See \code{rtweet::stream_tweets() q} for more information.
#' @param bbox Use four latitude/longitude bounding box points to stream by geo
#' location. This must be provided via a vector of length 4, e.g., c(-125, 26, -65, 49).
#' @param endpoint One of two endpoints ('stream' or 'search'), which will call
#' upon `search_tweets()` or `stream_tweets()`.
#' @param location Locations are pre-defined bounding boxes.
#' Use \code{rtweet:::citycoords} to see a list.
#' @param sample_size Integer giving the total number of tweets to download when
#' using search endpoint.
#' @param ... Additional arguments passed to \link[rtweet]{stream_tweets} or \link[rtweet]{search_tweets}.
#' @return Either a json file in the specified directory, or (if `parse = TRUE`) additionally a data frame.
#' @export

# TODO: timeout support
# TODO: LAT/LNG to BBOX conversion support
# TODO: Keyword filtering
# TODO: Add more locations (e.g. EU, UK, China ... currently only cities supported)
# TODO: add lang, location/country filtering.

# This is a wrapper function that combines rtweet::stream_tweets() and rtweet::search_tweets()
# and is specifically tailored to sampling geo-located data

get_tweets <- function(method = 'stream',
                       bbox = c(-180, -90, 180, 90),
                       sample_size = 100,
                       location = NULL,
                       ...) {

  if (method == 'stream') {
    rtweet::stream_tweets(
      q = bbox,
      ...
    )
  }

  if (method == 'search') {
    rtweet::search_tweets(n = sample_size,
                          geocode = rtweet::lookup_coords(location),
                          include_rts = FALSE,
                          retryonratelimit = TRUE,
                          ...)

  }

}


