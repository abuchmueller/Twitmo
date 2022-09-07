## Resubmission

This is a resubmission. In this version I have:

-   `Twitmo` 0.1. depends on `rtweet` < 1.0.0 now (breaking changes)
-   added linting via `lintr`
-   added `renv`
-   `pool_tweets()` now only requires a data frame with a "hashtag" and "text" column as input
-   added remotes field to description (explanation below)

This package depends on `rtweet`, which has introduced breaking changes in it's release v1.0.0.
Since R does not adhere to an upper boundary lower current version of a package specified in description 
the remotes field is necessary used to ensure `rtweet` v0.7.0 (the latest version with which `Twitmo` works) 
is installed otherwise CRAN users will not be able to use this package in full.
This is only temporary until the next major version of `Twitmo` v0.2, currently under development.


## R CMD check results

There were no ERRORs, WARNINGs or NOTEs.

