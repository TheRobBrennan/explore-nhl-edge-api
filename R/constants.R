# Get today's date in the format YYYY-MM-DD
todays_date <- format(Sys.Date(), "%Y-%m-%d")

NHL_EDGE_API_BASE_URL <- "https://api-web.nhle.com/v1"

NHL_EDGE_API_SCOREBOARD_URL <- paste0(NHL_EDGE_API_BASE_URL, "/score/now")
# NHL_EDGE_API_SCOREBOARD_URL <- paste0(NHL_EDGE_API_BASE_URL, "/score/", todays_date)

NHL_EDGE_API_TIMEZONE <- "America/Los_Angeles"
