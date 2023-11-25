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
  data <- fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE)
  games <- list(data$games)  # Assuming 'data' contains your example JSON structure

  scoreboard_df <- lapply(games, function(game) {
    utc_datetime <- if (!is.null(game$startTimeUTC)) ymd_hms(game$startTimeUTC) else NA
    local_datetime <- if (!is.null(game$venueTimezone)) with_tz(utc_datetime, game$venueTimezone) else NA

    home_team_abbr <- if (!is.null(game$homeTeam$abbrev)) game$homeTeam$abbrev else NA
    home_team_name <- if (!is.null(game$homeTeam$name$default)) game$homeTeam$name$default else NA

    visiting_team_abbr <- if (!is.null(game$awayTeam$abbrev)) game$awayTeam$abbrev else NA
    visiting_team_name <- if (!is.null(game$awayTeam$name$default)) game$awayTeam$name$default else NA

    current_period <- if (!is.null(game$period)) game$period else NA
    time_remaining <- if (!is.null(game$clock$timeRemaining)) game$clock$timeRemaining else NA

    home_team_sog <- if (!is.null(game$homeTeam$sog)) game$homeTeam$sog else NA
    visiting_team_sog <- if (!is.null(game$awayTeam$sog)) game$awayTeam$sog else NA

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
