library(pacman)
library(dplyr)
library(tidyr)
library(lubridate)
library(tibble)
library(vegan)
library(cli)
p_load(bookdown, tidyverse, ggforce, flextable, latex2exp, png, magick, cli)
install.packages("tidyverse")

#Setting the pathway for finding the data file
dros_path <- "./data/raw_data_drosophila.csv"
#Reading in the CSV file using the preset pathway
dros_data <- read.csv(dros_path)
#Excluding null columns
dros_data <- dros_data[, -c(7, 8)]

#Creating wide data frame with a column for each species and area_type and trap_no
total_site_abundance_df_wide <- dros_data %>%
  group_by(species, trap_no, collect_date, area_type) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = species, values_from = count, values_fill = 0)




