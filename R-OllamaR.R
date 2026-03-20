#
#https://github.com/hauselin/ollama-r
#

library(ollamar)

test_connection()
list_models()


# generate a response/text based on a prompt; returns an httr2 response by default
#resp <- generate("llama3.1", "tell me a 5-word story")
#resp_process(resp, "text")
#resp_process(resp, "df")

# alternatively, specify the output type when calling the function initially
#my_prompt = readline()

my_prompt = "What is the difference bettween up and down on a sphere. Explain in few words."

txt <- generate("llama3.1", my_prompt, output = "text") |> cat()


