% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fit_stm.R
\name{fit_ctm}
\alias{fit_ctm}
\title{Fit CTM (Correlated topic model)}
\usage{
fit_ctm(pooled_dfm, n_topics = 2L, ...)
}
\arguments{
\item{pooled_dfm}{Object of class dfm (see \link[quanteda]{dfm}) containing (pooled) Tweets.}

\item{n_topics}{Integer with number of topics}

\item{...}{Additional arguments passed to \link[stm]{stm}.}
}
\value{
Object of class \link[stm]{stm}
}
\description{
Estimate a CTM topic model.
}
\examples{
\dontrun{

library(Twitmo)

# load tweets (included in package)
mytweets <- load_tweets(system.file("extdata", "tweets_20191027-141233.json", package = "Twitmo"))

# Pool tweets into longer pseudo-documents
pool <- pool_tweets(data = mytweets)
pooled_dfm <- pool$document_term_matrix

# fit your CTM with 7 topics
ctm_model <- fit_ctm(pooled_dfm, n_topics = 7)
}

}
\seealso{
\link[stm]{stm}
}
