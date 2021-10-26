## Resubmission
This is a resubmission. In this version I have:

* Written package names, software names and API names in single quotes in title and description.

* Added missing \value to load_tweets.Rd describing the output.

* Fixed unexecutable code in man/plot_hashtag.Rd.

* Added on.exit() calls to `plot_hashtag` and `plot_tweets` functions in plots.R to ensure users options are not changed by function calls to those functions.

## R CMD check results
There were no ERRORs, WARNINGs or NOTEs.

