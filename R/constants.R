# Set DEBUG_VERBOSE to true if you would like to see details logged to the console # nolint
DEBUG_VERBOSE <- FALSE
EMPTY_SPACES <- "    "
THREE_MINUTES_IN_SECONDS <- 60 * 3

# NHL Edge API
NHL_EDGE_API_BASE_URL <- "https://api-web.nhle.com/v1"
NHL_EDGE_API_DATE <- format(Sys.Date(), "%Y-%m-%d") # Get today's date in the format YYYY-MM-DD
NHL_EDGE_API_DELAY_IN_SECONDS <- THREE_MINUTES_IN_SECONDS
NHL_EDGE_API_SCOREBOARD_URL <- paste0(NHL_EDGE_API_BASE_URL, "/score/", NHL_EDGE_API_DATE)
NHL_EDGE_API_TIMEOUT_IN_SECONDS <- 10
NHL_EDGE_API_TIMEZONE <- "America/Los_Angeles"
