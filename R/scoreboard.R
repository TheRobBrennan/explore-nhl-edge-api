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
    utc_datetime <- if (!is.null(game$startTimeUTC)) ymd_hms(game$startTimeUTC) else {print("UTC DateTime NA for game:"); print(game); NA}
    local_datetime <- if (!is.null(game$venueTimezone)) with_tz(utc_datetime, NHL_EDGE_API_TIMEZONE) else {print("Local DateTime NA for game:"); print(game); NA}

    home_team_abbr <- if (!is.null(game$homeTeam.abbrev)) game$homeTeam.abbrev else {print("Home Team Abbreviation NA for game:"); print(game); NA}
    home_team_score <- if (!is.null(game$homeTeam.score)) game$homeTeam.score else {print("Home Team Score NA for game:"); print(game); NA}
    home_team_sog <- if (!is.null(game$homeTeam.sog)) game$homeTeam.sog else {print("Home Team SOG NA for game:"); print(game); NA}

    visiting_team_abbr <- if (!is.null(game$awayTeam.abbrev)) game$awayTeam.abbrev else {print("Visiting Team Abbreviation NA for game:"); print(game); NA}
    visiting_team_score <- if (!is.null(game$awayTeam.score)) game$awayTeam.score else {print("Visiting Team Score NA for game:"); print(game); NA}
    visiting_team_sog <- if (!is.null(game$awayTeam.sog)) game$awayTeam.sog else {print("Visiting Team SOG NA for game:"); print(game); NA}

    current_period <- if (!is.null(game$periodDescriptor.number)) game$periodDescriptor.number else {print("Current Period NA for game:"); print(game); NA}
    current_period_descriptor <- if (!is.null(game$gameOutcome.lastPeriodType)) game$gameOutcome.lastPeriodType else {print("Game Outcome Last Period Type Descriptor NA for game:"); print(game); NA}
    time_remaining <- if (!is.null(game$clock.timeRemaining)) game$clock.timeRemaining else {print("Time Remaining NA for game:"); print(game); NA}

    current_period_descriptor <- case_when(
      game$gameState == "FUT" ~ "",
      game$gameOutcome.lastPeriodType == "REG" ~ "FINAL",
      game$gameOutcome.lastPeriodType == "OT"  ~ "FINAL (OT)",
      game$gameOutcome.lastPeriodType == "SO"  ~ "FINAL (SO)",
      game$gameState == "OFF" ~ "IN PROGRESS",
      TRUE ~ "IN PROGRESS"  # Default case if none of the above conditions are met
    )

    data.frame(
      local_datetime,
      visiting_team_abbr,
      visiting_team_score,
      home_team_abbr,
      home_team_score,
      current_period,
      time_remaining,
      current_period_descriptor,
      visiting_team_sog,
      home_team_sog
    )
  })

  scoreboard_df <- do.call(rbind, scoreboard_df)
  return(scoreboard_df)
}

# Run the process and display the data frame
scoreboard <- process_nhl_data()
View(scoreboard)
