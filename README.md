
# Twitmo <img src="man/figures/hexSticker.png" width="160px" align="right"/>

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

## Example: Collect geo-tagged Tweets

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
           location = c(-125, 26, -65, 49), 
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
pool.dfm <- pool$document_term_matrix
```

## Find optimal number of topics

``` r
find_lda(pool.dfm)
```

![](man/figures/README-ldatuner-1.png)<!-- -->

## Fit LDA model

``` r
model <- fit_lda(pool.dfm, n_topics = 7)
```

## View most relevant terms for each topic

``` r
lda_terms(model)
#>      Topic.1 Topic.2 Topic.3 Topic.4   Topic.5         Topic.6   Topic.7
#> 1      today   paola morning    meet      link        birthday      life
#> 2     laurel    says   music  people       bio           crazy     today
#> 3       glen   puppy     see   first     click         covered    season
#> 4   trailing      us  church     big       job          waffle beautiful
#> 5       oaks    grow  sunday  always       see          sooooo      like
#> 6    tuscany  empire    yall    love  downtown 9ten_restaurant   posting
#> 7         ii    find     9am    last knoxville  9tenrestaurant      olde
#> 8     design  people    word   night       can            time       end
#> 9  perfectly   build    15am     fun recommend            girl      days
#> 10     sized    team general    good    anyone           happy    grains
```

or which hashtags are heavily associated with each topic

``` r
lda_hashtags(model)
#>                      Topic
#> mood                     6
#> motivate                 2
#> healthcare               5
#> mrrbnsnathome            6
#> newyork                  6
#> breakfast                6
#> thisismyplace            3
#> p4l                      3
#> chinup                   2
#> sundayfunday             2
#> saintsgameday            2
#> instapuppy               2
#> woof                     2
#> tailswagging             2
#> tickfire                 6
#> msiclassic               7
#> nyc                      4
#> about                    4
#> joethecrane              4
#> government               5
#> ladystrut19              3
#> ladystrutaccessories     3
#> smartnews                3
#> sundaythoughts           7
#> sf100                    3
#> openhouse                1
#> springtx                 1
#> labor                    5
#> norfolk                  5
#> oprylandhotel            3
#> pharmaceutical           5
#> easthanover              4
#> sales                    4
#> scryingartist            7
#> beautifulskyz            7
#> knoxvilletn              5
#> downtownknoxville        5
#> heartofservice           6
#> youthmagnet              6
#> youthmentor              6
#> bonjour                  2
#> trump2020                5
#> spiritchat               2
#> columbia                 5
#> newcastle                6
#> oncology                 3
#> nbatwitter               1
#> detroit                  5
```

## LDA Distribution

Check the distribution of your LDA Model with

``` r
lda_distribution(model)
#>                         V1    V2    V3    V4    V5    V6    V7
#> mood                 0.001 0.001 0.001 0.001 0.001 0.996 0.001
#> motivate             0.001 0.993 0.001 0.001 0.001 0.001 0.001
#> healthcare           0.001 0.001 0.001 0.001 0.996 0.001 0.001
#> mrrbnsnathome        0.002 0.002 0.002 0.002 0.002 0.989 0.002
#> newyork              0.002 0.002 0.002 0.002 0.002 0.989 0.002
#> breakfast            0.002 0.002 0.002 0.002 0.002 0.989 0.002
#> thisismyplace        0.001 0.001 0.995 0.001 0.001 0.001 0.001
#> p4l                  0.001 0.001 0.995 0.001 0.001 0.001 0.001
#> chinup               0.004 0.978 0.004 0.004 0.004 0.004 0.004
#> sundayfunday         0.004 0.978 0.004 0.004 0.004 0.004 0.004
#> saintsgameday        0.004 0.978 0.004 0.004 0.004 0.004 0.004
#> instapuppy           0.004 0.978 0.004 0.004 0.004 0.004 0.004
#> woof                 0.004 0.978 0.004 0.004 0.004 0.004 0.004
#> tailswagging         0.004 0.978 0.004 0.004 0.004 0.004 0.004
#> tickfire             0.001 0.001 0.001 0.001 0.001 0.996 0.001
#> msiclassic           0.001 0.001 0.001 0.001 0.001 0.001 0.994
#> nyc                  0.001 0.001 0.001 0.996 0.001 0.001 0.001
#> about                0.001 0.001 0.001 0.996 0.001 0.001 0.001
#> joethecrane          0.001 0.001 0.001 0.996 0.001 0.001 0.001
#> government           0.001 0.001 0.001 0.001 0.995 0.001 0.001
#> ladystrut19          0.001 0.001 0.996 0.001 0.001 0.001 0.001
#> ladystrutaccessories 0.001 0.001 0.996 0.001 0.001 0.001 0.001
#> smartnews            0.001 0.001 0.997 0.001 0.001 0.001 0.001
#> sundaythoughts       0.000 0.000 0.000 0.000 0.000 0.000 0.997
#> sf100                0.001 0.001 0.995 0.001 0.001 0.001 0.001
#> openhouse            0.998 0.000 0.000 0.000 0.000 0.000 0.000
#> springtx             0.998 0.000 0.000 0.000 0.000 0.000 0.000
#> labor                0.001 0.001 0.001 0.001 0.995 0.001 0.001
#> norfolk              0.001 0.001 0.001 0.001 0.995 0.001 0.001
#> oprylandhotel        0.001 0.001 0.995 0.001 0.001 0.001 0.001
#> pharmaceutical       0.001 0.001 0.001 0.001 0.996 0.001 0.001
#> easthanover          0.001 0.001 0.001 0.996 0.001 0.001 0.001
#> sales                0.001 0.001 0.001 0.996 0.001 0.001 0.001
#> scryingartist        0.001 0.001 0.001 0.001 0.001 0.001 0.996
#> beautifulskyz        0.001 0.001 0.001 0.001 0.001 0.001 0.996
#> knoxvilletn          0.001 0.001 0.001 0.001 0.994 0.001 0.001
#> downtownknoxville    0.001 0.001 0.001 0.001 0.994 0.001 0.001
#> heartofservice       0.002 0.002 0.002 0.002 0.002 0.989 0.002
#> youthmagnet          0.002 0.002 0.002 0.002 0.002 0.989 0.002
#> youthmentor          0.002 0.002 0.002 0.002 0.002 0.989 0.002
#> bonjour              0.001 0.994 0.001 0.001 0.001 0.001 0.001
#> trump2020            0.001 0.001 0.001 0.001 0.993 0.001 0.001
#> spiritchat           0.001 0.997 0.001 0.001 0.001 0.001 0.001
#> columbia             0.001 0.001 0.001 0.001 0.996 0.001 0.001
#> newcastle            0.001 0.001 0.001 0.001 0.001 0.996 0.001
#> oncology             0.001 0.001 0.499 0.001 0.497 0.001 0.001
#> nbatwitter           0.997 0.000 0.000 0.000 0.000 0.000 0.000
#> detroit              0.001 0.001 0.001 0.001 0.995 0.001 0.001
```

## Visualize with `LDAvis`

Make sure you have `servr` package installed.

``` r
to_ldavis(model, pool.corpus, pool.dfm)
```

![](man/figures/to_ldavis.png)
