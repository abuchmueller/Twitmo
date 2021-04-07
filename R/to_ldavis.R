#' Create interactive visualization with LDAvis
#' @description Helper function. Converts topic model to LDAvis compatabile json string.
#' May requires \code{servr} to run properly.
#' @usage to_ldavis(fitted, corpus, doc_term).
#' @param fitted Fitted LDA Model. Object of class \link[topicmodels:TopicModel-class]{LDA})
#' @param corpus Document corpus. Object of class \link[quanteda:corpus]{corpus})
#' @param doc_term document term matrix (dtm).
#' @return Invisible Object (see \link[LDAvis]{serVis})).
#'
#' @export
#'

to_ldavis <- function(fitted, corpus, doc_term){
  # Required packages
  library(topicmodels)
  library(dplyr)
  library(stringi)
  library(tm)
  library(LDAvis)

  # Conversion of quanteda objects onto their tm counterparts
  # TODO: Test class atrribute
  # Convert our quanteda corpus to a tm corpus object for LDAvis
  corpus <- quanteda::convert(corpus, to="data.frame")
  corpus <- tm::SimpleCorpus(tm::DataframeSource(corpus),
                                    control = list(language = "en"))
  #  Convert quanteda dfm to tm document term matrix
  doc_term <- quanteda::convert(doc_term, to="tm")

  # Find required quantities
  phi <- posterior(fitted)$terms %>% as.matrix
  theta <- posterior(fitted)$topics %>% as.matrix
  vocab <- colnames(phi)
  doc_length <- vector()
  for (i in 1:length(corpus)) {
    temp <- paste(corpus[[i]]$content, collapse = ' ')
    doc_length <- c(doc_length, stri_count(temp, regex = '\\S+'))
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



