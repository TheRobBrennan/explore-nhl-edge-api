# Instructions

The NHL R scoreboard is a project initially intended to explore the NHL Edge API.

## Background

The code base for the NHL R scoreboard is publicly available in a GitHub repository at [https://github.com/TheRobBrennan/explore-nhl-edge-api](https://github.com/TheRobBrennan/explore-nhl-edge-api)

This project was initially created when the previous NHL stats API [https://statsapi.web.nhl.com/api/v1](https://statsapi.web.nhl.com/api/v1) was deprecated on November 7th, 2023.

This change completely broke my NHL shot chart - available publicly in a GitHub repository at [https://github.com/SplooshAI/sploosh-ai-nhl-shot-chart](https://github.com/SplooshAI/sploosh-ai-nhl-shot-chart). Plans are underway to rewrite the NHL shot chart to accommodate the new endpoints and data structure - though no release date has been identified.

The base URL for the NHL Edge API is [https://api-web.nhle.com/v1/](https://api-web.nhle.com/v1/).

The NHL Edge API is undocumented. However, there is a publicly available repository on GitHub at [https://github.com/Zmalski/NHL-API-Reference](https://github.com/Zmalski/NHL-API-Reference) that shares endpoints and data as discovered by other developers.

## Project structure

This project is primarily developed using [Posit RStudio IDE](https://posit.co/products/open-source/rstudio/) and [VS Code](https://code.visualstudio.com/) with the following structure:

- `explore-nhl-edge-api.Rproj` - The main project file that can be opened using RStudio.
- `README.md` - The main project README
- `/data` - This folder contains example JSON files from example requests to [https://api-web.nhle.com/v1/score/now](https://api-web.nhle.com/v1/score/now)
- `/openai` - This folder contains example Markdown files used to build and interact with a custom OpenAI GPT
- `/R` - This folder contains source code for this project - which has been written in R.
- `/R/constants.R` - This R script contains constants for the project including settings for controlling debugging output, automatically calcuating today's date, definining the base URL for NHL Edge API requests, and a default timezone set to my preferred Pacific timezone.
- `/R/example-scoreboard-timer.R` - This R script is the main script to launch the program. It periodically runs `scoreboard.R` and displays the `scoreboard` data frame if it contains at least one row.
- `/R/scoreboard.R` - This R script invokes a complex `process_nhl_data` function and displays the `scoreboard` data frame.

When this project is modified or enhanced, most of the work occurs within `/R/scoreboard.R`

Users should be prompted to share the latest source code before any suggestions, feedback, or example code enhancements are shared.

### constants.R

```r
# Set DEBUG_VERBOSE to true if you would like to see details logged to the console (such as scoreboard_df game details)

DEBUG_VERBOSE <- FALSE

# Get today's date in the format YYYY-MM-DD

todays_date <- format(Sys.Date(), "%Y-%m-%d")

NHL_EDGE_API_BASE_URL <- "<https://api-web.nhle.com/v1>"

NHL_EDGE_API_SCOREBOARD_URL <- paste0(NHL_EDGE_API_BASE_URL, "/score/now")

# NHL_EDGE_API_SCOREBOARD_URL <- paste0(NHL_EDGE_API_BASE_URL, "/score/", todays_date)

NHL_EDGE_API_TIMEZONE <- "America/Los_Angeles"
```

### example-scoreboard-timer.R

```r
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
EXECUTION_ATTEMPTS <- 1
EMPTY_SPACES <- "    "

# Load scoreboards
NHL_SCOREBOARD_SCRIPT <- sprintf("%s/R/scoreboard.R", getwd())

while (TRUE) {
  # Format Sys.time() to display with six-digit precision
  print(paste("Refreshing NHL scoreboard data at", format(Sys.time(), "%Y-%m-%d %H:%M:%OS6"), "- Attempt #", EXECUTION_ATTEMPTS))

  # Remove data frames before refreshing scoreboard data
  if (exists("scoreboard")) {
    try(rm(scoreboard), silent = TRUE)
  }
  
  # Read in the source files

  # Pass EXECUTION_ATTEMPTS to scoreboard.R
  source(NHL_SCOREBOARD_SCRIPT, local = new.env(list(EXECUTION_ATTEMPTS = EXECUTION_ATTEMPTS)))

  if (exists("scoreboard")) {
    # Check if the data frame contains at least one row of data (fixes a bug where a day range is specified where games do NOT exist - 2023.04.07 is an example)
    if (nrow(scoreboard) > 0) {
      # Format Sys.time() to display with six-digit precision
      print(paste(EMPTY_SPACES, "-> NHL scoreboard available at", format(Sys.time(), "%Y-%m-%d %H:%M:%OS6")))
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

```

### scoreboard.R

```r
# Load necessary libraries
library(httr)
library(jsonlite)
library(dplyr)
library(lubridate)

# Source the constants file
source("R/constants.R")

# Function to fetch and process NHL Edge API data
process_nhl_data <- function(source = "api", fileLocation = NULL, EXECUTION_ATTEMPTS) {
  if (source == "api") {
    # print("Fetching data from the NHL Edge API")
    # Fetch data from the NHL Edge API
    response <- GET(NHL_EDGE_API_SCOREBOARD_URL)
    data <- fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE)
  } else if (source == "file" && !is.null(fileLocation)) {
    print(paste("Loading data from", fileLocation, "instead of the NHL Edge API"))
    # Read the JSON file
    data <- fromJSON(fileLocation, flatten = TRUE)
  } else {
    stop("Invalid data source or missing file location.")
  }

  games <- list(data$games) # Assuming 'data' contains your example JSON structure

  # Assuming DEBUG_VERBOSE is defined somewhere in your script
  # DEBUG_VERBOSE <- TRUE or FALSE

  scoreboard_df <- lapply(games, function(game) {
    game_id <- if (!is.null(game$id)) {
      game$id
    } else {
      if (DEBUG_VERBOSE) {
        print("NHL ID NA for game:")
        print(game)
      }
      NA
    }

    utc_datetime <- if (!is.null(game$startTimeUTC)) {
      ymd_hms(game$startTimeUTC)
    } else {
      if (DEBUG_VERBOSE) {
        print("UTC DateTime NA for game:")
        print(game)
      }
      NA
    }
    game_start <- if (!is.null(game$venueTimezone)) {
      with_tz(utc_datetime, NHL_EDGE_API_TIMEZONE)
    } else {
      if (DEBUG_VERBOSE) {
        print("Local DateTime NA for game:")
        print(game)
      }
      NA
    }

    home <- if (!is.null(game$homeTeam.abbrev)) {
      game$homeTeam.abbrev
    } else {
      if (DEBUG_VERBOSE) {
        print("Home Team Abbreviation NA for game:")
        print(game)
      }
      NA
    }
    home_record <- if (!is.null(game$homeTeam.record)) {
      game$homeTeam.record
    } else {
      if (DEBUG_VERBOSE) {
        print("Home Team Record NA for game:")
        print(game)
      }
      NA
    }
    home_score <- if (!is.null(game$homeTeam.score)) {
      game$homeTeam.score
    } else {
      if (DEBUG_VERBOSE) {
        print("Home Team Score NA for game:")
        print(game)
      }
      NA
    }
    home_sog <- if (!is.null(game$homeTeam.sog)) {
      game$homeTeam.sog
    } else {
      if (DEBUG_VERBOSE) {
        print("Home Team SOG NA for game:")
        print(game)
      }
      NA
    }

    away <- if (!is.null(game$awayTeam.abbrev)) {
      game$awayTeam.abbrev
    } else {
      if (DEBUG_VERBOSE) {
        print("Visiting Team Abbreviation NA for game:")
        print(game)
      }
      NA
    }
    away_record <- if (!is.null(game$awayTeam.record)) {
      game$awayTeam.record
    } else {
      if (DEBUG_VERBOSE) {
        print("Visiting Team Record NA for game:")
        print(game)
      }
      NA
    }
    away_score <- if (!is.null(game$awayTeam.score)) {
      game$awayTeam.score
    } else {
      if (DEBUG_VERBOSE) {
        print("Visiting Team Score NA for game:")
        print(game)
      }
      NA
    }
    away_sog <- if (!is.null(game$awayTeam.sog)) {
      game$awayTeam.sog
    } else {
      if (DEBUG_VERBOSE) {
        print("Visiting Team SOG NA for game:")
        print(game)
      }
      NA
    }

    # Setting the current period
    period <- if (!is.null(game$periodDescriptor.number)) {
      period <- game$periodDescriptor.number
      if (!is.null(game$clock.inIntermission)) {
        inIntermission <- game$clock.inIntermission

        # Create a logical vector to index non-NA elements in 'inIntermission'
        non_na_index <- !is.na(inIntermission)

        # Append "INT" before 'period' where 'inIntermission' is TRUE and not NA
        period[non_na_index & inIntermission] <- paste0("INT", period[non_na_index & inIntermission])

        # Return the vector of 'period' values
        period
      } else {
        period
      }
    } else {
      NA # No current period information
    }

    period_desc <- if (!is.null(game$periodDescriptor.periodType)) {
      game$periodDescriptor.periodType
    } else {
      if (DEBUG_VERBOSE) {
        print("Game Outcome Last Period Type Descriptor NA for game:")
        print(game)
      }
      NA
    }

    time_remaining <- if (!is.null(game$clock.timeRemaining)) {
      game$clock.timeRemaining
    } else {
      NA # No time remaining information or the game has not started
    }

    # Use the passed EXECUTION_ATTEMPTS for the execution count for each game
    consecutive_updates <- EXECUTION_ATTEMPTS

    # Construct the NHL Gamecenter URL - https://www.nhl.com/gamecenter/<game_id>
    nhl_gamecenter_url <- if (!is.null(game_id)) {
      paste0("https://www.nhl.com/gamecenter/", game_id)
    } else {
      NA # Set as NA if game_id is null
    }

    data.frame(
      game_id,
      game_start,
      away,
      away_score,
      home,
      home_score,
      period,
      time_remaining,
      period_desc,
      away_record,
      away_sog,
      home_record,
      home_sog,
      consecutive_updates,
      nhl_gamecenter_url
    )
  })

  scoreboard_df <- do.call(rbind, scoreboard_df)

  # [Rest of the existing content of process_nhl_data function]
  return(scoreboard_df)
}

# Check if EXECUTION_ATTEMPTS is passed and set a default if not
EXECUTION_ATTEMPTS <- if (exists("EXECUTION_ATTEMPTS", envir = .GlobalEnv)) {
  get("EXECUTION_ATTEMPTS", envir = .GlobalEnv)
} else {
  1 # Default value if not provided
}

# DEBUG: Load the data from a file instead of the API
# scoreboard <- process_nhl_data(source = "file", fileLocation = "data/score-now-20231130.json", EXECUTION_ATTEMPTS = EXECUTION_ATTEMPTS)
# View(scoreboard)

# Call the process_nhl_data function with the EXECUTION_ATTEMPTS
scoreboard <- process_nhl_data(EXECUTION_ATTEMPTS = EXECUTION_ATTEMPTS)
View(scoreboard)

```
