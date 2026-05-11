# https://github.com/hauselin/ollama-r

library(rstudioapi)
library(ollamar)
library(rvest)
library(httr)
#library(httr2)



# functions ---------------------------------------------------------------

fun_locate_data_folder = function(){
  this_file = rstudioapi::getActiveDocumentContext()$path
  path = box::file()
  check_path = unlist(strsplit(this_file, split = "/"))
  check_path = paste0(check_path[1:length(check_path)-1], collapse="/")
  
  if (check_path != path){
    warning("There might be issues related to the path of files.", call. = TRUE, immediate. = FALSE, domain = NULL)
  }else{
    setwd(file.path(path, "data"))
    #allfiles = dir()
    #print(allfiles)
  }  
}




web_search = function(search_term = ""){
  #------------------------------------#
  #--> special thanks to Mistral AI <--#
  #------------------------------------#
  
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




fun_locate_data_folder()
test_connection()
list_models()


'
l llama3.1:latest  4.9 GB           8.0B
2      mistral:7b  4.4 GB           7.2B
3    qwen3-vl:30b 19.6 GB          31.1B
4     qwen3-vl:4b  3.3 GB           4.4B
5        qwen3:8b  5.2 GB           8.2B

check = generate("mistral:7b", "Who made you?", output = "text")
'



# web search tool ---------------------------------------------------------
tool1 <- list(type = "function",
              "function" = list(
                name = "web_search",  # function name
                description = "a web search with duckduckgo",
                parameters = list(
                  type = "object",
                  required = list("search_term"),  # function parameters
                  properties = list(
                    search_term = list(class = "character", description = "the term to search with duckduckgo")))
              )
)






locModel_1 = "llama3.1"
#locModel_1 = "mistral:7b"
#locModel_2 = "qwen3-vl:4b"


system_prompt = "Do not summarise. Keep it brief and conversate in a casual manner. Just plain text. No Emojis."
initial_prompt = "Say hi and ask what you can help with."

#--> start chat_log
chat_log = c(paste("\nLLM:", locModel_1, "\n", "\nSystem Prompt:", system_prompt, paste("\nInitial Prompt:", initial_prompt)), "\n----------")


messages <- create_messages(
  create_message(system_prompt, role = "system"),
  create_message(initial_prompt, role = "user")
)

ai_resp = chat(locModel_1, messages, output = "text")
messages = append_message(ai_resp, role = "assistant", messages)
messages[[length(messages)]][2] |> unlist() |> cat(); print("")
chat_log = append(chat_log, c(paste("\n>>> Ai says:", messages[[length(messages)]][2] |> unlist(), "\n")))


stop_it = F
for (i in c(1:15)) {
  source("../prompt_win.R") #--> user_input
  if(stop_it == T || i >= 50){break}
  messages = user_input |> append_message(role = "user", messages)
  chat_log = append(chat_log, c(paste(">>> User:", user_input, "\n")))
  
  messages = chat(locModel_1, messages, output = "text") |> append_message(role = "assistant", messages)
  messages[[length(messages)]][2] |> unlist() |> cat(); print("")
  chat_log = append(chat_log, c(paste(">>> Ai says:", messages[[length(messages)]][2] |> unlist(), "\n")))
}


messages = "The conversation is over. Say good bye and ask no further questions." |> append_message(role = "user", messages)
messages = chat(locModel_1, messages, output = "text") |> append_message(role = "assistant", messages)
messages[[length(messages)]][2] |> unlist() |> cat()
chat_log = append(chat_log, c(paste(">>> Ai says:", messages[[length(messages)]][2] |> unlist(), "\n")))


#--> create log_file
filename = format(Sys.time(), "ai_chat_%y%m%d_%H%M.txt")
chat_log = paste(chat_log, collapse = "\n")
chat_log = paste("\n", chat_log, "\n\n+ + + + +\n\neof\n")

write.table(chat_log, file = filename, row.names = F, col.names = F)
print("The End")

