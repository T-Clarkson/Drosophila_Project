library(pacman)
library(dplyr)
library(tidyr)
library(lubridate)
library(tibble)
library(vegan)
library(tabula)
library(lme4)
library(flextable)
library(readr)
library(rstatix)
library(ggplot2)
library(patchwork)
library(purr)

p_load(dplyr, tidyr, lubridate, tibble, vegan, tabula, lme4, flextable, readr, ggplot2, patchwork,purr)



#Setting the pathway for finding the data file
dros_path <- "./data/raw_data_drosophila.csv"
#Reading in the CSV file using the preset pathway
dros_data <- read_csv(dros_path, col_select = -c(7, 8))

summary(dros_data)

#Listing each different species character value
list(unique(dros_data$species))

#Fixing a spelling mistake identified from the previous step
dros_data$species[dros_data$species == "subs"] <- "sub"


#Removing D1 traps - D1 excluded from sample

dros_data <- dros_data[dros_data$trap_no != "D1", ]

#Loading in coordinate data

#Setting the pathway for finding the data file
coord_path <- "./data/site_coords.csv"
#Reading in the CSV file using the preset pathway
coord_data <- read_csv(coord_path, col_select = -c(4))
#Adding coord data to the dros_data table to make new codros_data table
codros_data <- dros_data %>% left_join(coord_data, by = "trap_no")

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

trans_trap_numeric <- trans_trap_no_abundance_noNA[, sapply(trans_trap_no_abundance_noNA, is.numeric)]

#Creating dissimilarity matrix

trans_trap_dist_matrix <- vegdist(trans_trap_numeric, method = "bray")

#Ensuring the data is contained as a matrix

trans_trap_dist_matrix <- as.matrix(trans_trap_numeric)

#Running perMANOVA of area_type against the dissimilarity matrix

trans_trap_perm_result <- adonis2(trans_trap_dist_matrix ~ area_type, data = trans_trap_no_abundance_noNA)

#perMANOVA results

trans_trap_perm_result

########T-Tests comparing species abundance across area types (shows significant difference in hydei and melongaster abundance across area types)

shapiro.test(trap_no_abundance_noNA$hyd[trans_trap_no_abundance_noNA$area_type=="N"])
shapiro.test(trap_no_abundance_noNA$hyd[trans_trap_no_abundance_noNA$area_type=="U"])
shapiro.test(trap_no_abundance_noNA$mel[trans_trap_no_abundance_noNA$area_type=="N"])
shapiro.test(trap_no_abundance_noNA$mel[trans_trap_no_abundance_noNA$area_type=="U"])
shapiro.test(trap_no_abundance_noNA$bus[trans_trap_no_abundance_noNA$area_type=="N"])
shapiro.test(trap_no_abundance_noNA$bus[trans_trap_no_abundance_noNA$area_type=="U"])
shapiro.test(trap_no_abundance_noNA$fun[trans_trap_no_abundance_noNA$area_type=="N"])
shapiro.test(trap_no_abundance_noNA$fun[trans_trap_no_abundance_noNA$area_type=="U"])
shapiro.test(trap_no_abundance_noNA$immi[trans_trap_no_abundance_noNA$area_type=="N"])
shapiro.test(trap_no_abundance_noNA$immi[trans_trap_no_abundance_noNA$area_type=="U"])
shapiro.test(trap_no_abundance_noNA$obs[trans_trap_no_abundance_noNA$area_type=="N"])
shapiro.test(trap_no_abundance_noNA$obs[trans_trap_no_abundance_noNA$area_type=="U"])
shapiro.test(trap_no_abundance_noNA$suz[trans_trap_no_abundance_noNA$area_type=="N"])
shapiro.test(trap_no_abundance_noNA$suz[trans_trap_no_abundance_noNA$area_type=="U"])
shapiro.test(trap_no_abundance_noNA$sub[trans_trap_no_abundance_noNA$area_type=="N"])
shapiro.test(trap_no_abundance_noNA$sub[trans_trap_no_abundance_noNA$area_type=="U"])
shapiro.test(trap_no_abundance_noNA$tris[trans_trap_no_abundance_noNA$area_type=="N"])
shapiro.test(trap_no_abundance_noNA$tris[trans_trap_no_abundance_noNA$area_type=="U"])

wilcox.test(hyd ~ area_type, data = trap_no_abundance_noNA)
t.test(mel~ area_type, data = trap_no_abundance_noNA)

wilcox.test(bus~ area_type, data = trap_no_abundance_noNA)
wilcox.test(fun~ area_type, data = trap_no_abundance_noNA)
t.test(log10(immi)~ area_type, data = trap_no_abundance_noNA)
t.test(obs~ area_type, data = trap_no_abundance_noNA)
t.test(suz~ area_type, data = trap_no_abundance_noNA)
t.test(sub~ area_type, data = trap_no_abundance_noNA)
t.test(sqrt(tris)~ area_type, data = trap_no_abundance_noNA)


#Calculating diversity metrics and adding these to the data frame.

#Creating abundance dataframe containing only numeric data

trap_numeric <- trap_no_abundance_noNA[, sapply(trap_no_abundance_noNA, is.numeric)]


#Simpson's

simpsons_values <- diversity(trap_numeric, index = "simpson")
# Adding values to dataframe
trap_no_abundance_noNA$simpsons_index <- simpsons_values

#Shannon's

shannon_values <- diversity(trap_numeric, index = "shannon")
# Adding values to dataframe
trap_no_abundance_noNA$shannon_index <- shannon_values

#Berger-Parker

berger_parker_values <- apply(trap_numeric, 1, function(x) max(x) / sum(x))
#Adding values to dataframe
trap_no_abundance_noNA$berger_parker_index <- berger_parker_values

#McIntosh

mcIntosh_values <- heterogeneity(trap_numeric, method = "mcintosh")
#Adding values to dataframe
trap_no_abundance_noNA$mcIntosh_index <- mcIntosh_values


#Diversity indice Shapiro-Wilks tests
shapiro.test(trap_no_abundance_noNA$simpsons_index[trans_trap_no_abundance_noNA$area_type=="U"])
shapiro.test(trap_no_abundance_noNA$simpsons_index[trans_trap_no_abundance_noNA$area_type=="N"])
shapiro.test(trap_no_abundance_noNA$shannon_index[trans_trap_no_abundance_noNA$area_type=="U"])
shapiro.test(trap_no_abundance_noNA$shannon_index[trans_trap_no_abundance_noNA$area_type=="N"])
shapiro.test(trap_no_abundance_noNA$berger_parker_index[trans_trap_no_abundance_noNA$area_type=="U"])
shapiro.test(trap_no_abundance_noNA$berger_parker_index[trans_trap_no_abundance_noNA$area_type=="N"])
shapiro.test(trap_no_abundance_noNA$mcIntosh_index[trans_trap_no_abundance_noNA$area_type=="U"])
shapiro.test(trap_no_abundance_noNA$mcIntosh_index[trans_trap_no_abundance_noNA$area_type=="N"])


#Running T-Tests
t.test((berger_parker_index) ~ area_type, data = trap_no_abundance_noNA)
t.test((shannon_index) ~ area_type, data = trap_no_abundance_noNA)
t.test((simpsons_index) ~ area_type, data = trap_no_abundance_noNA)
t.test((mcIntosh_index) ~ area_type, data = trap_no_abundance_noNA)





#Adding coordinate data to the trap_no_abundance_noNA data frame
trap_no_abundance_noNA_coord <- merge(trap_no_abundance_noNA, coord_data, by = "trap_no", all.x = TRUE)

#Exporting trap_no_abundance_noNA_coord as a .csv, 'abundances_coord.csv'

write.csv(trap_no_abundance_noNA_coord, "abundances_coord.csv", row.names = FALSE)



#Autocorrelation results load

#Setting the pathway for finding the data file
autocor_path <- "./data/autocorrelation_results.csv"
#Reading in the CSV file using the preset pathway
autocor_data <- read_csv(autocor_path)


#T-test results load

#Setting the pathway for finding the data file
ttest_path <- "./data/t_test_results.csv"
#Reading in the CSV file using the preset pathway
ttest_data <- read_csv(ttest_path)


#Wilcox results load

#Setting the pathway for finding the data file
wilcox_path <- "./data/wilcoxon_results.csv"
#Reading in the CSV file using the preset pathway
wilcox_data <- read_csv(wilcox_path)




#Wilcox Table
wilcox_data %>%
  flextable %>%
  width(., width = (6.49605/(ncol(wilcox_data)))) %>%
  italic(italic=T, part = "body", j = "Species") %>%
  color(color="#4DAC23", j = "p-value", i = 1)


#T Test Table

ttest_data %>%
  flextable %>%
  width(., width = (6.49605/(ncol(ttest_data)))) %>%
  italic(italic=T, part = "body", j = "Species") %>%
  color(color="#4DAC23", j = "p-value", i = 1)
  
#Autocor Table

autocor_data %>%
  flextable %>%
  width(., width = (6.49605/(ncol(autocor_data)))) %>%
  italic(italic=T, part = "body", j = "Species") %>%
  color(color="#4DAC23", j = "p-value", i = 4)
  
  

#Summary stats

mean(trap_no_abundance_noNA$mel[trap_no_abundance_noNA$area_type=="U"])
#Mean Mel U = 43.4
mean(trap_no_abundance_noNA$mel[trap_no_abundance_noNA$area_type=="N"])
#Mean Mel N 22.8
mn_se <- sd(trap_no_abundance_noNA$mel[trap_no_abundance_noNA$area_type=="N"]) / sqrt(sum(trap_no_abundance_noNA$area_type=="N"))
mn_se
mu_se <- sd(trap_no_abundance_noNA$mel[trap_no_abundance_noNA$area_type=="U"]) / sqrt(sum(trap_no_abundance_noNA$area_type=="U"))
mu_se


mean(trap_no_abundance_noNA$hyd[trap_no_abundance_noNA$area_type=="U"])
#Mean hyd U = 2.8
mean(trap_no_abundance_noNA$hyd[trap_no_abundance_noNA$area_type=="N"])
#Mean hyd N = 0.2
hu_se <- sd(trap_no_abundance_noNA$hyd[trap_no_abundance_noNA$area_type=="U"]) / sqrt(sum(trap_no_abundance_noNA$area_type=="U"))
hu_se
hn_se <- sd(trap_no_abundance_noNA$hyd[trap_no_abundance_noNA$area_type=="N"]) / sqrt(sum(trap_no_abundance_noNA$area_type=="N"))
hn_se


# Visualising the species abundances across disturbed and undisturbed sites
  
  # Reshape the dataframe to long format
  trap_no_abundance_noNA_long <- trap_no_abundance_noNA %>%
    gather(key = "species", value = "abundance", -trap_no, -area_type, -berger_parker_index,-mcIntosh_index,-shannon_index,-simpsons_index)
  
  # Calculate mean and standard error for each species and area type
  trap_abundance_summary_data <- trap_no_abundance_noNA_long %>%
    group_by(species, area_type) %>%
    summarise(mean_abundance = mean(abundance),
              se = sd(abundance) / sqrt(n()))
  
  # Plot the data with error bars
  ggplot(trap_abundance_summary_data, aes(x = species, y = mean_abundance, fill = area_type)) +
    geom_bar(stat = "identity", position = "dodge") +
    geom_errorbar(aes(ymin = mean_abundance - se, ymax = mean_abundance + se), width = 0.2, position = position_dodge(width = 0.9)) +
    labs(y = "Mean Abundance across Trapping Sites",
         x = "Species",
         fill = "Area Type") +
    scale_fill_manual(values = c("N" = "#1F77B4", "U" = "#9E2626"), labels = c("N" = "Undisturbed", "U" = "Disturbed")) +
    scale_x_discrete(labels = c("immi"="D. immigrans","mel"="D. melanogaster", "suz"="D. suzukii", "sub"="D. subobscura", "obs"="D. obscura", "bus"="D. busckii", "fun"="D. funebris", "hyd"="D. hydei", "tris"="D. tristis", "NA"="NA")) +
    theme_minimal()

  
  
#Diversity 

  # Making sure all indices are numeric
  trap_no_abundance_noNA <- trap_no_abundance_noNA %>%
    mutate(across(c(simpsons_index, shannon_index, berger_parker_index, mcIntosh_index), as.numeric))
  
  # Reorganising data and adding summary statistics
  summary_diversity_data <- trap_no_abundance_noNA %>%
    pivot_longer(cols = c(simpsons_index, shannon_index, berger_parker_index, mcIntosh_index),
                 names_to = "diversity_index",
                 values_to = "value") %>%
    group_by(area_type, diversity_index) %>%
    summarise(mean_value = mean(value),
              se = sd(value) / sqrt(n()),
              .groups = "drop")

  #Diversity index Plots
  
  #Simpsons
  
  plot_simpsons <- ggplot(summary_diversity_data %>% filter(diversity_index == "simpsons_index"), 
                          aes(x = area_type, y = mean_value, fill = area_type)) +
    geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
    geom_errorbar(aes(ymin = mean_value - se, ymax = mean_value + se), 
                  position = position_dodge(width = 0.9), 
                  width = 0.2) +
    labs(y = "Mean Diversity Index Value", fill = "Area Type", x = "")+
    scale_fill_manual(values = c("N" = "#4A2354", "U" = "#BB8FCE"), labels = c("N" = "Undisturbed", "U" = "Disturbed"))+
    theme_minimal()+
    ylim(0,1)+
    scale_x_discrete(labels = c("N"="Undisturbed","U"="Disturbed"))+
    guides(fill='none')
  
  # Plot for Shannon's Index
  plot_shannon <- ggplot(summary_diversity_data %>% filter(diversity_index == "shannon_index"), 
                         aes(x = area_type, y = mean_value, fill = area_type)) +
    geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
    geom_errorbar(aes(ymin = mean_value - se, ymax = mean_value + se), 
                  position = position_dodge(width = 0.9), 
                  width = 0.2) +
    labs(y = "Mean Diversity Index Value", fill = "Area Type", x = "") +
    scale_fill_manual(values = c("N" = "#0B5345", "U" = "#73C6B6"), labels = c("N" = "Undisturbed", "U" = "Disturbed"))+
    theme_minimal()+
    scale_x_discrete(labels = c("N"="Undisturbed","U"="Disturbed"))+
    guides(fill='none')
  
  # Plot for Berger-Parker Index
  plot_berger_parker <- ggplot(summary_diversity_data %>% filter(diversity_index == "berger_parker_index"), 
                               aes(x = area_type, y = mean_value, fill = area_type)) +
    geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
    geom_errorbar(aes(ymin = mean_value - se, ymax = mean_value + se), 
                  position = position_dodge(width = 0.9), 
                  width = 0.2) +
    labs(y = "Mean Diversity Index Value", fill = "Area Type", x = "")+
    scale_fill_manual(values = c("N" = "#7D6608", "U" = "#F7DC6F"), labels = c("N" = "Undisturbed", "U" = "Disturbed"))+
    theme_minimal()+
    ylim(0,1)+
    scale_x_discrete(labels = c("N"="Undisturbed","U"="Disturbed"))+
    guides(fill='none')
  
  # Plot for McIntosh Index
  plot_mcintosh <- ggplot(summary_diversity_data %>% filter(diversity_index == "mcIntosh_index"), 
                          aes(x = area_type, y = mean_value, fill = area_type)) +
    geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
    geom_errorbar(aes(ymin = mean_value - se, ymax = mean_value + se), 
                  position = position_dodge(width = 0.9), 
                  width = 0.2) +
    labs(y = "Mean Diversity Index Value", x = "") +
    scale_fill_manual(values = c("N" = "#6E2C00", "U" = "#E59866"), labels = c("N" = "Undisturbed", "U" = "Disturbed"))+ 
    theme_minimal()+
    ylim(0,1)+
    scale_x_discrete(labels = c("N"="Undisturbed","U"="Disturbed"))+
    guides(fill='none')
  
 plot_mcintosh
 
 
 # Combine plots
 combined_plots <- plot_simpsons + plot_shannon + plot_berger_parker + plot_mcintosh
 
 # Display combined plots with one legend
 combined_plots + plot_layout(guides = 'collect', axes = 'collect') + plot_annotation(tag_levels = 'A')
 

 