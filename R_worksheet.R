library(pacman)
library(dplyr)
library(tidyr)
library(lubridate)
p_load(bookdown, tidyverse, ggforce, flextable, latex2exp, png, magick)

#Setting the pathway for finding the data file
dros_path <- "./data/raw_data_drosophila.csv"
#Reading in the CSV file using the preset pathway
dros_data <- read_csv(dros_path, col_select = -c(7, 8))

summary(dros_data)

#Listing each different species character value
list(unique(dros_data$species))

#Fixing a spelling mistake identified from the previous step
dros_data$species[dros_data$species == "subs"] <- "sub"


#Converting collect_date into date format
sampling_dates <- as.Date(dros_data$collect_date)
#Transferring collect_date into day of year format (1-365)
doy_sampling_dates <- yday(sampling_dates)
#Adding day of year (doy) values into the existing data frame
dros_data$collect_doy <- yday(sampling_dates)

#Repeated for refill_date
refill_dates <- as.Date(dros_data$refill_date)
doy_refill_dates <- yday(refill_dates)
dros_data$refill_doy <- yday(refill_dates)



#Creating a data frame showing total number of species across urban/natural
total_abundance_df <- dros_data %>%
  group_by(species, area_type) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = species, values_from = count, values_fill = 0)

print(total_abundance_df)

#Showing each DOY value, representing each trapping day
list(unique(dros_data$collect_doy))


#Labelling 
dros_data <- dros_data %>%
  mutate(
    sampling_session = case_when(
      trap_no %in% c("D1") ~ NA_real_,
      collect_doy <= 276 ~ 1,
      collect_doy <= 278 ~ 2,
      collect_doy <= 284 ~ 3,
      collect_doy <= 287 ~ 4,
      collect_doy <= 292 ~ 5,
      collect_doy <= 306 ~ 6,
      collect_doy <= 312 ~ 7,
      collect_doy <= 316 ~ 8,
      collect_doy <= 319 ~ 9,
      collect_doy <= 322 ~ 10,
      TRUE ~ NA_real_  # Default condition for any other case
    )
  )