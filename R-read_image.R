library(ollamar)

test_connection()
list_models()

#name   size parameter_size quantization_level            modified
#1      gemma3:1b 815 MB        999.89M             Q4_K_M 2026-02-28T03:35:03
#2      llama3.1:latest 4.9 GB   

messages <- create_message("What is in the image?", images = "image.png")

generate("llama3.1", "What is in the image?",
         images = "C:\\Zentrum\\R_docx\\jne_plot.png", output = 'text')


#llama3.1

generate("llama3.1", "Tomorrow is a...", output = "text")

