
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
#>    Topic.1         Topic.2  Topic.3
#> 1      see            like     link
#> 2   church           music      bio
#> 3      job        downtown      job
#> 4    today       knoxville    paola
#> 5    great           crazy     says
#> 6  morning         covered    puppy
#> 7    click          waffle birthday
#> 8      bio          sooooo    click
#> 9     link 9ten_restaurant      see
#> 10    team  9tenrestaurant   hiring
```

or which hashtags are heavily associated with each topic

``` r
lda_hashtags(model)
#>                      Topic
#> mood                     1
#> motivate                 1
#> healthcare               1
#> mrrbnsnathome            2
#> newyork                  2
#> breakfast                2
#> thisismyplace            1
#> p4l                      1
#> chinup                   3
#> sundayfunday             3
#> saintsgameday            3
#> instapuppy               3
#> woof                     3
#> tailswagging             3
#> tickfire                 3
#> msiclassic               1
#> nyc                      3
#> about                    3
#> joethecrane              3
#> government               1
#> ladystrut19              2
#> ladystrutaccessories     2
#> smartnews                1
#> sundaythoughts           2
#> sf100                    2
#> openhouse                1
#> springtx                 1
#> labor                    3
#> norfolk                  3
#> oprylandhotel            2
#> pharmaceutical           3
#> easthanover              3
#> sales                    3
#> scryingartist            2
#> beautifulskyz            2
#> knoxvilletn              2
#> downtownknoxville        2
#> heartofservice           3
#> youthmagnet              3
#> youthmentor              3
#> bonjour                  2
#> trump2020                1
#> spiritchat               3
#> columbia                 3
#> newcastle                2
#> oncology                 1
#> nbatwitter               2
#> detroit                  3
```

## LDA Distribution

Check the distribution of your LDA Model with

``` r
lda_distribution(model)
#>                         V1    V2    V3
#> mood                 0.997 0.001 0.001
#> motivate             0.996 0.002 0.002
#> healthcare           0.642 0.001 0.357
#> mrrbnsnathome        0.004 0.993 0.004
#> newyork              0.004 0.993 0.004
#> breakfast            0.004 0.993 0.004
#> thisismyplace        0.997 0.002 0.002
#> p4l                  0.997 0.002 0.002
#> chinup               0.007 0.007 0.986
#> sundayfunday         0.007 0.007 0.986
#> saintsgameday        0.007 0.007 0.986
#> instapuppy           0.007 0.007 0.986
#> woof                 0.007 0.007 0.986
#> tailswagging         0.007 0.007 0.986
#> tickfire             0.001 0.001 0.997
#> msiclassic           0.996 0.002 0.002
#> nyc                  0.001 0.001 0.998
#> about                0.001 0.001 0.998
#> joethecrane          0.001 0.001 0.998
#> government           0.997 0.001 0.001
#> ladystrut19          0.001 0.997 0.001
#> ladystrutaccessories 0.001 0.997 0.001
#> smartnews            0.998 0.001 0.001
#> sundaythoughts       0.001 0.998 0.001
#> sf100                0.001 0.997 0.001
#> openhouse            0.999 0.001 0.001
#> springtx             0.999 0.001 0.001
#> labor                0.002 0.002 0.997
#> norfolk              0.002 0.002 0.997
#> oprylandhotel        0.001 0.997 0.001
#> pharmaceutical       0.001 0.001 0.997
#> easthanover          0.001 0.001 0.997
#> sales                0.001 0.001 0.997
#> scryingartist        0.001 0.997 0.001
#> beautifulskyz        0.001 0.997 0.001
#> knoxvilletn          0.002 0.996 0.002
#> downtownknoxville    0.002 0.996 0.002
#> heartofservice       0.004 0.004 0.993
#> youthmagnet          0.004 0.004 0.993
#> youthmentor          0.004 0.004 0.993
#> bonjour              0.002 0.996 0.002
#> trump2020            0.996 0.002 0.002
#> spiritchat           0.001 0.001 0.998
#> columbia             0.001 0.001 0.997
#> newcastle            0.001 0.998 0.001
#> oncology             0.997 0.001 0.001
#> nbatwitter           0.001 0.998 0.001
#> detroit              0.002 0.002 0.997
```

## Visualize with `LDAvis`

Make sure you have `servr` package installed.

``` r
to_ldavis(model, pool.corpus, pool.dfm)
```
