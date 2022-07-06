# Version 0.1.4

- refactored the code
- added linting (`lintr`)
- added `renv`
- `pool_tweets()` now only requires a dataframe with a "hastag" and "text" column as input

# Version 0.1.3

- Fixed an issue with `fit_stm()` where n_topics hard-coded to 7
- Fixed an issue in `pool_tweets()` where it would expect a character vector instead of a logical when checking for duplicate tweets / retweets / quotes in the data

# Version 0.1.2

- Fixed an issue, where `fit_stm()` default stopwords argument would lead to an error (#26)
- Credited co-authors and advisers to the package 
