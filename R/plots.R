#' Plot tweets on a static map
#' @description Plot tweets on a static map with base plot.
#' @details This function can be used to generate high resolution spatial plots of tweets.
#' Works with data frames of tweets returned by \link[TweetLocViz]{pool_tweets} as well as data frames
#' read in by \link[TweetLocViz]{load_tweets} and then augmented by lat/lng coordinates with \link[rtweet]{lat_lng}.
#' For larger view resize the plot window then call \code{plot_tweets} again.
#' @param data A data frame of tweets parsed by \link[TweeLocViz]{load_tweets} or returned by \link[TweetLocViz]{pool_tweets}.
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
#' # Plot tweets on mainland USA
#' mytweets <- load_tweets("inst/extdata/tweets 20191027-141233.json")
#' plot_tweets(mytweets, region = "USA(?!:Alaska|:Hawaii)", alpha=1)
#' #' # Add title
#' title("My Tweets on a Map")
#' }
#'
#' @seealso \link[maps]{map}, \link[maps]{iso3166}
#'
#' @export

plot_tweets <- function(data, region = ".", alpha = 0.01, ...) {

  # remove opacity if sample size is small
  if (nrow(data) < 1000) alpha <- 1

  ## plot state boundaries
  par(mar = c(0, 0, 3, 0))
  maps::map("world", region,  ...)

  ## plot lat and lng points onto state map
  with(data, points(lng, lat, pch = 20, cex = .75, col = rgb(0, .3, .7, .75, alpha = alpha)))

}

#' Plot tweets with certain hashtag.
#' @description Plot the locations of certain hashtag on a static map with base plot.
#' @details This function can be used to generate high resolution spatial plots of tweets.
#' Works with data frames of tweets returned by \link[TweetLocViz]{pool_tweets} as well as data frames
#' read in by \link[TweetLocViz]{load_tweets} and then augmented by lat/lng coordinates with \link[rtweet]{lat_lng}.
#' For larger view resize the plot window then call \code{plot_tweets} again.
#' @param hashtag Character vector of the hashtag you want to plot.
#' @param ignore_case Logical, if TRUE will ignore case of hashtag.
#' @param ... Extra arguments passed to \link[graphics]{polygon} or \link[graphics]{lines}.
#' @inheritParams plot_tweets
#' @return Maps where each dot represents a tweet.
#' @examples
#'
#' \dontrun{
#'
#' library(TweetLocViz)
#'
#' # Plot hashtags on mainland USA
#' mytweets <- load_tweets("inst/extdata/tweets 20191027-141233.json")
#' plot_hashtag(mytweets, region = "USA(?!:Alaska|:Hawaii)", hashtag = "breakfast|chinup", ignore_case=TRUE, alpha=1)
#' # Add title
#' title("My Hashtags on a Map")
#' }
#'
#' @seealso \link[maps]{map}, \link[maps]{iso3166}
#'
#' @export

plot_hashtag <- function(data, region = ".", alpha = 0.01, hashtag = "", ignore_case = TRUE, ...) {

  # remove opacity if sample size is small
  if (nrow(data[which(data$hashtags == hashtag), ]) < 1000) alpha <- 1

  ## plot state boundaries
  par(mar = c(0, 0, 3, 0))
  maps::map("world", region,  ...)


  # convert query to lowercase
  if (ignore_case==TRUE) {

    hashtag <- tolower(hashtag)

    ## plot lat and lng points onto state map
    with(data[which(tolower(data$hashtags) == hashtag), ],
         points(lng, lat, pch = 20, cex = .75, col = rgb(0, .3, .7, .75, alpha = alpha)))

  } else {

    ## plot lat and lng points onto state map
    with(data[which(data$hashtags == hashtag), ],
         points(lng, lat, pch = 20, cex = .75, col = rgb(0, .3, .7, .75, alpha = alpha)))

  }

}


#' Cluster tweets on an interactive map
#' @description Plot into clusters on a interactive map
#' @details This function can be used to create interactive maps on OpenStreetView.
#' @param ... Extra arguments passed to \link[leaflet]{markerClusterOptions}
#' @inheritParams plot_tweets
#' @return Interactive leaflet map
#' @examples
#'
#' \dontrun{
#'
#' library(TweetLocViz)
#'
#' mytweets <- load_tweets("inst/extdata/tweets 20191027-141233.json")
#' pool <- pool_tweets(mytweets)
#' cluster_tweets(mytweets)
#'
#' # OR
#' cluster_tweets(pool$data)
#' }
#'
#' @seealso \link[leaflet]{tileOptions}
#'
#' @export

cluster_tweets <- function(data, ...) {

  library(leaflet)

  # create leaflet map with marker clusters
  m <- leaflet() %>%
    addTiles() %>%  # Add default OpenStreetMap map tiles
    addMarkers(lng=data$lng, lat=data$lat, clusterOptions = markerClusterOptions(...), popup = data$text)

  # Print the map
  m
}



