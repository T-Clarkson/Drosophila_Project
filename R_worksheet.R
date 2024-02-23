library(pacman)
library(dplyr)
library(tidyr)
library(lubridate)
library(tibble)
library(vegan)
p_load(bookdown, tidyverse, ggforce, flextable, latex2exp, png, magick)
install.packages("tidyr", dependencies = TRUE)

remove.packages("cli")

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

#Removing D1 traps - D1 excluded from sample

dros_data <- dros_data[dros_data$trap_no != "D1", ]


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

total_site_abundance_df_wide <- dros_data %>%
  group_by(species, trap_no, collect_date, area_type) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = species, values_from = count, values_fill = 0)

print(total_site_abundance_df_wide)

#Checking for the number of sampling sessions at each site
sampling_no_table <- total_site_abundance_df_wide %>%
  group_by(trap_no) %>%
  summarise(unique_dates = n_distinct(collect_date))

print(sampling_no_table)

#Rearranging total_site_abundance_df to longer format with species grouped under 'species' header

total_site_abundance_df_long <- total_site_abundance_df_wide %>%
  pivot_longer(cols = c(bus,fun,hyd,immi,mel,obs,sub,suz,tris,"NA"), names_to = "species", values_to = "count")

#Barchart showing distribution of each species 

ggplot(subset(total_site_abundance_df_long, trap_no != "D1"), aes(x = area_type, y = count, fill = factor(species, levels = c("immi","mel","suz", "sub", "obs", "bus", "fun", "hyd", "tris", "NA")))) +
  geom_bar(stat = "identity", position = "stack", na.rm = T) +
  labs(title = expression("Total Abundance of" ~ italic("Drosophila") ~ "species in Undisturbed and Disturbed Sites"),
       y = "Total abundance",
       x = "Site Type",
       fill = "Species") +
  theme_minimal() +
  scale_fill_brewer(palette="Set3") +
  scale_x_discrete(labels = c("N"="Undisturbed","U"="Disturbed"))

###PerMANOVA

#Reorganising data so rows represent trap_no and columns represent species abundance

trap_no_abundance <- total_site_abundance_df_wide <- dros_data %>%
  group_by(species, trap_no, area_type) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = species, values_from = count, values_fill = 0)


#creating trap abundance dataframe without the NA column

trap_no_abundance_noNA <- trap_no_abundance[, colnames(trap_no_abundance) != "NA"]


#Fourth-root transformation of data to limit influence of common species (Alves de Mata et al, ? & Clarke, 1993)

trans_trap_no_abundance_noNA <- trap_no_abundance_noNA %>%
  mutate_if(is.numeric, function(x) x^(1/4))

#Removing non-numeric columns to prepare for making dissimilarity matrix

trans_trap_numeric <- trans_trap_no_abundance_noNA[, sapply(trans_trap_no_abundance_noNA, is.numeric) & colnames(trans_trap_no_abundance_noNA) != "NA"]

#Creating dissimilarity matrix

trans_trap_dist_matrix <- vegdist(trans_trap_numeric, method = "bray")

#Ensuring the data is contained as a matrix

trans_trap_dist_matrix <- as.matrix(trans_trap_numeric)

#Running perMANOVA of area_type against the dissimilarity matrix

trans_trap_perm_result <- adonis2(trans_trap_dist_matrix ~ area_type, data = trans_trap_no_abundance_noNA)

#perMANOVA results

trans_trap_perm_result

########T-Tests comparing species abundance across area types (shows significant difference in hydei and melongaster abundance across area types)
t.test(hyd~ area_type, data = total_site_abundance_df_wide)
t.test(mel~ area_type, data = total_site_abundance_df_wide)

t.test(bus~ area_type, data = total_site_abundance_df_wide)
t.test(fun~ area_type, data = total_site_abundance_df_wide)
t.test(immi~ area_type, data = total_site_abundance_df_wide)
t.test(obs~ area_type, data = total_site_abundance_df_wide)
t.test(suz~ area_type, data = total_site_abundance_df_wide)
t.test(sub~ area_type, data = total_site_abundance_df_wide)
t.test(tris~ area_type, data = total_site_abundance_df_wide)

