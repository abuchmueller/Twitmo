#' Fit STM (Structural topic model)
#' @description Estimate a structural topic model
#' @details Use this to function estimate a STM from a data frame of parsed Tweets.
#' Works with unpooled Tweets only. Pre-processing and fitting is done in one run.
#' @param n_topics Integer with number of topics.
#' @param xcov Either a \[stats]{formula} with an empty left-hand side specifying external covariates
#' (meta data) to use.e.g. \code{~favourites_count + retweet_count}
#' or a character vector (\code{c("favourites_count", "retweet_count")})
#' or comma seperated character string (\code{"favourites_count,retweet_count"})
#' with column names implying which metadata to use as external covariates.
#' @param remove_punct Logical. Indicates wheter punctuation (includes Twitter hashtags and usernames)
#' should be removed. Defaults to TRUE.
#' @param stem Logical. If \code{TRUE} turn on word stemming for terms.
#' @param ... Additional arguments passed to \link[stm]{stm}.
#' @return Object of class \link[stm]{stm}. Additionally, pre-processed documents are appended into a named list called "prep".
#' @inheritParams pool_tweets
#'
#' @export
#' @seealso \link[stm]{stm}

fit_stm <- function(data, n_topics = 2L, xcov,
                    remove_punct = TRUE,
                    stem = TRUE,
                    remove_url = TRUE,
                    remove_emojis = TRUE,
                    stopwords = "en",
                    ...) {

  if (missing(data)) stop("Missing data frame with parsed tweets")

  if (missing(xcov)) stop("Please provide at least one external covariate for STMs
If you wish to fit a model without external covariates use `fit_ctm()`.
Type `?fit_stm` to learn more.")

  n_topics <- as.integer(n_topics)

  # if stopwords are missing or not a character vector no stopwords will be used
  if (!is.character(stopwords)|missing(stopwords)) stopwords <- FALSE

  stopifnot(is.logical(stem),
            is.logical(remove_punct),
            is.logical(remove_url),
            is.logical(remove_emojis),
            is.integer(n_topics))

  # perform twitter specific text cleaning by removing urls, emojis, hashtags and usernames from text
  # add single-point latitude and longitude variables to tweets data
  data <- rtweet::lat_lng(data)

  # remove duplicates quoted tweets and retweets
  data <- data[data$is_quote == "FALSE" & data$is_retweet == FALSE, ]

  # remove emojis from tweets
  if (remove_emojis) {
    data$text <- stringr::str_remove_all(data$text, emojis_regex)
  }

  # remove urls
  if (remove_url) {
    data$text <- stringr::str_replace_all(data$text, "https://t.co/[a-z,A-Z,0-9]*","")
  }

  # remove hashtags / usernames
  if (remove_punct) {
    data$text <- stringr::str_replace_all(data$text,"#[a-z,A-Z,_]*","")

    # remove references to usernames
    data$text <- stringr::str_replace_all(data$text,"@[a-z,A-Z,_]*","")

  }

  # perform usual pre-processing steps
  processed <- stm::textProcessor(data$text,
                                  metadata = data,
                                  lowercase = TRUE,
                                  removestopwords = TRUE,
                                  removepunctuation = remove_punct,
                                  stem = stem,
                                  language = stopwords,
                                  customstopwords = c("amp", "na", "rt", "via"))
  # prepare data for stm modeling
  out <- stm::prepDocuments(documents = processed$documents,
                            vocab = processed$vocab,
                            meta = processed$meta)

  # routine for metadata formulation
  # stm takes a formula object with the lhs empty as input
  # if user inputs character string for metadata
  if (is.character(xcov) & length(xcov) == 1) {
    xcov <- paste("~", paste(unlist(strsplit(xcov, ",")), collapse = "+"), collapse = "", sep = "")
    xcov <- stats::as.formula(xcov)
  }
  # if user inputs character vector for metadata
  if (is.character(xcov) & length(xcov) > 1) {
    xcov <- paste("~", paste(xcov, collapse = "+"), collapse = "", sep = "")
    xcov <- stats::as.formula(xcov)
  }
  # make sure external covariates are a into a formula object
  # if user passes formula obj
  if (is.language(xcov)) xcov <- stats::as.formula(xcov)
  model.stm <- stm::stm(documents = out$documents, vocab = out$vocab, data = out$meta,
                        K = 7,
                        prevalence = xcov,
                        max.em.its = 75,
                        init.type = "Spectral",
                        ...)

  # append prepped data (docs, vocab)
  model.stm[["prep"]] <- out

  return(model.stm)

}

#' Fit CTM (Correlated topic model)
#' @description Estimate a CTM topic model.
#' @param pooled_dfm Object of class dfm (see \link[quanteda]{dfm}) containing (pooled) Tweets.
#' @param n_topics Integer with number of topics
#' @param ... Additional arguments passed to \link[stm]{stm}.
#' @return Object of class \link[stm]{stm}
#'
#' @export
#' @seealso \link[stm]{stm}


fit_ctm <- function(pooled_dfm, n_topics = 2L, ...) {

  dfm2ctm <- quanteda::convert(pooled_dfm, to = "stm")

  model.ctm <- stm::stm(dfm2ctm$documents,
                        dfm2ctm$vocab,
                        K = n_topics,
                        max.em.its = 75,
                        ...)

  return(model.ctm)

}


#' Find best STM/CTM
#' @description Gridsearch for optimal K for your STM/CTM
#' @param pooled_dfm object of class dfm (see \link[quanteda]{dfm}) containing (pooled) tweets
#' @param search_space Vector with number of topics to compare different models.
#' @param ... Additional parameters passed to \link[stm]{searchK}
#' @seealso \link[stm]{searchK}
#' @return Plot with different metrics compared.
#'
#' @export
#' @seealso \link[stm]{stm}

find_stm <- function(pooled_dfm, search_space = seq(4, 20, by = 2), ...) {

  dfm2stm <- quanteda::convert(pooled_dfm, to = "stm")

  idealK <- stm::searchK(dfm2stm$documents, dfm2stm$vocab, K = search_space, max.em.its = 75, ...)

  plot(idealK)

}

