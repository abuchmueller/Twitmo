% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fit_lda.R
\name{lda_terms}
\alias{lda_terms}
\title{View Terms heavily associated with each topic}
\usage{
lda_terms(lda_model, n_terms = 10)
}
\arguments{
\item{lda_model}{Fitted LDA Model. Object of class \link[topicmodels:TopicModel-class]{LDA}).}

\item{n_terms}{Integer number of terms to return.}
}
\value{
Data frame with top n terms for each topic.
}
\description{
Convenience Function to extract the most likely terms for each topic.
}
\examples{
\dontrun{

library(Twitmo)

# load tweets (included in package)
mytweets <- load_tweets(system.file("extdata", "tweets_20191027-141233.json", package = "Twitmo"))

# Pool tweets into longer pseudo-documents
pool <- pool_tweets(data = mytweets)
pooled_dfm <- pool$document_term_matrix

# fit your LDA model with 7 topics
model <- fit_lda(pooled_dfm, n_topics = 7, method = "Gibbs")

}

}
