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


#Labelling points with sampling session IDs (1-10) based on collection day, excluding D1 (Penryn)
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
      TRUE ~ NA_real_ 
    )
  )
#Setting the sampling session to be read as a character rather than numeric
dros_data$sampling_session <- as.character(dros_data$sampling_session)


#Creating a new data frame with the number of records for each species at each trap per sampling session
sampling_records_dros <- dros_data %>%
  group_by(trap_no, species, area_type, sampling_session) %>%
  summarise(average_records = n())
#Creating a new data frame using the previous one, calculating averages of species record numbers across the sampling sessions
average_abun_dros <- sampling_records_dros %>%
  group_by(trap_no, species, area_type) %>%
  summarise(mean_records = mean(average_records, na.rm = TRUE))

#Plotting a bar chart showing the species abundance across traps, comparing between disturbed and undisturbed (averaging across sampling sessions)
ggplot(subset(average_abun_dros, trap_no != "D1", mean_records != "NA"), aes(x = trap_no, y = mean_records, fill = species)) +
  geom_bar(stat = "identity", position = "stack", na.rm = T) +
  facet_wrap(~area_type, scales = "free") +
  coord_cartesian(ylim = c(0,65)) +

  labs(title = "Average Abundance of Drosophila Species by Area Type",
       x = "Trap Number",
       y = "Average Abundance") +
  theme_minimal()

##Merging coordinate data with the current data

#Setting the pathway for finding the data file
coord_path <- "./data/site_coords.csv"
#Reading in the CSV file using the preset pathway
coord_data <- read_csv(coord_path, col_select = -c(4))
#Adding coord data to the dros_data table to make new codros_data table
codros_data <- dros_data %>% left_join(coord_data, by = "trap_no")

#Creating a dataframe showing the species abundance at each site and sampling session

total_site_abundance_df <- dros_data %>%
  group_by(species, trap_no, collect_date) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = species, values_from = count, values_fill = 0)

print(total_site_abundance_df)