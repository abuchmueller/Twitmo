
# TweetLocViz

The goal of `TweetLocViz` is to facilitate topic modeling in R with
Twitter data. `TweetLocViz` provides a broad range of methods to sample,
pre-process and visualize Tweets to make modeling the public discourse
easy and accessible. This `README` covers the most important features.
For more details use `vignette("TweetLocViz")`.

## Installation

You can install `TweetLocViz` from CRAN with:

``` r
install.packages("TweetLocViz")
```

You can install `TweetLocViz` from github with:

Before you install from github make sure you have Rtools for
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

## install dev version of TweetLocViz from github
remotes::install_github("abuchmueller/TweetLocViz",
                        auth_token = "YOUR_TOKEN HERE")
```

## Example: Collect your tweets

Make sure you have a regular Twitter Account before start to sample your
Tweets. For more sophisticated sampling you’ll need a developer account.
Use `vignette("sampling", package = "TweetLocViz")` to learn more about
Twitter’s endpoints.

### Work in Progress: Use included examples for now as `get_tweets()` is not well documented.

``` r
# get_tweets()
```

## Parse your tweets

``` r
dat <- parse_stream("inst/extdata/tweets 20191027-141233.json")
#> opening file input connection.
#>  Found 167 records... Found 193 records... Imported 193 records. Simplifying...
#> closing file input connection.
```

## Pool tweets into document pools

``` r
pool <- pool_tweets(dat)
#> 
#> 193 Tweets found
#> Pooling 35 Tweets with Hashtags
#> 36 Unique Hashtags found
#> Begin pooling ...Done
pool.corpus <- pool$corpus
```

``` r
pool.dfm <- pool$document_term_matrix
```

## Find optimal number of topics

``` r
find_lda(pool.dfm)
```

![](figures/ldatuner-1.png)<!-- -->

## Fit LDA model

``` r
model <- fit_lda(pool.dfm, n_topics = 3)
```

## View most relevant terms for each topic

``` r
lda_terms(model)
#>      Topic.1        Topic.2   Topic.3
#> 1      today #puppiesatplay      link
#> 2     people          paola       bio
#> 3       last           says       job
#> 4        amp        #chinup       see
#> 5   downtown  #sundayfunday     click
#> 6  knoxville #saintsgameday    church
#> 7       meet    #instapuppy       can
#> 8      crazy          #woof recommend
#> 9    covered  #tailswagging    anyone
#> 10    waffle          puppy     great
```

or which hashtags are heavily associated with each topic

``` r
lda_hashtags(model)
#>                      Topic
#> mood                     3
#> motivate                 1
#> healthcare               3
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
#> msiclassic               3
#> nyc                      1
#> about                    1
#> joethecrane              1
#> government               3
#> ladystrut19              2
#> ladystrutaccessories     2
#> smartnews                3
#> sundaythoughts           1
#> sf100                    3
#> openhouse                1
#> springtx                 1
#> labor                    3
#> norfolk                  3
#> oprylandhotel            1
#> pharmaceutical           2
#> easthanover              1
#> sales                    1
#> scryingartist            2
#> beautifulskyz            2
#> knoxvilletn              1
#> downtownknoxville        1
#> heartofservice           2
#> youthmagnet              2
#> youthmentor              2
#> bonjour                  2
#> trump2020                3
#> spiritchat               2
#> columbia                 3
#> newcastle                1
#> oncology                 3
#> nbatwitter               1
#> detroit                  3
```

## LDA Distribution

Check the distribution of your LDA Model with

``` r
lda_distribution(model)
#>                         V1    V2    V3
#> mood                 0.001 0.001 0.998
#> motivate             0.996 0.002 0.002
#> healthcare           0.001 0.001 0.997
#> mrrbnsnathome        0.997 0.001 0.001
#> newyork              0.997 0.001 0.001
#> breakfast            0.997 0.001 0.001
#> thisismyplace        0.002 0.002 0.996
#> p4l                  0.002 0.002 0.996
#> chinup               0.002 0.997 0.002
#> sundayfunday         0.002 0.997 0.002
#> saintsgameday        0.002 0.997 0.002
#> instapuppy           0.002 0.997 0.002
#> woof                 0.002 0.997 0.002
#> tailswagging         0.002 0.997 0.002
#> tickfire             0.997 0.001 0.001
#> msiclassic           0.001 0.001 0.998
#> nyc                  0.998 0.001 0.001
#> about                0.998 0.001 0.001
#> joethecrane          0.998 0.001 0.001
#> government           0.002 0.002 0.997
#> ladystrut19          0.001 0.998 0.001
#> ladystrutaccessories 0.001 0.998 0.001
#> smartnews            0.001 0.001 0.997
#> sundaythoughts       0.998 0.001 0.001
#> sf100                0.001 0.001 0.997
#> openhouse            0.998 0.001 0.001
#> springtx             0.998 0.001 0.001
#> labor                0.002 0.002 0.997
#> norfolk              0.002 0.002 0.997
#> oprylandhotel        0.997 0.001 0.001
#> pharmaceutical       0.001 0.763 0.236
#> easthanover          0.853 0.001 0.146
#> sales                0.853 0.001 0.146
#> scryingartist        0.001 0.997 0.001
#> beautifulskyz        0.001 0.997 0.001
#> knoxvilletn          0.997 0.002 0.002
#> downtownknoxville    0.997 0.002 0.002
#> heartofservice       0.001 0.998 0.001
#> youthmagnet          0.001 0.998 0.001
#> youthmentor          0.001 0.998 0.001
#> bonjour              0.002 0.996 0.002
#> trump2020            0.002 0.002 0.996
#> spiritchat           0.001 0.998 0.001
#> columbia             0.001 0.001 0.997
#> newcastle            0.997 0.001 0.001
#> oncology             0.002 0.002 0.997
#> nbatwitter           0.998 0.001 0.001
#> detroit              0.002 0.002 0.996
```

## Visualize with `LDAvis`

Hint: Make sure you have `servr` package installed.

``` r
to_ldavis(model, pool.corpus, pool.dfm)
```
