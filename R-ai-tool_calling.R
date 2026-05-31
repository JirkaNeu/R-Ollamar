# https://github.com/hauselin/ollama-r

library(rstudioapi)
library(ollamar)
library(rvest)
library(httr)
#library(httr2)
library(tcltk)


# locate folder -----------------------------------------------------------

this_file = rstudioapi::getActiveDocumentContext()$path
path = box::file()
check_path = unlist(strsplit(this_file, split = "/"))
check_path = paste0(check_path[1:length(check_path)-1], collapse="/")

if (check_path != path){
  warning("There might be issues related to the path...", call. = TRUE, immediate. = FALSE, domain = NULL)
}else{
  setwd(file.path(path, "data"))
  #allfiles = dir()
}
rm(this_file, path, check_path)



# functions ---------------------------------------------------------------

source("../functions/fun_prompt_win.R")
source("../functions/fun_web_search.R")
#source("../functions/fun_take_notes.R") #--> under construction

fun_tool_key_words = function(user_input) {
  search_keywords = c("search for", "look up", "find information about", "google", "search the web", "in the internet", "in the web", "suche nach", "suche im internet", "suche im netz", "finde im netz", "suche im web", "im internet", "im web", "im netz")
  tolower_user_input = tolower(user_input) |> trimws()
  for (keyword in search_keywords) {
    if (grepl(keyword, tolower_user_input)) {
      return(TRUE)
    }
  }
  return(FALSE)
}


# script ------------------------------------------------------------------

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



# define tools ------------------------------------------------------------

tool_web_search = list(type = "function",
                        "function" = list(
                          name = "web_search",  # function name
                          description = "Search the web for information. Use this only if the user explicitly asks to.",
                          parameters = list(
                            type = "object",
                            required = list("search_term"),  # function parameters
                            properties = list(
                              search_term = list(class = "character", description = "the term to search the web")))
                          )
                        )

tools_jne = list(tool_web_search)


# start chat --------------------------------------------------------------


locModel_1 = "llama3.1"
#locModel_1 = "mistral:7b"
#locModel_2 = "qwen3-vl:4b"


system_prompt = "Do not use tools, only when explicitly asked to. Do not summarise. Keep it brief and conversate in a casual manner. Just plain text. No Emojis."
initial_prompt = "Say hi and ask what you can help with."

#--> start chat_log
chat_log = c(paste("\nLLM:", locModel_1, "\n", "\nSystem Prompt:", system_prompt, paste("\nInitial Prompt:", initial_prompt)), "\n----------")


messages = create_messages(
  create_message(system_prompt, role = "system"),
  create_message(initial_prompt, role = "user")
)

ai_resp = chat(locModel_1, messages, output = "text")
messages = append_message(ai_resp, role = "assistant", messages)
messages[[length(messages)]][2] |> unlist() |> cat(); cat("\n\n")
chat_log = append(chat_log, c(paste("\n>>> Ai says:", messages[[length(messages)]][2] |> unlist(), "\n")))





# chat loop ---------------------------------------------------------------

stop_it = F
i = 0 #safety stop

while(TRUE) {
  i = i + 1
  
  user_input = get_user_input()
  if (is.null(user_input) || user_input == ""){
    user_input = "Nothing entered by user..."
    stop_it = T
  }
  
  if(stop_it == T || i >= 50){break}
  
  messages = user_input |> append_message(role = "user", messages)
  messages[[length(messages)]][2] |> unlist() |> cat(); cat("\n\n")
  chat_log = append(chat_log, c(paste(">>> User:", user_input, "\n")))
  
  
  if (fun_tool_key_words(user_input)) {
    cat("tool calling keyword found\n")
    
    ai_resp = chat(locModel_1, messages, tools = tools_jne, output = "tools")
    #--> check if tool calling has results
    if (length(ai_resp) > 0 && !is.null(ai_resp) && ai_resp != "") {
      tool_call = ai_resp[[1]]
      cat(sprintf("Calling tool: %s with arguments: %s\n",
                  tool_call$name, toString(tool_call$arguments)))
      tool_result = do.call(tool_call$name, tool_call$arguments)
      cat("Tool result:\n\n")
      print(tool_result)
      
      #--> httr error when adding result to messages list
      #messages = append_message(paste("Tool result:", tool_result), "assistant", messages)
      #--> add tool result to log file
      chat_log = append(chat_log, c(paste("Tool result:", tool_result, "\n")))
      
    } else {
      #--> when tool calling is without results generate text
      messages = chat(locModel_1, messages, output = "text") |> append_message(role = "assistant", messages)
      messages[[length(messages)]][2] |> unlist() |> cat(); cat("\n\n")
      chat_log = append(chat_log, c(paste(">>> Ai says:", messages[[length(messages)]][2] |> unlist(), "\n")))
    }
    
  } else {
    cat("no explicit keyword for tool use found\n")
    messages = chat(locModel_1, messages, output = "text") |> append_message(role = "assistant", messages)
    messages[[length(messages)]][2] |> unlist() |> cat(); cat("\n\n")
    chat_log = append(chat_log, c(paste(">>> Ai says:", messages[[length(messages)]][2] |> unlist(), "\n")))
  }
  
  

}


# initiate the end --------------------------------------------------------


messages = "The conversation is over. Say good bye and ask no further questions." |> append_message(role = "user", messages)
messages = chat(locModel_1, messages, output = "text") |> append_message(role = "assistant", messages)
messages[[length(messages)]][2] |> unlist() |> cat(); cat("\n\n")
chat_log = append(chat_log, c(paste(">>> Ai says:", messages[[length(messages)]][2] |> unlist(), "\n")))



# create log file ---------------------------------------------------------

filename = format(Sys.time(), "ai_chat_%y%m%d_%H%M.txt")
chat_log = paste(chat_log, collapse = "\n")
chat_log = paste("\n", chat_log, "\n\n+ + + + +\n\neof\n")

write.table(chat_log, file = filename, row.names = F, col.names = F)
print("The End")


