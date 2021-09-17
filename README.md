
# Twitmo <img src="man/figures/hexSticker.png" width="160px" align="right" />

<!-- badges: start -->
<!-- badges: end -->

The goal of `Twitmo` is to facilitate topic modeling in R with
Twitter data. `Twitmo` provides a broad range of methods to sample,
pre-process and visualize Tweets to make modeling the public discourse
easy and accessible. This `README` covers the most important features.
For more details use `vignette("Twitmo")`.

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

# YOU CAN CREATE YOUR GITHUB ACCESS TOKEN HERE
# https://github.com/settings/tokens
# PASTE THE STRING INTO THE AUTH_TOKEN ARGUMENT 

## install dev version of Twitmo from github
remotes::install_github("abuchmueller/Twitmo",
                        auth_token = "YOUR_TOKEN HERE")
```

## Example: Collect your tweets

Make sure you have a regular Twitter Account before start to sample your
Tweets. For more sophisticated sampling you’ll need a developer account.
Use `vignette("sampling", package = "Twitmo")` to learn more about
Twitter’s endpoints.

### Work in Progress: Use included examples for now as `get_tweets()` is not well documented.

``` r
# get_tweets()
```

## Parse your tweets

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
#>      Topic.1 Topic.2   Topic.3
#> 1   birthday    link     paola
#> 2    morning     bio      says
#> 3     people     job     puppy
#> 4      first   click        us
#> 5      music     see     today
#> 6   downtown   great      like
#> 7  knoxville  hiring beautiful
#> 8       like   crazy      life
#> 9        see covered    church
#> 10      good  waffle sometimes
```

or which hashtags are heavily associated with each topic

``` r
lda_hashtags(model)
#>                      Topic
#> mood                     3
#> motivate                 1
#> healthcare               2
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
#> tickfire                 2
#> msiclassic               1
#> nyc                      1
#> about                    1
#> joethecrane              1
#> government               2
#> ladystrut19              1
#> ladystrutaccessories     1
#> smartnews                2
#> sundaythoughts           2
#> sf100                    2
#> openhouse                3
#> springtx                 3
#> labor                    2
#> norfolk                  2
#> oprylandhotel            3
#> pharmaceutical           1
#> easthanover              2
#> sales                    2
#> scryingartist            3
#> beautifulskyz            3
#> knoxvilletn              1
#> downtownknoxville        1
#> heartofservice           1
#> youthmagnet              1
#> youthmentor              1
#> bonjour                  2
#> trump2020                3
#> spiritchat               3
#> columbia                 3
#> newcastle                1
#> oncology                 2
#> nbatwitter               2
#> detroit                  2
```

## LDA Distribution

Check the distribution of your LDA Model with

``` r
lda_distribution(model)
#>                         V1    V2    V3
#> mood                 0.002 0.002 0.996
#> motivate             0.994 0.003 0.003
#> healthcare           0.002 0.996 0.002
#> mrrbnsnathome        0.005 0.990 0.005
#> newyork              0.005 0.990 0.005
#> breakfast            0.005 0.990 0.005
#> thisismyplace        0.995 0.002 0.002
#> p4l                  0.995 0.002 0.002
#> chinup               0.010 0.010 0.979
#> sundayfunday         0.010 0.010 0.979
#> saintsgameday        0.010 0.010 0.979
#> instapuppy           0.010 0.010 0.979
#> woof                 0.010 0.010 0.979
#> tailswagging         0.010 0.010 0.979
#> tickfire             0.002 0.996 0.002
#> msiclassic           0.995 0.003 0.003
#> nyc                  0.996 0.002 0.002
#> about                0.996 0.002 0.002
#> joethecrane          0.996 0.002 0.002
#> government           0.002 0.996 0.002
#> ladystrut19          0.996 0.002 0.002
#> ladystrutaccessories 0.996 0.002 0.002
#> smartnews            0.002 0.997 0.002
#> sundaythoughts       0.001 0.997 0.001
#> sf100                0.002 0.996 0.002
#> openhouse            0.001 0.001 0.998
#> springtx             0.001 0.001 0.998
#> labor                0.470 0.528 0.002
#> norfolk              0.470 0.528 0.002
#> oprylandhotel        0.002 0.002 0.996
#> pharmaceutical       0.738 0.260 0.002
#> easthanover          0.002 0.996 0.002
#> sales                0.002 0.996 0.002
#> scryingartist        0.002 0.002 0.996
#> beautifulskyz        0.002 0.002 0.996
#> knoxvilletn          0.994 0.003 0.003
#> downtownknoxville    0.994 0.003 0.003
#> heartofservice       0.990 0.005 0.005
#> youthmagnet          0.990 0.005 0.005
#> youthmentor          0.990 0.005 0.005
#> bonjour              0.003 0.994 0.003
#> trump2020            0.003 0.003 0.994
#> spiritchat           0.002 0.002 0.997
#> columbia             0.002 0.265 0.733
#> newcastle            0.996 0.002 0.002
#> oncology             0.002 0.996 0.002
#> nbatwitter           0.001 0.997 0.001
#> detroit              0.002 0.995 0.002
```

## Visualize with `LDAvis`

Hint: Make sure you have `servr` package installed.

``` r
to_ldavis(model, pool.corpus, pool.dfm)
```
