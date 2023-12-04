library(pacman)
library(dplyr)
library(tidyr)
p_load(bookdown, tidyverse, ggforce, flextable, latex2exp, png, magick)

#Setting the pathway for finding the data file
dros_path <- "./data/raw_data_drosophila.csv"
#Reading in the CSV file using the preset pathway
dros_data <- read_csv(dros_path, col_select = -c(7, 8))

#Listing each different species character value
list(unique(dros_data$species))

#Fixing a spelling mistake identified from the previous step
dros_data$species[dros_data$species == "subs"] <- "sub"


total_abundance_df <- dros_data %>%
  group_by(species, area_type) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = species, values_from = count, values_fill = 0)

print(total_abundance_df)
