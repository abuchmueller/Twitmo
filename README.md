
# Twitmo <img src="man/figures/hexSticker.png" width="160px" align="right" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/abuchmueller/Twitmo/workflows/R-CMD-check/badge.svg)](https://github.com/abuchmueller/Twitmo/actions)
[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
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
Tweets.

``` r
# Live stream Tweets from the UK for 30 seconds and save to "uk_tweets.json" in current working directory
get_tweets(method = 'stream', 
           location = "GBR", 
           timeout = 30, 
           file_name = "uk_tweets.json")

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
#>      Topic.1   Topic.2  Topic.3
#> 1        job     paola birthday
#> 2       link      says     life
#> 3        bio     puppy   church
#> 4        see     music     meet
#> 5      click  downtown     last
#> 6     hiring knoxville     good
#> 7        can     today     time
#> 8  recommend      team    today
#> 9     anyone   morning       us
#> 10     great    season   people
```

or which hashtags are heavily associated with each topic

``` r
lda_hashtags(model)
#>                      Topic
#> mood                     3
#> motivate                 2
#> healthcare               1
#> mrrbnsnathome            1
#> newyork                  1
#> breakfast                1
#> thisismyplace            3
#> p4l                      3
#> chinup                   2
#> sundayfunday             2
#> saintsgameday            2
#> instapuppy               2
#> woof                     2
#> tailswagging             2
#> tickfire                 1
#> msiclassic               2
#> nyc                      3
#> about                    3
#> joethecrane              3
#> government               1
#> ladystrut19              2
#> ladystrutaccessories     2
#> smartnews                2
#> sundaythoughts           3
#> sf100                    3
#> openhouse                2
#> springtx                 2
#> labor                    1
#> norfolk                  1
#> oprylandhotel            3
#> pharmaceutical           1
#> easthanover              1
#> sales                    1
#> scryingartist            3
#> beautifulskyz            3
#> knoxvilletn              2
#> downtownknoxville        2
#> heartofservice           3
#> youthmagnet              3
#> youthmentor              3
#> bonjour                  1
#> trump2020                3
#> spiritchat               3
#> columbia                 3
#> newcastle                1
#> oncology                 1
#> nbatwitter               1
#> detroit                  1
```

## LDA Distribution

Check the distribution of your LDA Model with

``` r
lda_distribution(model)
#>                         V1    V2    V3
#> mood                 0.001 0.001 0.997
#> motivate             0.002 0.996 0.002
#> healthcare           0.998 0.001 0.001
#> mrrbnsnathome        0.993 0.003 0.003
#> newyork              0.993 0.003 0.003
#> breakfast            0.993 0.003 0.003
#> thisismyplace        0.002 0.002 0.997
#> p4l                  0.002 0.002 0.997
#> chinup               0.007 0.986 0.007
#> sundayfunday         0.007 0.986 0.007
#> saintsgameday        0.007 0.986 0.007
#> instapuppy           0.007 0.986 0.007
#> woof                 0.007 0.986 0.007
#> tailswagging         0.007 0.986 0.007
#> tickfire             0.998 0.001 0.001
#> msiclassic           0.002 0.997 0.002
#> nyc                  0.001 0.001 0.998
#> about                0.001 0.001 0.998
#> joethecrane          0.001 0.001 0.998
#> government           0.997 0.001 0.001
#> ladystrut19          0.001 0.998 0.001
#> ladystrutaccessories 0.001 0.998 0.001
#> smartnews            0.001 0.998 0.001
#> sundaythoughts       0.001 0.001 0.998
#> sf100                0.001 0.001 0.997
#> openhouse            0.001 0.999 0.001
#> springtx             0.001 0.999 0.001
#> labor                0.997 0.001 0.001
#> norfolk              0.997 0.001 0.001
#> oprylandhotel        0.001 0.001 0.997
#> pharmaceutical       0.997 0.001 0.001
#> easthanover          0.997 0.001 0.001
#> sales                0.997 0.001 0.001
#> scryingartist        0.001 0.001 0.998
#> beautifulskyz        0.001 0.001 0.998
#> knoxvilletn          0.002 0.996 0.002
#> downtownknoxville    0.002 0.996 0.002
#> heartofservice       0.003 0.003 0.993
#> youthmagnet          0.003 0.003 0.993
#> youthmentor          0.003 0.003 0.993
#> bonjour              0.996 0.002 0.002
#> trump2020            0.002 0.002 0.996
#> spiritchat           0.001 0.001 0.998
#> columbia             0.294 0.001 0.705
#> newcastle            0.998 0.001 0.001
#> oncology             0.997 0.001 0.001
#> nbatwitter           0.998 0.001 0.001
#> detroit              0.997 0.002 0.002
```

## Visualize with `LDAvis`

Make sure you have `servr` package installed.

``` r
to_ldavis(model, pool.corpus, pool.dfm)
```
