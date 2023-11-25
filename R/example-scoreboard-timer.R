# Installing the packages
# install.packages("httr")
# install.packages("jsonlite")
# install.packages("dplyr")    # The %>% is no longer natively supported by the R language
# install.packages("lubridate")

# Load necessary libraries
library(httr)
library(jsonlite)
library(dplyr)
library(lubridate)

THREE_MINUTES_IN_SECONDS <- 60 * 3
DELAY_IN_SECONDS <- THREE_MINUTES_IN_SECONDS
# DELAY_IN_SECONDS <- 15
EXECUTION_ATTEMPTS <- 1
EMPTY_SPACES <- "    "

# Load scoreboards
NHL_SCOREBOARD_SCRIPT <- sprintf("%s/R/scoreboard.R", getwd())

while (TRUE) {
  print(paste("Refreshing NHL scoreboard data at", Sys.time(), "- Attempt #", EXECUTION_ATTEMPTS))

  # Remove data frames before refreshing scoreboard data
  if (exists("scoreboard")) {
    try(rm(scoreboard), silent = TRUE)
  }
  
  # Read in the source files
  source(NHL_SCOREBOARD_SCRIPT)

  if (exists("scoreboard")) {
    # Check if the data frame contains at least one row of data (fixes a bug where a day range is specified where games do NOT exist - 2023.04.07 is an example)
    if (nrow(scoreboard) > 0) {
      print(paste(EMPTY_SPACES, "-> NHL scoreboard available at", Sys.time()))
      View(scoreboard)
    } else {
      print("The scoreboard data frame exists, but it does not contain any data.")
    }
  }

  # Wait for at least X seconds
  Sys.sleep(DELAY_IN_SECONDS)

  # Increment our counter
  EXECUTION_ATTEMPTS <- EXECUTION_ATTEMPTS + 1
}
