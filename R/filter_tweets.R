#' Filter tweets
#' @description Filter tweets by keywords.
#' @details Use this function if you want your Tweets to contain certain keywords.
#' This can be used for iterative filtering to create more coherent topic models.
#' Keyword filtering is always case insensitive (lowercase).
#' @param keywords Character string of keywords for black- or whitelisting provided via a comma separated character string.
#' @param include Logical. Indicate where to perform exclusive or inclusive filtering.
#' Inclusive filtering is akin to whitelisting keywords. Exclusive filtering is blacklisting certain keywords.
#' @inheritParams pool_tweets
#' @return Data frame of Tweets containing specified keywords
#'
#' @export
#' @examples
#'
#' \dontrun{
#'
#' library(Twitmo)
#'
#'
#' # load tweets (included in package)
#' mytweets <- load_tweets(system.file("extdata", "tweets_20191027-141233.json", package = "Twitmo"))
#'
#' # Exclude Tweets that mention "football" and/or "mood"
#' keyword_dict <- "football,mood"
#' mytweets_reduced <- filter_tweets(mytweets, keywords = keyword_dict, include = FALSE)
#' }


filter_tweets <- function(data, keywords, include = TRUE) {

  # Turn keywords dictionary into Regex
  dict <- stringr::str_replace_all(keywords, ",", "|")

  if (include) {

    # subset based on Regex
    included <- which(stringr::str_detect(tolower(data$text), dict))

    # return subset rows
    df_new <- data[included, ]

    return(df_new)

  }

  if (!include) {

    # subset based on Regex
    excluded <- which(!stringr::str_detect(tolower(data$text), dict))

    # return subset rows
    df_new <- data[excluded, ]

    return(df_new)

  }

}


