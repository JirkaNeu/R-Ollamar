#
#https://github.com/hauselin/ollama-r
#

library(rstudioapi)
library(ollamar)
library(tcltk)
#library(httr2)


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
  #print(allfiles)
}


# functions ---------------------------------------------------------------

source("../functions/fun_prompt_win.R")



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

#locModel_1 = "llama3.1"
locModel_1 = "mistral:7b"
locModel_2 = "qwen3-vl:4b"


messages <- create_messages(
  #create_message("Begin with 'Here am AI.' Who made you?", role = "system"),
  create_message("Do not summarise. Keep it brief and conversate in a casual manner.", role = "system"),
  create_message("Make suggestions what to talk about.", role = "user")
)

ai_resp = chat(locModel_1, messages, output = "text")
messages = append_message(ai_resp, role = "assistant", messages)
messages[[length(messages)]][2] |> unlist() |> cat(); cat("\n\n")

stop_it = F
for (i in c(1:5)) {
  
  user_input = get_user_input()
  if (is.null(user_input)){
    user_input = "Nothing entered by user..."
    stop_it = T
  }
  
  if(stop_it == T || i >= 50){break}
  messages = user_input |> append_message(role = "user", messages)
  messages = chat(locModel_1, messages, output = "text") |> append_message(role = "assistant", messages)
  messages[[length(messages)]][2] |> unlist() |> cat(); cat("\n\n")
}

messages = "The conversation is over. Say good bye and ask no further questions" |> append_message(role = "user", messages)
messages = chat(locModel_1, messages, output = "text") |> append_message(role = "assistant", messages)
messages[[length(messages)]][2] |> unlist() |> cat(); cat("\n\n")



#-------------------------------------------------------------------------------------#
my_prompt = "Suggest more than three topics and ask which of them is interessting to talk about."
#+++++++
plus_more = "Do not summarise. Keep it brief and answer with few lines. Try to conversate in a casual manner. Provide plain text, no emojis, no formating signs."
#+++++++ 
ai1trait = "Keep it brief. Try to explore deeper what your conversation partner thinks."
ai2trait = "Feel free to change the topic."
#-------------------------------------------------------------------------------------#

#--> start chat_log
chat_log = c(paste("\nModel one:", locModel_1, "(a1-one)"), paste("Model two:", locModel_2, "(ai-2)"), "----------")
chat_log = append(chat_log, c(paste("\na1-one:", ai1trait), paste("ai-2:", ai2trait), paste("\nboth:", plus_more), "\n\n+ + + + +\n", paste("Today's topic:", my_prompt), "\n+ + + + +\n"))


#--> start conversation
ai1_says = generate(locModel_1, my_prompt, output = "text") |> print()
chat_log = append(chat_log, paste("\n>>>>> a1-one says:\n", ai1_says))

for (i in c(1:5)) {
  ai2_says = generate(locModel_2, paste(ai1_says, ai2trait, plus_more), output = "text")
  chat_log = append(chat_log, paste("\n>>>>> ai-2 says:\n", ai2_says, "\n"))
  
  ai1_says = generate(locModel_1, paste(ai2_says, ai1trait, plus_more), output = "text")
  chat_log = append(chat_log, paste("\n>>>>> a1-one says:\n", ai1_says))
}


#--> make log_file
filename = format(Sys.time(), "ai_chat_%y%m%d_%H%M.txt")
chat_log = paste(chat_log, collapse = "\n")
chat_log = paste("\n", chat_log, "\n\n\n+ + + + +\n\neof\n")

write.table(chat_log, file = filename, row.names = F, col.names = F)
