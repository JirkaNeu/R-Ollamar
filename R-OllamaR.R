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


# generate a response/text based on a prompt; returns an httr2 response by default
#resp <- generate("llama3.1", "tell me a 5-word story")
#resp_process(resp, "text")
#resp_process(resp, "df")

# alternatively, specify the output type when calling the function initially
#my_prompt = readline()

'
llama3.1:latest  4.9 GB           8.0B             Q4_K_M 2026-03-20T00:35:08
2    qwen3-vl:30b 19.6 GB          31.1B             Q4_K_M 2026-02-21T01:04:10
3     qwen3-vl:4b  3.3 GB           4.4B             Q4_K_M 2026-03-23T00:27:40
4        qwen3:8b  5.2 GB           8.2B             Q4_K_M 2026-03-01T15:35:18
'

local_modell = "llama3.1"
local_modell_2 = "qwen3-vl:4b"

#my_prompt = "What is the difference bettween up and down on a sphere. Explain in few words."
#my_prompt = "Ask me a new question."
my_prompt = "Suggest three or four topics to talk about."
plus_more = "Try beeing brief. Do not summarise. Try to lead a conversation. Feel free to change the topic."
chat_log = c(paste("\nai one:", local_modell), paste("ai two:", local_modell_2), "\n+ + + + +\n", my_prompt, "\n+ + + + +\n")


#txt <- generate(local_modell, my_prompt, output = "text")
ai1_says <- generate(local_modell, my_prompt, output = "text") |> print()
chat_log = append(chat_log, paste("\n>>>>> One says:", ai1_says))


for (i in c(1:10)) {
  ai2_says = generate(local_modell_2, paste(ai1_says, plus_more), output = "text")
  chat_log = append(chat_log, paste("\n>>>>> Two says:", ai2_says, "\n"))
  
  ai1_says = generate(local_modell, paste(ai2_says, plus_more), output = "text")
  chat_log = append(chat_log, paste("\n>>>>> One says:", ai1_says))
}


filename = format(Sys.time(), "ai_chat_%y%m%d_%H%M.txt")
chat_log = paste(chat_log, collapse = "\n")
chat_log = paste("\n", chat_log, "\n\n\n+ + + + +\n\neof\n")

write.table(chat_log, file = filename, row.names = F, col.names = F)


