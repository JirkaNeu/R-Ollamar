library(ollamar)

test_connection()
list_models()

#name   size parameter_size quantization_level            modified
#1      gemma3:1b 815 MB        999.89M             Q4_K_M 2026-02-28T03:35:03
#2      llama3.1:latest 4.9 GB   


vision_modell = "gemma4:e2b"
img_file = "a_picture.jpg"


#generate(vision_modell, "Tomorrow is a...", output = "text")

generate(vision_modell, "What is in the image?",
         images = img_file, output = 'text')

messages <- create_message("What is in the image?", images = "image.png")

#llama3.1



