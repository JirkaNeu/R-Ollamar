require(rvest)
require(httr)

#------------------------------------#
#--> special thanks to Mistral AI <--#
#------------------------------------#

web_search = function(search_term = ""){

  search_term = as.character(search_term)
  
  # Define the search query
  query <- search_term
  url <- paste0("https://html.duckduckgo.com/html/?q=", URLencode(query))
  
  # Send a GET request with a user-agent header
  response <- GET(
    url,
    #user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
    user_agent("Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36")
  )
  
  # Parse the HTML content
  html_content <- read_html(response)
  
  # Extract titles
  titles <- html_content |>
    html_nodes(".result__title a") |>
    html_text()
  
  # Extract links
  links <- html_content |>
    html_nodes(".result__title a") |>
    html_attr("href")
  
  # Extract teasers (snippets)
  teasers <- html_content |>
    html_nodes(".result__snippet") |>
    html_text()
  
  # Combine into a data frame
  results <- data.frame(
    Title = titles[1:5],
    Link = links[1:5],
    Teaser = teasers[1:5]
  )
  
  # Print the results
  # print(results)
  return(results)
}
