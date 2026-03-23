#
#https://github.com/hauselin/ollama-r
#

library(rstudioapi)
library(ollamar)
#library(httr2)


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

#locModel_1 = "llama3.1"
locModel_1 = "mistral:7b"
locModel_2 = "qwen3-vl:4b"


#my_prompt = "What is the difference bettween up and down on a sphere?"
#my_prompt = "Ask me a new question."
my_prompt = "Suggest more than three topics and ask which of them is interessting to talk about."
#+++++++
#plus_more = "Try beeing brief. Do not summarise. Try to lead a conversation. Comment on mentioned ideas. Feel free to change the topic."
plus_more = "Do not summarise. Be brief and answer with less than 600 digits. Try to conversate in a casual manner. Feel free to change the topic. Provide plain text, no emojis, no formating signs."
#+++++++ 
ai1trait = "Be curious about what your conversation partner thinks."
ai2trait = "Be sceptical of what your conversation partner says."


chat_log = c(paste("\na1-one:", locModel_1), paste("ai-2:", locModel_2), "\n+ + + + +\n", my_prompt, "\n+ + + + +\n")


ai1_says <- generate(locModel_1, my_prompt, output = "text") |> print()
chat_log = append(chat_log, paste("\n>>>>> a1-one says:\n", ai1_says))


for (i in c(1:10)) {
  ai2_says = generate(locModel_2, paste(ai1_says, ai2trait, plus_more), output = "text")
  chat_log = append(chat_log, paste("\n>>>>> ai-2 says:\n", ai2_says, "\n"))
  
  ai1_says = generate(locModel_1, paste(ai2_says, ai1trait, plus_more), output = "text")
  chat_log = append(chat_log, paste("\n>>>>> a1-one says:\n", ai1_says))
}


filename = format(Sys.time(), "ai_chat_%y%m%d_%H%M.txt")
chat_log = paste(chat_log, collapse = "\n")
chat_log = paste("\n", chat_log, "\n\n\n+ + + + +\n\neof\n")

write.table(chat_log, file = filename, row.names = F, col.names = F)


