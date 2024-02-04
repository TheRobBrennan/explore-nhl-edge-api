# Set DEBUG_VERBOSE to true if you would like to see details logged to the console (such as scoreboard_df game details)
DEBUG_VERBOSE <- FALSE

# Get today's date in the format YYYY-MM-DD
todays_date <- format(Sys.Date(), "%Y-%m-%d")

# NHL Edge API
NHL_EDGE_API_BASE_URL <- "https://api-web.nhle.com/v1"
NHL_EDGE_API_SCOREBOARD_URL <- paste0(NHL_EDGE_API_BASE_URL, "/score/now") # OR ... <- paste0(NHL_EDGE_API_BASE_URL, "/score/", todays_date)
NHL_EDGE_API_TIMEOUT_IN_SECONDS <- 10
NHL_EDGE_API_TIMEZONE <- "America/Los_Angeles"

