#' Prepare for Tweets for topic modeling by pooling (experimental)
#' @description This version of \link[TweetLocViz]{pool_tweets} allows the use of
#' external tokenizers.
#' @details This function pools a data frame of parsed tweets into document pools.
#' @usage pool_tweets(data, tokenizer = tokenizers::tokenize_tweets())
#' @param TFUN A tokenizer function of your choice e.g. \code{tokenizers::tokenize_tweets()}.
#' First argument of your tokenizer must be character vector or a list of character vectors to be tokenized.
#' External tokenizers have to be compatible to the quanteda See \link[quanteda]{tokens} constructor,
#' i.e. must output one of the following: a (uniquely) named list of characters;
#' a \link[quanteda]{tokens} object; or a See \link[quanteda]{corpus} or \link[base]{character} object to be tokenized.
#' @inheritParams pool_tweets
#' @return List with corpus object and \link[quanteda]{dfm} object of pooled tweets.
#'

# TODO: ADD EXPORT WHEN DONE
# TODO: Wie übergibt man die Tweets and den Tokenizer und sorgt? Wie gibt man weitere Argument an den Tokenizer? Dots?
# TODO: Add STM Support - return emojis and more metadata for stm
# TODO: Create a class for pooled tweets.
# TODO: customizeable min pool size
# TODO: n-gram support for tokenizer

pool_tweets2 <- function(data,
                         TFUN,
                         cosine_threshold = 0.8,
                         min_pool_size = 1) {

  quanteda::quanteda_options(pattern_hashtag = NULL, pattern_username = NULL)

  stopifnot(!missing(tokenizer))

  cat("\n")
  cat(nrow(data), "Tweets found", sep = " ")

  # all tweets with hashtags
  all_tweets_w_hashtags <- data[which(nchar(data$hashtags) >= 0), ]

  # all tweets without hashtags
  all_tweets_no_ht <- data[which(is.na(data$hashtags)), ]

  cat("\n")
  cat("Pooling", nrow(all_tweets_w_hashtags), "Tweets with Hashtags", sep = " ")

  hashtags.unique <- unlist(data$hashtags)
  hashtags.unique  <- unique(hashtags.unique)
  hashtags.unique <- hashtags.unique[!is.na(hashtags.unique)]
  cat("\n")
  cat(length(hashtags.unique), "Unique Hashtags found", sep = " ")

  cat("\n")
  cat("Begin pooling ...")

  # add single-point latitude and longitude variables to tweets data
  a <- rtweet::lat_lng(data)

  # extract emoji vector
  a$emojis <- emo::ji_extract_all(a$text)

  # remove emojis from corpus
  if (!include_emojis) {
    a$text <- remove_emojis(a$text)
  }

  # removing duplicates, removing quoted tweets and retweets
  a <- a[a$is_quote == "FALSE" & a$is_retweet == FALSE, ]

  # drop unnecessary cols
  a <- a[c("created_at", "text", "hashtags", "bbox_coords", "lat", "lng", "location", "emojis")]

  #unfold/explode twitter data by hashtags
  b <- a %>%
    tidyr::unnest(c(hashtags))

  ## group tweets by hashtags
  c <- b %>%
    dplyr::group_by(hashtags) %>%
    dplyr::summarise(text = paste0(text, collapse = " "))

  # collect unique hashtags
  df <- data.frame(
    doc_id = unique(tolower(na.omit(unlist(a$hashtags)))) %>%
      seq_along %>%
      paste0("doc",.),
    hashtags = unique(tolower(na.omit(unlist(a$hashtags))))
  )

  # combine into docs (by hashtag)
  c$hashtags <- tolower(c$hashtags)

  # create hashtag pools by joining tweets with same hashtags
  # each tweet can be assigned to multiple pools
  # this is explicitly allowed

  d <- c %>%
    na.omit() %>%
    dplyr::group_by(hashtags) %>%
    dplyr::mutate(tweets_pooled = paste0(text, collapse = " ")) %>%
    dplyr::distinct(hashtags, tweets_pooled)

  # join document hashtag dataframe with pooled tweets dataframe
  document_hashtag_pools <- dplyr::inner_join(df, d, by = "hashtags")

  ##### TF-IDF Vectorization
  ## 1. TF-IDF Matrices of Pools ----

  ## using external tokenizer
  # tokenize using external tokenizer
  ext.tokens <- tokenizer(document_hashtag_pools$tweets_pooled,
                          stopwords = stopwords)

  # convert to quanteda tokens object
  ext.tokens <- quanteda::tokens(ext.tokens)

  # create dfm
  pooled.dfm <-
    dfm(ext.tokens) %>%
    dfm_trim() %>%
    dfm_tfidf(.)

  ## 2. TF-IDF Matrices of unpooled tweets ----

  # tweets without hashtags
  c.nohashtag <- c[which(is.na(c$hashtags)), ]

  # tokenize unpooled tweets using external tokenizer
  ext.tokens.unpooled <- tokenizer(c.nohashtag$text,
                                   stopwords = stopwords)

  # convert to quanteda tokens object
  ext.tokens.unpooled <- quanteda::tokens(ext.tokens.unpooled)

  # create dfm
  unpooled.dfm <-
    dfm(ext.tokens.unpooled) %>%
    dfm_trim() %>%
    dfm_tfidf(.)

  # calculate cosine similarities between pooled tweets and tweets without hashtags
  h <- suppressWarnings(quanteda.textstats::textstat_simil(pooled.dfm,
                                                           unpooled.dfm,
                                                           margin = "documents",
                                                           method = "cosine"))

  # sample tweets using cosine threshold
  O <- as.data.frame(h)
  tt <- O[O$cosine >= cosine_threshold, ]

  # append tweets passing threshold to corresponding hashtag pools
  # skip if no tweets pass the similarity threshold
  if (!is.na(tt[1,1])) {
    for (i in tt) {
      for (j in tt) {
        document_hashtag_pools[document_hashtag_pools["hashtags"] == as.character(i), "tweets_pooled"] <-
          paste(document_hashtag_pools[document_hashtag_pools["hashtags"] == as.character(i), "tweets_pooled"], c.nohashtag[as.character(j), "text"])
      }
    }
  }


  ## Recalculate new after enrichment ----

  # tokenize using external tokenizer
  ext.tokens.final <- tokenizer(document_hashtag_pools$tweets_pooled,
                                stopwords = stopwords)

  # convert to quanteda tokens object
  ext.tokens.final <- quanteda::tokens(ext.tokens.final)

  # Final pooled document frequency matrix
  pooled.dfm <- dfm(ext.tokens.final, tolower = TRUE)

  ret_list <- list("data" = a,
                   "tokens" = tokens.final,
                   "corpus" = doc.corpus,
                   "document_term_matrix" = pooled.dfm)
  cat("Done")
  return(ret_list)
}
