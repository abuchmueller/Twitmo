#' Prepare for Tweets for topic modeling by pooling
#' @description Pools tweets by hashtags using cosine similarity to create
#' longer pseudo-documents for better LDA estimation and creates n-gram tokens.
#' The method applies an implementation of the pooling algorithm from Mehrotra et al. 2013.
#' @details This function pools parsed stream into hashtags.
#' @param data Data frame of parsed tweets either by using `parse_stream()` or
#' `jsonlite::stream_in()` and `rtweet::tweets_with_users(s)`.
#' @return List with corpus object and dfm object of pooled tweets.
#'
#' @export

# TODO: Remove Emojis from Corpus
# TODO: Add STM Support
# TODO: Add Emojis to STM Metadata
# TODO: Create a class for pooled tweets.
# TODO: specify min pool size


pool_tweets <- function(data,
                        remove_numbers = TRUE,
                        remove_punct = TRUE,
                        remove_symbols = TRUE,
                        remove_url = TRUE,
                        remove_separators = TRUE,
                        cosine_threshold = 0.8) {

  quanteda::quanteda_options(pattern_hashtag = NULL, pattern_username = NULL)

  stopifnot(is.logical(remove_numbers),
            is.logical(remove_punct),
            is.logical(remove_symbols),
            is.logical(remove_url),
            is.logical(remove_separators))


  cat("\n")
  cat(nrow(data), "Tweets found", sep = " ")

  # all tweets with hashtags
  all_tweets_w_hashtags <- data[which(nchar(data$hashtags) >= 0), ]

  # all tweets without hashtags
  all_tweets_no_ht <- data[which(is.na(data$hashtags)), ]

  cat("\n")
  cat("Pooling", nrow(all_tweets_w_hashtags), "Tweets with Hashtags", sep = " ")

  hashtags.unique <- lapply(data$hashtags, unique)
  hashtags.unique  <- unique(hashtags.unique)
  cat("\n")
  cat(length(hashtags.unique), "Unique Hashtags found", sep = " ")

  cat("\n")
  cat('Begin pooling ...')


  # add single-point latitude and longitude variables to tweets data
  a <- rtweet::lat_lng(data)

  # removing duplicates, removing quoted tweets and retweets
  a <- a[a$is_quote == "FALSE" & a$is_retweet == FALSE, ]

  # drop unnecessary cols
  a <- a[c("created_at", "text", "hashtags", "bbox_coords", "lat", "lng", "location")]

  #unfold/explode twitter data by hashtags
  b <- a %>%
    tidyr::unnest(c(hashtags))

  ## group tweets by hashtags
  c <- b %>%
    dplyr::group_by(hashtags) %>%
    dplyr::summarise(text)

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
  ## 1. TF-IDF Matrices of Pools

  # using quanteda
  doc.corpus <- quanteda::corpus(document_hashtag_pools,
                       meta = document_hashtag_pools$hashtags,
                       text_field = 'tweets_pooled')

  quanteda::docnames(doc.corpus) <- document_hashtag_pools$hashtags

  tokens.pooled <- quanteda::tokens(doc.corpus,
                                    what = "word1",
                                    remove_punct = remove_punct,
                                    remove_symbols = remove_symbols,
                                    remove_numbers = remove_numbers,
                                    remove_url = remove_url,
                                    remove_separators = remove_separators,
                                    split_hyphens = FALSE,
                                    include_docvars = TRUE,
                                    padding = FALSE
  ) %>% quanteda::tokens_remove(quanteda::stopwords("english"))

  pooled.dfm <-
    quanteda::dfm(tokens.pooled,  tolower = TRUE) %>%
    quanteda::dfm_trim() %>%
    quanteda::dfm_tfidf(.)

  ## 2. TF-IDF Matrices of unpooled tweets

  # tweets without hashtags
  c.nohashtag <- c[which(is.na(c$hashtags)), ]

  unpooled.corpus <- quanteda::corpus(c.nohashtag, text_field = 'text')

  tokens.unpooled <- quanteda::tokens(unpooled.corpus ,
                                    what = "word1",
                                    remove_punct = remove_punct,
                                    remove_symbols = remove_symbols,
                                    remove_numbers = remove_numbers,
                                    remove_url = remove_url,
                                    remove_separators = remove_separators,
                                    split_hyphens = FALSE,
                                    include_docvars = TRUE,
                                    padding = FALSE
  ) %>% quanteda::tokens_remove(quanteda::stopwords("english"))

  unpooled.dfm <-
    quanteda::dfm(tokens.unpooled,  tolower = TRUE) %>%
    quanteda::dfm_trim() %>%
    quanteda::dfm_tfidf(.)

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
          paste(document_hashtag_pools[document_hashtag_pools["hashtags"] == as.character(i), "tweets_pooled"], c.nohashtag[as.character(j), 'text'])
      }
    }
  }


  ## Recalculate new after enrichment
  doc.corpus <- quanteda::corpus(document_hashtag_pools,
                       meta = document_hashtag_pools$hashtags,
                       text_field = 'tweets_pooled')

  quanteda::docnames(doc.corpus) <- document_hashtag_pools$hashtags

  tokens.final <- quanteda::tokens(doc.corpus,
                                    what = "word1",
                                    remove_punct = remove_punct,
                                    remove_symbols = remove_symbols,
                                    remove_numbers = remove_numbers,
                                    remove_url = remove_url,
                                    remove_separators = remove_separators,
                                    split_hyphens = FALSE,
                                    include_docvars = TRUE,
                                    padding = FALSE
  ) %>% quanteda::tokens_remove(quanteda::stopwords("english"))

  # Final pooled dfm
  pooled.dfm <- quanteda::dfm(tokens.final,  tolower = TRUE)

  ret_list <- list("data" = a,
                   "tokens" = tokens.final,
                   "corpus" = doc.corpus,
                   "document_term_matrix" = pooled.dfm)
  cat('Done')
  return(ret_list)
}



