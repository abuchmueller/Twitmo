#' Fit LDA Topic Model
#' @description
#' @usage fit_lda(pooled_dfm, n_topics)
#' @param pooled_dfm Object of class dfm (see \link[quanteda]{dfm}) containing (pooled) tweets
#' @param n_topics Integer with number of topics
#' @return Object of class \link[topicmodels:TopicModel-class]{LDA})
#'
#' @export

fit_lda <- function(pooled_dfm, n_topics) {
  ###### LDA ######
  n_topics <- n_topics
  dfm2topicmodels <- quanteda::convert(pooled_dfm, to = "topicmodels")
  lda.model <- topicmodels::LDA(dfm2topicmodels, n_topics)

  return(lda.model)

}

#' Find best LDA model
#' @description
#' @usage find_lda(pooled_dfm, search_space)
#' @param pooled_dfm object of class dfm (see \link[quanteda]{dfm}) containing (pooled) tweets
#' @param search_space Vector with number of topics to compare different models.
#' @return Plot with different metrics compared.
#'
#' @export


find_lda <- function(pooled_dfm, search_space = seq(1, 10, 2)) {

  dfm2topicmodels <- quanteda::convert(pooled_dfm, to = "topicmodels")

  # LDA Hyperparameter Tuning
  ldatuning_metrics <- ldatuning::FindTopicsNumber(dfm2topicmodels,
                                                    topics = search_space,
                                                    metrics = c("Griffiths2004",
                                                                "CaoJuan2009",
                                                                "Arun2010",
                                                                "Deveaud2014"),
                                                    method = "Gibbs"
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
lda_terms <- function(lda_model, n_terms = 10) {
  data.frame(topicmodels::terms(lda_model, n_terms))
}

#' View Documents (hashtags) heavily associated with topics
#' @description Convenience Function to extract the most likely topics for each hashtag.
#' @param lda_model Fitted LDA Model. Object of class \link[topicmodels:TopicModel-class]{LDA}).
#' @param n_terms Integer number of terms to return.
#' @return Data frame with most likely topic for each hashtag.
#' @export
lda_hashtags <- function(lda_model) {
  data.frame(Topic = topicmodels::topics(lda_model))
}


#' View distribution of fitted LDA Models
#' @description View the distribution of your fitted LDA model.
#' @usage lda_distribution(lda_model, param = "beta", tidy = FALSE).
#' @param lda_model Object of class \link[topicmodels:TopicModel-class]{LDA}).
#' @param param String. Specify either "beta" to return the term distribution.
#' over topics (term per document) or "gamma" for the document distribution over.
#'  topics (i.e. hashtag pool per topic probability).
#' @param tidy Boolean. Specify TRUE for return distribution in tidy format (tbl).
#' @return Data frame or tbl of Term (beta) or document (gamma) distribution over topics.
#'
#' @export

lda_distribution <- function(lda_model, param = "gamma", tidy = FALSE) {

  if (param == "beta") {
    if (is.logical(tidy)) {
      if (!tidy) {
        # % Each document (hashtag) belongs to a topic
        warning('beta has no base R support. Use `tidy = TRUE`')
      }

      if (tidy) {
        # View Gamma / Beta per Document in a tidy format
        # Beta = term distribution of topics (term per document)
        # Gamma = document distribution of topics (i.e. hashtag pool per topic probability)
        res <- tidytext::tidy(lda_model, matrix = c("beta")) %>%
          tidyr::spread(topic, beta)
      }
    } else warning('`tidy` must be a boolean value')
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
          tidyr::spread(topic, gamma)
      }
    } else warning('`tidy` must be a boolean value')
  }

  if (exists("res")) return(res)

}

