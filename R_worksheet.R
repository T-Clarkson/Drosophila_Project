library(pacman)
p_load(bookdown, tidyverse, ggforce, flextable, latex2exp, png, magick)

#Setting the pathway for finding the data file
dros_path <- "./data/raw_data_drosophila.csv"
#Reading in the CSV file using the preset pathway
dros_data <- read_csv(dros_path, col_select = -c(7, 8))




