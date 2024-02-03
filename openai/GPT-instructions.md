# Instructions

The NHL R scoreboard is a project initially intended to explore the NHL Edge API.

## Background

The code base for the NHL R scoreboard is publicly available in a GitHub repository at [https://github.com/TheRobBrennan/explore-nhl-edge-api](https://github.com/TheRobBrennan/explore-nhl-edge-api)

This project was initially created when the previous NHL stats API [https://statsapi.web.nhl.com/api/v1](https://statsapi.web.nhl.com/api/v1) was deprecated on November 7th, 2023.

This change completely broke my NHL shot chart - available publicly in a GitHub repository at [https://github.com/SplooshAI/sploosh-ai-nhl-shot-chart](https://github.com/SplooshAI/sploosh-ai-nhl-shot-chart). Plans are underway to rewrite the NHL shot chart to accommodate the new endpoints and data structure - though no release date has been identified.

The base URL for the NHL Edge API is [https://api-web.nhle.com/v1/](https://api-web.nhle.com/v1/).

The NHL Edge API is undocumented. However, there is a publicly available repository on GitHub at [https://github.com/Zmalski/NHL-API-Reference](https://github.com/Zmalski/NHL-API-Reference) that shares endpoints and data as discovered by other developers.

This project is intended to be run locally. There is no publicly available demo.

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
