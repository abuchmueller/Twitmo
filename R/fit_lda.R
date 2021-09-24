#' Fit LDA Topic Model
#' @description Estimate a LDA topic model using VEM or Gibbs Sampling.
#' @param pooled_dfm Object of class dfm (see \link[quanteda]{dfm}) containing (pooled) tweets.
#' @param n_topics Integer with number of topics.
#' @param ... Additional arguments passed to \link[topicmodels]{LDA}.
#' @return Object of class \link[topicmodels:TopicModel-class]{LDA}.
#'
#' @export
#' @examples
#' \dontrun{
#'
#' library(Twitmo)
#'
#' # load tweets (included in package)
#' mytweets <- load_tweets(system.file("extdata", "tweets_20191027-141233.json", package = "Twitmo"))
#'
#' # Pool tweets into longer pseudo-documents
#' pool <- pool_tweets(data = mytweets)
#' pooled_dfm <- pool$document_term_matrix
#'
#' # fit your LDA model with 7 topics
#' model <- fit_lda(pooled_dfm, n_topics = 7, method = "Gibbs")
#' }

fit_lda <- function(pooled_dfm, n_topics, ...) {
  ###### LDA ######
  n_topics <- n_topics
  dfm2topicmodels <- quanteda::convert(pooled_dfm, to = "topicmodels")
  lda.model <- topicmodels::LDA(dfm2topicmodels, n_topics, ...)

  return(lda.model)

}

#' Find best LDA model
#' @description Find the optimal hyperparameter k for your LDA model
#' @param pooled_dfm object of class dfm (see \link[quanteda]{dfm}) containing (pooled) tweets
#' @param search_space Vector with number of topics to compare different models.
#' @param method The method to be used for fitting.
#' Currently method = "VEM" or method = "Gibbs" are supported.
#' @param ... Additional arguments passed to \link[ldatuning]{FindTopicsNumber}.
#' @seealso \link[ldatuning]{FindTopicsNumber}
#' @return Plot with different metrics compared.
#'
#' @export
#' @examples
#' \dontrun{
#'
#' library(Twitmo)
#'
#' # load tweets (included in package)
#' mytweets <- load_tweets(system.file("extdata", "tweets_20191027-141233.json", package = "Twitmo"))
#'
#' # Pool tweets into longer pseudo-documents
#' pool <- pool_tweets(data = mytweets)
#' pooled_dfm <- pool$document_term_matrix
#'
#' # use the ldatuner to compare different K
#' find_lda(pooled_dfm, search_space = seq(1, 10, 1),  method = "Gibbs")
#' }

find_lda <- function(pooled_dfm, search_space = seq(1, 10, 2), method = "Gibbs", ...) {

  dfm2topicmodels <- quanteda::convert(pooled_dfm, to = "topicmodels")

  # LDA Hyperparameter Tuning
  ldatuning_metrics <- ldatuning::FindTopicsNumber(dfm2topicmodels,
                                                    topics = search_space,
                                                    metrics = c("Griffiths2004",
                                                                "CaoJuan2009",
                                                                "Arun2010",
                                                                "Deveaud2014"),
                                                    method = method
  )
  return(ldatuning::FindTopicsNumber_plot(ldatuning_metrics))
}


# Convenience Functions ---------------------------------------------------

#' View Terms heavily associated with each topic
#' @description Convenience Function to extract the most likely terms for each topic.
#' @param lda_model Fitted LDA Model. Object of class \link[topicmodels:TopicModel-class]{LDA}).
#' @param n_terms Integer number of terms to return.
#' @return Data frame with top n terms for each topic.
#' @export
#' @examples
#' \dontrun{
#'
#' library(Twitmo)
#'
#' # load tweets (included in package)
#' mytweets <- load_tweets(system.file("extdata", "tweets_20191027-141233.json", package = "Twitmo"))
#'
#' # Pool tweets into longer pseudo-documents
#' pool <- pool_tweets(data = mytweets)
#' pooled_dfm <- pool$document_term_matrix
#'
#' # fit your LDA model with 7 topics
#' model <- fit_lda(pooled_dfm, n_topics = 7, method = "Gibbs")
#'
# extract the most likely 10 terms for each topic
# lda_terms(model, n_terms = 10)
#' }


lda_terms <- function(lda_model, n_terms = 10) {
  data.frame(topicmodels::terms(lda_model, n_terms))
}

#' View Documents (hashtags) heavily associated with topics
#' @description Convenience Function to extract the most likely topics for each hashtag.
#' @param lda_model Fitted LDA Model. Object of class \link[topicmodels:TopicModel-class]{LDA}).
#' @return Data frame with most likely topic for each hashtag.
#' @export
#' @examples
#' \dontrun{
#'
#' library(Twitmo)
#'
#' # load tweets (included in package)
#' mytweets <- load_tweets(system.file("extdata", "tweets_20191027-141233.json", package = "Twitmo"))
#'
#' # Pool tweets into longer pseudo-documents
#' pool <- pool_tweets(data = mytweets)
#' pooled_dfm <- pool$document_term_matrix
#'
#' # fit your LDA model with 7 topics
#' model <- fit_lda(pooled_dfm, n_topics = 7, method = "Gibbs")
#'
#  extract the most likely topics for each hashtag
#' lda_hashtags(model)
#' }

lda_hashtags <- function(lda_model) {
  data.frame(Topic = topicmodels::topics(lda_model))
}


#' View distribution of fitted LDA Models
#' @importFrom rlang .data
#' @importFrom utils install.packages
#' @description View the distribution of your fitted LDA model.
#' @param lda_model Object of class \link[topicmodels:TopicModel-class]{LDA}).
#' @param param String. Specify either "beta" to return the term distribution
#' over topics (term per document) or "gamma" for the document distribution over.
#'  topics (i.e. hashtag pool per topic probability).
#' @param tidy Logical. Specify \code{TRUE} for return distribution in tidy format (tbl).
#' @return Data frame or tbl of Term (beta) or document (gamma) distribution over topics.
#'
#' @export
#' @examples
#' \dontrun{
#'
#' library(Twitmo)
#'
#' # load tweets (included in package)
#' mytweets <- load_tweets(system.file("extdata", "tweets_20191027-141233.json", package = "Twitmo"))
#'
#' # Pool tweets into longer pseudo-documents
#' pool <- pool_tweets(data = mytweets)
#' pooled_dfm <- pool$document_term_matrix
#'
#' # fit your LDA model with 7 topics
#' model <- fit_lda(pooled_dfm, n_topics = 7, method = "Gibbs")
#'
#' # Choose either "beta" to return the term distribution
#' # over topics (term per document) or "gamma" for the document distribution over
#' # topics (hashtag pool per topic probability)
#' lda_distribution(model, param = "gamma")
#' }

lda_distribution <- function(lda_model, param = "gamma", tidy = FALSE) {

  # quietly install tidyr and tidytext if user wants results in tidy format but doesn't have the packages installed
  if (tidy|param == "beta") {
    if (!requireNamespace("tidytext", quietly = TRUE)) {
      install.packages("tidytext")
    }
    if (!requireNamespace("tidyr", quietly = TRUE)) {
      install.packages("tidyr")
    }
  }

  if (param == "beta") {
    if (is.logical(tidy)) {
      if (!tidy) {
        # % Each document (hashtag) belongs to a topic
        warning("`param = beta` has no base R support. Continuing with `tidy = TRUE`")
        res <- tidytext::tidy(lda_model, matrix = c("beta")) %>%
          tidyr::spread(.data$topic, beta)
      }

      if (tidy) {
        # View Gamma / Beta per Document in a tidy format
        # Beta = term distribution of topics (term per document)
        # Gamma = document distribution of topics (i.e. hashtag pool per topic probability)
        res <- tidytext::tidy(lda_model, matrix = c("beta")) %>%
          tidyr::spread(.data$topic, beta)
      }
    } else warning('`tidy` must be either TRUE or FALSE')
  }

  if (param == "gamma") {
    if (is.logical(tidy)) {
      if (!tidy) {
        # % Each document (hashtag) belongs to a topic
        res <- as.data.frame(lda_model@gamma, row.names = lda_model@documents) %>% round(3)
      }

      if (tidy) {
        # View Gamma / Beta per Document in a tidy format
        # Beta = term distribution of topics (term per document)
        # Gamma = document distribution of topics (i.e. hashtag pool per topic probability)
        res <- tidytext::tidy(lda_model, matrix = c("gamma")) %>%
          tidyr::spread(.data$topic, gamma)
      }
    } else warning('`tidy` must be either TRUE or FALSE')
  }

  if (exists("res")) return(res)

}

#' Predict topics of tweets using fitted LDA model
#' @description Predict topics of tweets using fitted LDA model.
#' @param lda_model Fitted LDA Model. Object of class \link[topicmodels:TopicModel-class]{LDA}.
#' @param response Type of response. Either "prob" for probabilities or "max" one topic (default).
#' @return Data frame of topic predictions or predicted probabilities per topic (see response).
#'
#' @inheritParams pool_tweets
#' @export
#' @examples
#' \dontrun{
#'
#' library(Twitmo)
#'
#' # load tweets (included in package)
#' mytweets <- load_tweets(system.file("extdata", "tweets_20191027-141233.json", package = "Twitmo"))
#'
#' # Pool tweets into longer pseudo-documents
#' pool <- pool_tweets(data = mytweets)
#' pooled_dfm <- pool$document_term_matrix
#'
#' # fit your LDA model with 7 topics
#' model <- fit_lda(pooled_dfm, n_topics = 7, method = "Gibbs")
#'
#' # Predict topics of tweets using your fitted LDA model
#' predict_lda(mytweets, model, response = "prob")
#' }

predict_lda <- function(data, lda_model,
                        response = "max",
                        remove_numbers = TRUE,
                        remove_punct = TRUE,
                        remove_symbols = TRUE,
                        remove_url = TRUE) {

  quanteda::quanteda_options(pattern_hashtag = NULL, pattern_username = NULL)

  stopifnot(is.logical(remove_numbers),
            is.logical(remove_punct),
            is.logical(remove_symbols),
            is.logical(remove_url))

  # Predict topics of tweets using fitted LDA model
  ### corpus of all tweets
  tweets.corpus <- quanteda::corpus(data,
                          meta = list(data$created_at, data$hashtags),
                          text_field = "text")

  tweets.tokens <- quanteda::tokens(tweets.corpus ,
                   what = "word1",
                   remove_punct = remove_punct,
                   remove_symbols = remove_symbols,
                   remove_numbers = remove_numbers,
                   remove_url = remove_url,
                   remove_separators = TRUE,
                   split_hyphens = FALSE,
                   include_docvars = TRUE,
                   padding = FALSE
  ) %>% quanteda::tokens_remove(quanteda::stopwords("english"))

  # dfm of all tweets
  tweets.dfm <- quanteda::dfm(tweets.tokens, tolower=TRUE)

  # convert to topic models object
  t2tm <- quanteda::convert(tweets.dfm, to="topicmodels")

  # predict topics on twitter data using fitted model
  predict.topics <- topicmodels::posterior(lda_model, t2tm)
  res <- predict.topics$topics

  if (response == "max") {
    # Predict, which tweet belongs to which topic
    res <- apply(predict.topics$topics, 1, which.max)
  }

  return(res)

}

