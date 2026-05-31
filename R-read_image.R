library(rstudioapi)
library(ollamar)
#library(httr2)


# locate folder -----------------------------------------------------------


this_file = rstudioapi::getActiveDocumentContext()$path
path = box::file()
check_path = unlist(strsplit(this_file, split = "/"))
check_path = paste0(check_path[1:length(check_path)-1], collapse="/")

if (check_path != path){
  warning("There might be issues related to the path of files.", call. = TRUE, immediate. = FALSE, domain = NULL)
}else{
  setwd(file.path(path, "data"))
  #allfiles = dir()
}  
rm(this_file, path, check_path)



# script ------------------------------------------------------------------


test_connection()
list_models()

#name        size    parameter_size
#gemma4:e2b  7.2 GB  5.1B            

vision_modell = "gemma4:e2b"


#------> remake a pie plot shown in img_file by creating R-code
img_file = "../a_pie_plot1_src.png"

plot_rmk = generate(vision_modell, "Provide Code written in R for data science which creates the same plot as shown in the image. Provide R-code only, no annotations or explainations.",
                    images = img_file, output = 'text')

cat(plot_rmk)

##### result, output (a_pie_plot2_rmk.png)
# data <- c(40, 25, 20, 15)
# labels <- c("drinks", "fruits", "sweets", "cheese")
# colors <- c("cyan", "green", "red", "blueviolet")
# pie(data, labels = labels, col = colors, main = "sold items last year")

