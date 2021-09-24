#' Create interactive visualization with LDAvis
#' @description Converts \link[topicmodels:TopicModel-class]{LDA} topic model to LDAvis compatible json string and starts server.
#' May require \code{servr} Package to run properly. For conversion of \link[stm:stm]{STM} topic models use \link[stm]{toLDAvis}.
#' @importFrom utils install.packages
#' @param fitted Fitted LDA Model. Object of class \link[topicmodels:TopicModel-class]{LDA})
#' @param corpus Document corpus. Object of class \link[quanteda:corpus]{corpus})
#' @param doc_term document term matrix (dtm).
#' @details Beware that \code{to_ldavis} might fail if the corpus contains documents that consist ONLY of numbers,
#' emojis or punctuation e.g. do not contain a single character string. This is due to a limitation in the \code{topicmodels} package
#' used for model fitting that does not consider such terms as words and omits them causing the posterior to differ in length from the corpus.
#' If you encounter such an error, redo your pre-processing and exclude emojis, punctuation and numbers.
#' When using \code{\link{pool_tweets}} you can remove emojis by specifying \code{remove_emojis = TRUE}.
#' @return Invisible Object (see \link[LDAvis]{serVis})).
#'
#' @export
#' @seealso \link[stm]{toLDAvis}
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
#' pooled_corp <- pool$corpus
#'
#' # fit your LDA model with 7 topics
#' model <- fit_lda(pooled_dfm, n_topics = 7, method = "Gibbs")
#'
#' # Explore your topics with LDAvis
#' to_ldavis(model, pooled_corp, pooled_dfm)
#' }

to_ldavis <- function(fitted, corpus, doc_term){

  # check for dependencies
  if (!requireNamespace("LDAvis", quietly = TRUE)) {
    install.packages("LDAvis")
  }

  if (!requireNamespace("tm", quietly = TRUE)) {
    install.packages("tm")
  }

  if (!requireNamespace("stringi", quietly = TRUE)) {
    install.packages("stringi")
  }

  ## Conversion of quanteda objects onto their tm counterparts

  # Convert our quanteda corpus to a tm corpus object for LDAvis
  corpus <- quanteda::convert(corpus, to="data.frame")
  corpus <- tm::SimpleCorpus(tm::DataframeSource(corpus),
                                    control = list(language = "en"))
  #  Convert quanteda dfm to tm document term matrix
  doc_term <- quanteda::convert(doc_term, to="tm")

  # Find required quantities
  phi <- modeltools::posterior(fitted)$terms %>% as.matrix
  phi[phi == 0] <- 1e-16 # Workaround since phi cannot be 0 for PCA
  theta <- modeltools::posterior(fitted)$topics %>% as.matrix
  vocab <- colnames(phi)
  doc_length <- vector()
  for (i in 1:length(corpus)) {
    temp <- paste(corpus[[i]]$content, collapse = " ")
    doc_length <- c(doc_length, stringi::stri_count(temp, regex = "\\S+"))
  }
  temp_frequency <- as.data.frame(as.matrix(doc_term))
  freq_matrix <- data.frame(ST = colnames(temp_frequency),
                            Freq = colSums(temp_frequency))
  rm(temp_frequency)

  # Convert to json
  json_lda <- LDAvis::createJSON(phi = phi, theta = theta,
                                 vocab = vocab,
                                 doc.length = doc_length,
                                 term.frequency = freq_matrix$Freq)

  LDAvis::serVis(json = json_lda,
                 out.dir = tempfile())

}
