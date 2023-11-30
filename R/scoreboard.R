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

    # Setting the current period
    current_period <- if (!is.null(game$periodDescriptor.number)) {
        period <- game$periodDescriptor.number
        if (!is.null(game$clock.inIntermission)) {
          inIntermission <- game$clock.inIntermission

          print(paste("Game ID:", game$id, " has an inIntermission value of: ", inIntermission))
          print(inIntermission)

          # Create a logical vector to index non-NA elements in 'inIntermission'
          non_na_index <- !is.na(inIntermission)

          # Append " (INT)" to 'period' where 'inIntermission' is TRUE and not NA
          period[non_na_index & inIntermission] <- paste0(period[non_na_index & inIntermission], " INT")

          # Return the vector of 'period' values
          period
        } else {
            period
        }
    } else {
        NA  # No current period information
    }

    # TODO: We can probably remove this sometime soon once we have the current_period corrected
    current_period_descriptor <- if (!is.null(game$periodDescriptor.periodType)) game$periodDescriptor.periodType else {print("Game Outcome Last Period Type Descriptor NA for game:"); print(game); NA}

    # TODO: This is correct. DO NOT CHANGE OR DELETE.
    time_remaining <- if (!is.null(game$clock.timeRemaining)) {
      game$clock.timeRemaining
    } else {
      NA  # No time remaining information or the game has not started
    }

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

# Function to fetch and process NHL Edge API data stored in a local file
process_nhl_data_from_file <- function() {
  # Path to the JSON file
  json_file <- "data/score-now-20231129.json"

  # Read the JSON file
  data <- fromJSON(json_file, flatten = TRUE)
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

    # TODO: Fix the display of intermission values
    # Setting the current period
    current_period <- if (!is.null(game$periodDescriptor.number)) {
        period <- game$periodDescriptor.number
        if (!is.null(game$clock.inIntermission)) {
          inIntermission <- game$clock.inIntermission

          print(paste("Game ID:", game$id, " has an inIntermission value of: ", inIntermission))
          print(inIntermission)

          # Create a logical vector to index non-NA elements in 'inIntermission'
          non_na_index <- !is.na(inIntermission)

          # Append " (INT)" to 'period' where 'inIntermission' is TRUE and not NA
          period[non_na_index & inIntermission] <- paste0(period[non_na_index & inIntermission], " INT")

          # Return the vector of 'period' values
          period
        } else {
            print(paste("Game ID:", game$id, " is not in intermission."))
            period
        }
    } else {
        print(paste("Game ID:", game$id, " has not started."))
        NA  # No current period information
    }

    # TODO: We can probably remove this sometime soon once we have the current_period corrected
    current_period_descriptor <- if (!is.null(game$periodDescriptor.periodType)) game$periodDescriptor.periodType else {print("Game Outcome Last Period Type Descriptor NA for game:"); print(game); NA}

    # TODO: This is correct. DO NOT CHANGE OR DELETE.
    time_remaining <- if (!is.null(game$clock.timeRemaining)) {
      game$clock.timeRemaining
    } else {
      NA  # No time remaining information or the game has not started
    }

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

# TODO: Refactor so that we can either load data from the live URL or use a specific file
# Run the process and display the data frame
scoreboard <- process_nhl_data()
# scoreboard <- process_nhl_data_from_file()

# Display the scoreboard
View(scoreboard)
