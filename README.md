
# Twitmo <img src="man/figures/hexSticker.png" width="160px" align="right" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/abuchmueller/Twitmo/workflows/R-CMD-check/badge.svg)](https://github.com/abuchmueller/Twitmo/actions)
<!-- badges: end -->

The goal of `Twitmo` is to facilitate topic modeling in R with Twitter
data. `Twitmo` provides a broad range of methods to sample, pre-process
and visualize Tweets to make modeling the public discourse easy and
accessible. This `README` covers the most important features. For more
details use `vignette("Twitmo")`.

## Installation

You can install `Twitmo` from CRAN with:

``` r
install.packages("Twitmo")
```

You can install `Twitmo` from github with:

Before you install from Github make sure you have Rtools for
[Windows](https://cran.r-project.org/bin/windows/Rtools/ "Rtools for Windows (CRAN)")
or
[macOS](https://thecoatlessprofessor.com/programming/cpp/r-compiler-tools-for-rcpp-on-macos/ "Rtools for macOS")
already installed.

``` r
## install remotes package if it's not already
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

## install dev version of Twitmo from github
remotes::install_github("abuchmueller/Twitmo")
```

## Example: Collect your tweets

Make sure you have a regular Twitter Account before start to sample your
Tweets. For more sophisticated sampling you’ll need a developer account.
Use `vignette("sampling", package = "Twitmo")` to learn more about
Twitter’s endpoints.

``` r
# Live stream Tweets from the UK for 30 seconds and save to "uk_tweets.json" in current working directory
get_tweets(method = 'stream', location = "GBR", timeout = 30, file_name = "uk_tweets.json")

# Use your own bounding box to stream US mainland Tweets
get_tweets(method = 'stream', 
           location =   c(-125, 26, -65, 49), 
           timeout = 30,
           file_name = "tweets_from_us_mainland.json")
```

## Parse your tweets from a json file

``` r
dat <- load_tweets("inst/extdata/tweets_20191027-141233.json")
#> opening file input connection.
#>  Found 167 records... Found 193 records... Imported 193 records. Simplifying...
#> closing file input connection.
```

## Pool tweets into document pools

``` r
pool <- pool_tweets(dat)
#> 
#> 193 Tweets total
#> 158 Tweets without hashtag
#> Pooling 35 Tweets with hashtags #
#> 56 Unique hashtags total
#> Begin pooling ...Done
pool.corpus <- pool$corpus
```

``` r
pool.dfm <- pool$document_term_matrix
```

## Find optimal number of topics

``` r
find_lda(pool.dfm)
#> Warning: `guides(<scale> = FALSE)` is deprecated. Please use `guides(<scale> = "none")` instead.
```

![](man/figures/README-ldatuner-1.png)<!-- -->

## Fit LDA model

``` r
model <- fit_lda(pool.dfm, n_topics = 3)
```

## View most relevant terms for each topic

``` r
lda_terms(model)
#>     Topic.1 Topic.2   Topic.3
#> 1      link morning      like
#> 2       bio  church  downtown
#> 3       job   music knoxville
#> 4     click   today beautiful
#> 5     paola     see     today
#> 6      says   place      life
#> 7     puppy    life    laurel
#> 8  birthday     day      glen
#> 9       see    team  trailing
#> 10   hiring  sunday      oaks
```

or which hashtags are heavily associated with each topic

``` r
lda_hashtags(model)
#>                      Topic
#> mood                     2
#> motivate                 3
#> healthcare               1
#> mrrbnsnathome            1
#> newyork                  1
#> breakfast                1
#> thisismyplace            2
#> p4l                      2
#> chinup                   1
#> sundayfunday             1
#> saintsgameday            1
#> instapuppy               1
#> woof                     1
#> tailswagging             1
#> tickfire                 2
#> msiclassic               2
#> nyc                      1
#> about                    1
#> joethecrane              1
#> government               1
#> ladystrut19              2
#> ladystrutaccessories     2
#> smartnews                2
#> sundaythoughts           2
#> sf100                    2
#> openhouse                3
#> springtx                 3
#> labor                    1
#> norfolk                  1
#> oprylandhotel            3
#> pharmaceutical           3
#> easthanover              1
#> sales                    1
#> scryingartist            3
#> beautifulskyz            3
#> knoxvilletn              3
#> downtownknoxville        3
#> heartofservice           1
#> youthmagnet              1
#> youthmentor              1
#> bonjour                  3
#> trump2020                2
#> spiritchat               1
#> columbia                 1
#> newcastle                1
#> oncology                 1
#> nbatwitter               2
#> detroit                  1
```

## LDA Distribution

Check the distribution of your LDA Model with

``` r
lda_distribution(model)
#>                         V1    V2    V3
#> mood                 0.001 0.997 0.001
#> motivate             0.002 0.002 0.996
#> healthcare           0.997 0.001 0.001
#> mrrbnsnathome        0.993 0.004 0.004
#> newyork              0.993 0.004 0.004
#> breakfast            0.993 0.004 0.004
#> thisismyplace        0.002 0.997 0.002
#> p4l                  0.002 0.997 0.002
#> chinup               0.986 0.007 0.007
#> sundayfunday         0.986 0.007 0.007
#> saintsgameday        0.986 0.007 0.007
#> instapuppy           0.986 0.007 0.007
#> woof                 0.986 0.007 0.007
#> tailswagging         0.986 0.007 0.007
#> tickfire             0.001 0.997 0.001
#> msiclassic           0.002 0.996 0.002
#> nyc                  0.998 0.001 0.001
#> about                0.998 0.001 0.001
#> joethecrane          0.998 0.001 0.001
#> government           0.997 0.001 0.001
#> ladystrut19          0.001 0.997 0.001
#> ladystrutaccessories 0.001 0.997 0.001
#> smartnews            0.001 0.998 0.001
#> sundaythoughts       0.001 0.998 0.001
#> sf100                0.001 0.997 0.001
#> openhouse            0.001 0.001 0.999
#> springtx             0.001 0.001 0.999
#> labor                0.997 0.002 0.002
#> norfolk              0.997 0.002 0.002
#> oprylandhotel        0.001 0.001 0.997
#> pharmaceutical       0.341 0.001 0.658
#> easthanover          0.997 0.001 0.001
#> sales                0.997 0.001 0.001
#> scryingartist        0.001 0.001 0.997
#> beautifulskyz        0.001 0.001 0.997
#> knoxvilletn          0.002 0.002 0.996
#> downtownknoxville    0.002 0.002 0.996
#> heartofservice       0.993 0.004 0.004
#> youthmagnet          0.993 0.004 0.004
#> youthmentor          0.993 0.004 0.004
#> bonjour              0.002 0.002 0.996
#> trump2020            0.002 0.996 0.002
#> spiritchat           0.998 0.001 0.001
#> columbia             0.997 0.001 0.001
#> newcastle            0.998 0.001 0.001
#> oncology             0.997 0.001 0.001
#> nbatwitter           0.001 0.998 0.001
#> detroit              0.997 0.002 0.002
```

## Visualize with `LDAvis`

Hint: Make sure you have `servr` package installed.

``` r
to_ldavis(model, pool.corpus, pool.dfm)
```
