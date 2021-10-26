#' Plot tweets on a static map
#' @description Plot tweets on a static map with base plot.
#' @details This function can be used to generate high resolution spatial plots of tweets.
#' Works with data frames of tweets returned by \link[Twitmo]{pool_tweets} as well as data frames
#' read in by \link[Twitmo]{load_tweets} and then augmented by lat/lng coordinates with \link[rtweet]{lat_lng}.
#' For larger view resize the plot window then call \code{plot_tweets} again.
#' @param data A data frame of tweets parsed by \link[Twitmo]{load_tweets} or returned by \link[Twitmo]{pool_tweets}.
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
#' library(Twitmo)
#'
#' # Plot tweets on mainland USA
#' mytweets <- load_tweets(system.file("extdata", "tweets_20191027-141233.json", package = "Twitmo"))
#'
#' plot_tweets(mytweets, region = "USA(?!:Alaska|:Hawaii)", alpha=1)
#' # Add title
#' title("My tweets on a map")
#' }
#'
#' @seealso \link[maps]{map}, \link[maps]{iso3166}
#'
#' @export

plot_tweets <- function(data, region = ".", alpha = 0.01, ...) {

  # remove opacity if sample size is small
  if (nrow(data) < 100) alpha <- 1

  # restore user options on exit
  oldpar <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(oldpar))

  ## plot state boundaries
  graphics::par(mar = c(0, 0, 3, 0))
  maps::map("world", region,  ...)

  ## plot lat and lng points onto state map
  with(data, points(lng, lat, pch = 20, cex = .75, col = rgb(0, .3, .7, .75, alpha = alpha)))

}

#' Plot tweets containing certain hashtag
#' @description Plot the locations of certain hashtag on a static map with base plot.
#' @details This function can be used to generate high resolution spatial plots of hashtags
#' Works with data frames of tweets returned by \link[Twitmo]{pool_tweets} as well as data frames
#' read in by \link[Twitmo]{load_tweets} and then augmented by lat/lng coordinates with \link[rtweet]{lat_lng}.
#' For larger view resize the plot window then call \code{plot_tweets} again.
#' @param hashtag Character vector of the hashtag you want to plot.
#' @param ignore_case Logical, if TRUE will ignore case of hashtag.
#' @param ... Extra arguments passed to \link[graphics]{polygon} or \link[graphics]{lines}.
#' @inheritParams plot_tweets
#' @return Maps where each dot represents a tweet.
#' @examples
#'
#' \dontrun{
#' library(Twitmo)
#'
#' # load tweets (included in package)
#' mytweets <- load_tweets(system.file("extdata", "tweets_20191027-141233.json", package = "Twitmo"))
#'
#' # Plot tweets on mainland USA region
#' plot_hashtag(mytweets,
#'              region = "USA(?!:Alaska|:Hawaii)",
#'              hashtag = "breakfast",
#'              ignore_case=TRUE,
#'              alpha=1)
#'
#' # Add title
#' title("My hashtags on a map")
#' }
#'
#' @seealso \link[maps]{map}, \link[maps]{iso3166}
#'
#' @export

plot_hashtag <- function(data, region = ".", alpha = 0.01, hashtag = "", ignore_case = TRUE, ...) {

  # remove opacity if sample size is small
  if (nrow(data[which(sapply(data$hashtags, FUN=function(X) hashtag %in% X)), ]) < 100) alpha <- 1

  # restore user options on exit
  oldpar <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(oldpar))

  ## plot state boundaries
  graphics::par(mar = c(0, 0, 3, 0))
  maps::map("world", region,  ...)

 # case sensitivity logic
  if (ignore_case) {

    # convert query to lowercase
    hashtag <- tolower(hashtag)

    # convert hashtags to lowercase
    data$hashtags <- lapply(data$hashtags, tolower)

    # indices of tweets with matching hashtag
    match_ind <- which(sapply(data$hashtags, FUN=function(X) hashtag %in% X))

    ## plot lat and lng points onto state map
    with(data[match_ind, ],
         points(lng, lat, pch = 20, cex = .75, col = rgb(1, 0, 0, 0, alpha = alpha)))

  } else {

    # indices of tweets with matching hashtag
    match_ind <- which(sapply(data$hashtags, FUN=function(X) hashtag %in% X))

    ## plot lat and lng points onto state map
    with(data[match_ind, ],
         points(lng, lat, pch = 20, cex = .75, col = rgb(1, 0, 0, 0, alpha = alpha)))

  }

}


#' Cluster tweets on an interactive map
#' @description Plot into clusters on an interactive map
#' @details This function can be used to create interactive maps on OpenStreetView.
#' @param ... Extra arguments passed to \link[leaflet]{markerClusterOptions}
#' @inheritParams plot_tweets
#' @return Interactive leaflet map
#' @examples
#'
#' \dontrun{
#'
#' library(Twitmo)
#'
#' # load tweets (included in package)
#' mytweets <- load_tweets(system.file("extdata", "tweets_20191027-141233.json", package = "Twitmo"))
#'
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

  # create leaflet map with marker clusters
  m <- leaflet::leaflet() %>%
    leaflet::addTiles() %>%  # Add default OpenStreetMap map tiles
    leaflet::addMarkers(lng=data$lng, lat=data$lat, clusterOptions = leaflet::markerClusterOptions(...), popup = data$text)

  # Print the map
  m
}




