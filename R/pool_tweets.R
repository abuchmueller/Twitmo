#' Prepare Tweets for topic modeling by pooling
#' @importFrom rlang .data
#' @importFrom stats na.omit
#' @details Pools tweets by hashtags using cosine similarity to create
#' longer pseudo-documents for better LDA estimation and creates n-gram tokens.
#' The method applies an implementation of the pooling algorithm from Mehrotra et al. 2013.
#' @description This function pools a data frame of parsed tweets into document pools.
#' @param data Data frame of parsed tweets. Obtained either by using \code{\link{load_tweets}}  or
#' \code{\link[jsonlite]{stream_in}} in conjunction with \code{\link[rtweet]{tweets_with_users}}.
#' @param remove_numbers Logical. If TRUE remove tokens that consist only of numbers,
#' but not words that start with digits, e.g. 2day. See \link[quanteda]{tokens}.
#' @param remove_punct Logical. If TRUE remove all characters in the Unicode
#' "Punctuation" [P] class, with exceptions for those used as prefixes for valid social media tags if
#' \code{preserve_tags = TRUE}. See \link[quanteda]{tokens}
#' @param remove_symbols Logical. If TRUE remove all characters in the Unicode "Symbol" [S] class (e.g. emojis)
#' @param remove_url Logical. If TRUE find and eliminate URLs beginning with http(s).
#' See \link[quanteda]{tokens}.
#' @param remove_separators Logical. If TRUE remove separators and separator characters
#' (Unicode "Separator" [Z] and "Control" [C] categories). See \link[quanteda]{tokens}.
#' @param stopwords a character vector, list of character vectors, \link[quanteda]{dictionary}
#' or collocations object. See \link[quanteda]{pattern} for details.
#' Defaults to \link[stopwords:stopwords]{stopwords("english")}.
#' @param n_grams Integer vector specifying the number of elements to be concatenated in each n-gram.
#' Each element of this vector will define a n in the n-gram(s) that are produced. See \link[quanteda]{tokens_ngrams}
#' @param remove_emojis Logical. If TRUE all emojis will be removed from tweets but keeps other symbols.
#' @param cosine_threshold Double. Value between 0 and 1 specifying the cosine similarity used
#' for document pooling. Tweets without a hashtag will be assigned to document (hashtag) pools
#' based upon this metric. Low thresholds will reduce topic coherence by including
#' a large number of tweets without a hashtag into the document pools. Higher thresholds will lead
#' to more coherent topics but will reduce document sizes.
#'
#' @return List with \link[quanteda]{corpus} object and \link[quanteda]{dfm} object of pooled tweets.
#' @references Mehrotra, Rishabh & Sanner, Scott & Buntine, Wray & Xie, Lexing. (2013).
#' Improving LDA Topic Models for Microblogs via Tweet Pooling and Automatic Labeling.
#' 889-892. 10.1145/2484028.2484166.
#' @seealso \link[quanteda]{tokens}, \link[quanteda]{dfm}
#'
#' @export

# TODO: add meta data to dfm objects

pool_tweets <- function(data,
                        remove_numbers = TRUE,
                        remove_punct = TRUE,
                        remove_symbols = TRUE,
                        remove_url = TRUE,
                        remove_separators = TRUE,
                        remove_emojis = TRUE,
                        cosine_threshold = 0.8,
                        stopwords = "en",
                        n_grams = 1L) {

  quanteda::quanteda_options(pattern_hashtag = NULL, pattern_username = NULL)

  if (missing(data)) stop("Missing data frame with parsed tweets")

  n_grams <- as.integer(n_grams)
  min_pool_size <- as.integer(min_pool_size)

  stopifnot(is.logical(remove_numbers),
            is.logical(remove_punct),
            is.logical(remove_symbols),
            is.logical(remove_url),
            is.logical(remove_separators),
            is.logical(remove_emojis),
            is.double(cosine_threshold),
            is.integer(n_grams),
            cosine_threshold >= 0.01 && cosine_threshold <= 1)

  if (cosine_threshold <= 0.2) {

    invisible(readline(prompt = "Low cosine thresholds can increase calculation time and memory usage significantly and even lead to crashes.
Press [enter] to continue or [control+c] to abort"))

    warning("Please be aware that your cosine threshold is low.
  Low cosine thresholds lead to incoherent topics due to
  document pool dillution by too tweets without hashtags.
  For coherent topics we recommend thresholds of 0.8 or higher.")
  }

  # Local stopwords + additional Twitter stopwords
  if (is.character(stopwords)) stopwords <- c(stopwords::stopwords(stopwords), "amp", "na", "rt", "via")
  if (missing(stopwords)) stopwords <- c(stopwords::stopwords("en"), "amp", "na", "rt", "via")

  cat("\n")
  cat(nrow(data), "Tweets total", sep = " ")

  # all tweets with hashtags
  tweets_w_hashtags <- data[which(nchar(data$hashtags) >= 0), ]

  # all tweets without hashtags
  tweets_no_hashtags <- data[which(is.na(data$hashtags)), ]

  cat("\n")
  cat(nrow(tweets_no_hashtags), "Tweets without hashtag", sep = " ")

  cat("\n")
  cat("Pooling", nrow(tweets_w_hashtags), "Tweets with hashtags #", sep = " ")

  hashtags.unique <- unlist(data$hashtags)
  hashtags.unique  <- unique(hashtags.unique)
  hashtags.unique <- hashtags.unique[!is.na(hashtags.unique)]
  cat("\n")
  cat(length(hashtags.unique), "Unique hashtags total", sep = " ")

  cat("\n")
  cat("Begin pooling ...")

  # add single-point latitude and longitude variables to tweets data
  a <- rtweet::lat_lng(data)

  # extract emoji vector
  a$emojis <- stringr::str_extract_all(a$text, emojis_regex, simplify = FALSE)

  # remove emojis from tweets
  if (remove_emojis) {
    a$text <- stringr::str_remove_all(a$text, emojis_regex)
  }

  # remove URLs
  if (remove_url) {
    a$text <- stringr::str_replace_all(a$text, "https://t.co/[a-z,A-Z,0-9]*","")
  }

  # remove hashtags
  if (remove_symbols) {
    a$text <- stringr::str_replace_all(a$text,"#[a-z,A-Z,_]*","")

    # remove references to usernames
    a$text <- stringr::str_replace_all(a$text,"@[a-z,A-Z,_]*","")
  }

  # remove duplicates quoted tweets and retweets
  a <- a[a$is_quote == "FALSE" & a$is_retweet == FALSE, ]

  # pre-selection of metadata for stm modeling
  a <- a[c("created_at", "text", "hashtags", "favorite_count", "retweet_count", "quote_count",
           "reply_count", "quoted_friends_count", "favourites_count", "friends_count",
           "followers_count", "screen_name")]

  #unfold/explode twitter data by hashtags
  b <- a %>%
    tidyr::unnest(.data$hashtags)

  ## group tweets by hashtags
  c <- b %>%
    dplyr::group_by(.data$hashtags) %>%
    dplyr::summarise(text = paste0(.data$text, collapse = " "))

  # collect unique hashtags
  df <- data.frame(
    doc_id = unique(tolower(na.omit(unlist(a$hashtags)))) %>%
      seq_along %>%
      paste0("doc", .data),
    hashtags = unique(tolower(na.omit(unlist(a$hashtags))))
  )

  # combine into docs (by hashtag)
  c$hashtags <- tolower(c$hashtags)

  # create hashtag pools by joining tweets with same hashtags
  # each tweet can be assigned to multiple pools
  # this is explicitly allowed

  d <- c %>%
    na.omit() %>%
    dplyr::group_by(.data$hashtags) %>%
    dplyr::mutate(tweets_pooled = paste0(.data$text, collapse = " ")) %>%
    dplyr::distinct(.data$hashtags, .data$tweets_pooled)

  # join document hashtag dataframe with pooled tweets dataframe
  document_hashtag_pools <- dplyr::inner_join(df, d, by = "hashtags")

  ## TF-IDF Vectorization ----
  # Calculate TF-IDF matrices for document pools ----

  # using quanteda
  doc.corpus <- quanteda::corpus(document_hashtag_pools,
                       meta = document_hashtag_pools$hashtags,
                       text_field = "tweets_pooled")

  quanteda::docnames(doc.corpus) <- document_hashtag_pools$hashtags

  tokens.pooled <- quanteda::tokens(doc.corpus,
                                    what = "word",
                                    remove_url = remove_url,
                                    remove_punct = remove_punct,
                                    remove_symbols = remove_symbols,
                                    remove_numbers = remove_numbers,
                                    remove_separators = remove_separators,
                                    split_hyphens = FALSE,
                                    include_docvars = TRUE,
                                    padding = FALSE
  ) %>% quanteda::tokens_remove(stopwords) %>% quanteda::tokens_ngrams(n = n_grams)


  pooled.dfm <-
    quanteda::dfm(tokens.pooled, tolower = TRUE) %>%
    quanteda::dfm_trim(.) %>%
    quanteda::dfm_tfidf(.)

  # Calculate TF-IDF matrices for unpooled tweets ----

  # tweets without hashtags
  b.nohashtag <- b[which(is.na(b$hashtags)), ]

  unpooled.corpus <- quanteda::corpus(b.nohashtag, text_field = "text")

  tokens.unpooled <- quanteda::tokens(unpooled.corpus ,
                                    what = "word",
                                    remove_url = remove_url,
                                    remove_punct = remove_punct,
                                    remove_symbols = remove_symbols,
                                    remove_numbers = remove_numbers,
                                    remove_separators = remove_separators,
                                    split_hyphens = FALSE,
                                    include_docvars = TRUE,
                                    padding = FALSE
  ) %>% quanteda::tokens_remove(stopwords) %>% quanteda::tokens_ngrams(n = n_grams)

  unpooled.dfm <-
    quanteda::dfm(tokens.unpooled,  tolower = TRUE) %>%
    quanteda::dfm_trim(.) %>%
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
          paste(document_hashtag_pools[document_hashtag_pools["hashtags"] == as.character(i), "tweets_pooled"], b.nohashtag[as.character(j), "text"])
      }
    }
  }


  ## Recalculate document frequency matrices after pooling
  doc.corpus <- quanteda::corpus(document_hashtag_pools,
                       meta = document_hashtag_pools$hashtags,
                       text_field = 'tweets_pooled')

  quanteda::docnames(doc.corpus) <- document_hashtag_pools$hashtags

  tokens.final <- quanteda::tokens(doc.corpus,
                                    what = "word",
                                    remove_url = remove_url,
                                    remove_punct = remove_punct,
                                    remove_symbols = remove_symbols,
                                    remove_numbers = remove_numbers,
                                    remove_separators = remove_separators,
                                    split_hyphens = FALSE,
                                    include_docvars = TRUE,
                                    padding = FALSE
  ) %>% quanteda::tokens_remove(stopwords) %>% quanteda::tokens_ngrams(n = n_grams)

  # Final pooled document frequency matrix
  pooled.dfm <- quanteda::dfm(tokens.final,  tolower = TRUE)

  hashtag.freq <- a$hashtags[!is.na(a$hashtags)] %>% unlist %>% tolower() %>% plyr::count() %>%
    dplyr::arrange(-.data$freq) %>% dplyr::as_tibble() %>% dplyr::rename(hashtag = .data$x, count = .data$freq)

  ret_list <- list("meta" = a,
                   "hashtags" = hashtag.freq,
                   "tokens" = tokens.final,
                   "corpus" = doc.corpus,
                   "document_term_matrix" = pooled.dfm)
  cat("Done\n")

  return(ret_list)

}

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))

