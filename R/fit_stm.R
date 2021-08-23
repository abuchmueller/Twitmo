#' Fit STM Topic Model
#' @description Estimate a STM topic model
#' @usage fit_stm(pooled_dfm, n_topics = 2L, ...)
#' @param pooled_dfm Object of class dfm (see \link[quanteda]{dfm}) containing (pooled) Tweets.
#' @param n_topics Integer with number of topics
#' @param meta Optional data frame of external covariates i.e. meta data.
#' By default uses favorite count, retweet count, emojis and hashtags from Tweets.
#' @param ... Additional arguments passed to \link[stm:stm]{stm}.
#' @return Object of class \link[stm:stm]{STM}
#'
#' @export


fit_stm <- function(pooled_dfm, n_topics = 2L, ...) {

  dfm2stm <- quanteda::convert(pooled_dfm, to = "stm")

  model.stm <- stm::stm(dfm2stm$documents,
                    dfm2stm$vocab,
                    K = n_topics,
                    data = dfm2stm$meta,
                   ...)

  return(model.stm)

}

#' Fit CTM Topic Model
#' @description Estimate a CTM topic model.
#' @usage fit_ctm(pooled_dfm, n_topics = 2L, ...)
#' @param pooled_dfm Object of class dfm (see \link[quanteda]{dfm}) containing (pooled) Tweets.
#' @param n_topics Integer with number of topics
#' @param ... Additional arguments passed to \link[stm:stm]{stm}.
#' @return Object of class \link[stm:stm]{STM}
#'
#' @export


fit_ctm <- function(pooled_dfm, n_topics = 2L, ...) {

  dfm2ctm <- quanteda::convert(pooled_dfm, to = "stm")

  model.ctm <- stm::stm(dfm2ctm$documents,
                        dfm2ctm$vocab,
                        K = n_topics,
                        ...)

  return(model.ctm)

}


#' Find best STM/CTM model
#' @description Gridsearch for optimal K for your STM/CTM model. Wrapper function for \link[stm]{searchK}
#' @usage find_stm(pooled_dfm, search_space = seq(4, 20, by = 2), ...)
#' @param pooled_dfm object of class dfm (see \link[quanteda]{dfm}) containing (pooled) tweets
#' @param search_space Vector with number of topics to compare different models.
#' @param ... Additional parameters passed to \link[stm]{searchK}
#' @seealso \link[stm]{searchK}
#' @return Plot with different metrics compared.
#'
#' @export


find_stm <- function(pooled_dfm, search_space = seq(4, 20, by = 2), ...) {

  dfm2stm <- quanteda::convert(pooled_dfm, to = "stm")

  idealK <- stm::searchK(dfm2stm$documents, dfm2stm$vocab, K = search_space, max.em.its = 75, ...)

  plot(idealK)

}


