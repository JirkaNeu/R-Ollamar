#
#https://github.com/hauselin/ollama-r
#

library(rstudioapi)
library(ollamar)


fun_locate_data_folder = function(){
  this_file = rstudioapi::getActiveDocumentContext()$path
  path = box::file()
  check_path = unlist(strsplit(this_file, split = "/"))
  check_path = paste0(check_path[1:length(check_path)-1], collapse="/")
  
  if (check_path != path){
    warning("There might be issues related to the path...", call. = TRUE, immediate. = FALSE, domain = NULL)
  }else{
    setwd(file.path(path, "data"))
    #allfiles = dir()
    #print(allfiles)
  }  
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

locModel_1 = "llama3.1"
#locModel_1 = "mistral:7b"
locModel_2 = "qwen3-vl:4b"

#system_prompt = "Begin with 'Here am AI.'"
system_prompt = "Do not summarise. Keep it brief and conversate in a casual manner. Feel free to change the topic."
initial_prompt = "Say hi and start with a couple of suggestions what to talk about."

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


#--> make log_file
filename = format(Sys.time(), "ai_chat_%y%m%d_%H%M.txt")
chat_log = paste(chat_log, collapse = "\n")
chat_log = paste("\n", chat_log, "\n\n+ + + + +\n\neof\n")

write.table(chat_log, file = filename, row.names = F, col.names = F)


