# Load necessary libraries
library(httr)
library(jsonlite)
library(dplyr)
library(lubridate)

# Source the constants file
source("R/constants.R")

# Function to fetch and process NHL Edge API data
process_nhl_data <- function() {
  # Fetch data from the NHL Edge API
  response <- GET(NHL_EDGE_API_SCOREBOARD_URL)
  data <- fromJSON(content(response, "text"), flatten = TRUE)
  games <- data$games

  scoreboard_df <- lapply(games, function(game) {
    # Uncomment the next line to print the structure of each game object
    # str(game)

    # Initialize variables
    utc_datetime <- NA
    local_datetime <- NA
    home_team_abbr <- NA
    home_team_name <- NA
    visiting_team_abbr <- NA
    visiting_team_name <- NA
    current_period <- NA
    time_remaining <- NA
    home_team_sog <- NA
    visiting_team_sog <- NA

  # Check if necessary fields are not NULL and set variables
  if (!is.null(game["startTimeUTC"])) {
    utc_string <- as.character(game["startTimeUTC"][[1]])
    utc_datetime <- ymd_hms(utc_string)

    if (!is.null(game["venueTimezone"]) && game["venueTimezone"][[1]] %in% OlsonNames()) {
      timezone_string <- as.character(game["venueTimezone"][[1]])
      local_datetime <- with_tz(utc_datetime, timezone_string)
    } else {
      local_datetime <- NA  # Assign NA if the timezone is not valid
    }
  }
  if (!is.null(game["homeTeam"]) && !is.null(game["homeTeam"]["abbrev"])) {
    home_team_abbr <- game["homeTeam"]["abbrev"][1]
    home_team_name <- game["homeTeam"]["name"]["default"][1]
  }
  # TODO: Left off here. Fix based on the homeTeam code above and using ChatGPT
  if (!is.null(game["awayTeam"]) && !is.null(game["awayTeam"][["abbrev"]])) {
    visiting_team_abbr <- game["awayTeam"][["abbrev"]][[1]]
    visiting_team_name <- game["awayTeam"][["name"]][["default"]][[1]]
  }
  if (!is.null(game["period"])) {
    current_period <- game["period"][[1]]
  }
  if (!is.null(game["clock"]) && !is.null(game["clock"][["timeRemaining"]])) {
    time_remaining <- game["clock"][["timeRemaining"]][[1]]
  }
  if (!is.null(game["homeTeam"]) && !is.null(game["homeTeam"][["sog"]])) {
    home_team_sog <- game["homeTeam"][["sog"]][[1]]
  }
  if (!is.null(game["awayTeam"]) && !is.null(game["awayTeam"][["sog"]])) {
    visiting_team_sog <- game["awayTeam"][["sog"]][[1]]
  }

    # Return a data frame with the variables
    data.frame(
      utc_datetime,
      local_datetime,
      home_team_abbr,
      home_team_name,
      visiting_team_abbr,
      visiting_team_name,
      current_period,
      time_remaining,
      home_team_sog,
      visiting_team_sog
    )
  })

  scoreboard_df <- do.call(rbind, scoreboard_df)
  return(scoreboard_df)
}

# Run the process and display the data frame
scoreboard <- process_nhl_data()
View(scoreboard)
