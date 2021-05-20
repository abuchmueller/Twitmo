#' Plot tweets on a map
#' @description Visualize twitter data on a map.
#' @details This function can be used to generate high resolution spatial plots of tweets.
#' Works with data frames of tweets returned by \link[TweetLocViz]{pool_tweets} as well as data frames
#' read in by \link[TweetLocViz]{load_tweets} and then augmented by lat/lng coordinates with \link[rtweet]{lat_lng}.
#' @param data A data frame of tweets created by \link[TweetLocViz]{pool_tweets}.
#' @param region Character vector specifying region. Returns a world \link[maps]{map} by default.
#' For higher resolutions specify a region.
#' @param alpha A double between 0 and 1 specifying the opacity of plotted points.
#' See \link[maps]{iso3166} for country codes.
#' @param ... Extra arguments passed to \link[graphics]{polygon} or \link[graphics]{lines}.
#' @return Maps where each dot represents a tweet.
#' @examples
#'
#' \dontrun{
#'
#' library(TweetLocViz)
#'
#' mytweets <- load_tweets("~/TweetsfromUK.json")
#' pool <- pool_tweets(mytweets)
#' plot_tweets(pool$data, region = "UK", alpha = 0.02, lwd = 0.1)
#' }
#'
#' @seealso \link[maps]{map}, \link[maps]{iso3166}
#'
#' @export

plot_tweets <- function(data, region = ".", alpha = 0.01, ...) {

  ## plot state boundaries
  par(mar = c(0, 0, 0, 0))
  maps::map("world", region,  ...)

  ## plot lat and lng points onto state map
  with(data, points(lng, lat, pch = 20, cex = .75, col = rgb(0, .3, .7, .75, alpha = alpha)))

}


