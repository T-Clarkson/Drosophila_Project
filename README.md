# Data and Code Summary of 'Fruit flies as bioindicators: Drosophila species distribution relative to environmental disturbance'
## 700041182
 
All statistical analyses conducted for this research project can be reproduced using the data files and R code provided in this repository. Spatial autocorrelation analyses can be recreated using the provided data in ArcGIS Pro, using the 'spatial autocorrelation' geoprocessing tool.

## Workflow

The primary files for the data are within the 'data' folder. 'raw_drosophila_data.csv/xlsx', contains the unprocessed data containing a unique row for each individual fruit fly identified. The 'site_coords.csv/xlsx' file is necessary only if intending to run the spatial autocorrelation analyses. Several data frames are created throughout the provided code which can be ran for replication.

# Contents Description
## .gitattributes
## .gitignore
Defining features to not commit to the repository.
## Drosophila_Project.Rproj
The project file for this research project.
## README.md
The file you're currently reading, summarising the contents of the repository.
## R_worksheet.R
The main workspace for the coding and visualisations of data. The contents are rough. Please refer to the 'code_summary.html' or 'drosophila_markdown.Rmd' for neat and structured presentation of the code used.
## abundance_coord.csv
Data frame written by code in the R project. This data is re-organised to a wide format, with columns for each species, merged with the diversity index values and trap coordinates.

- **trap_no** = The unique identifer of the trap from which that individual was collected.
- **area_type** = Indicates the classification of the trap at which the individual was collected. (N = Undisturbed, U = Disturbed)
- **bus** = The total abundance of *D. busckii* in each trap.
- **fun** = The total abundance of *D. funebris* in each trap.
- **hyd** = The total abundance of *D. hydei* in each trap.
- **immi** = The total abundance of *D. immigrans* in each trap.
- **mel** = The total abundance of *D. melanogaster* in each trap.
- **obs** = The total abundance of *D. obscura* in each trap.
- **sub** = The total abundance of *D. subobscura* in each trap.
- **suz** = The total abundance of *D. suzukii* in each trap.
- **tris** = The total abundance of *D. tristis* in each trap.
- **simpsons_index** = The Simpson's diversity index value for each trap.
- **shannon_index** = The Shannnon's diversity index value for each trap.
- **berger_parker_index** = The Berger-Parker index value for each trap.
- **mcIntosh_index** = The McIntosh's diversity index value for each trap.
- **lat** = Latitude of the trap in decimal degrees
- **long** = Longitude of the trap in decimal degrees
## code_summary.html
The knitted 'drosophila_markdown.Rmd' file, providing all of the fucntional code for analyses and visualisation with descriptions of what the code does.
## draft_markdown.tex
## drosophila_markdown.Rmd
The R markdown file for the code used in this project.
## 'data' folder
### autocorrelation_results.csv
This file contains the results of the spatial autocorrelation analyses conducted in ArcGIS Pro
- **Species** = This refers to the *Drosophila* species of which the test statistics apply to.
- **Moran's Index** = This is the Moran's I value from the spatial autocorrelation
- **Expected Index** = This is the value we expect under null hypothesis/random spatial distribution
- **Variance** = The variance of the analyses
- **z-score** = The associated z-score
- **p-value** = The associated *p* value
### raw_data_drosophila.csv
This is the raw data from the species identification process.
- **refill_date** = The date on which the banana bait was most recently refilled at the time of collection of this individual. YYYY-MM-DD
- **collect_date** = The date on which the recorded indivdual was collected. YYYY-MM-DD
- **area_type** = Indicates the classification of the trap at which the individual was collected. (N = Undisturbed, U = Disturbed)
- **trap_no** = The unique identifer of the trap from which that individual was collected.
- **species** = The species of the individual. (immi = *D. immigrans*, mel = *D. melanogaster*, hyd = *D. hydei*, bus = *D. busckii*, obs = *D. obscura*, suz = *D. suzukii*, sub = *D. subobscura*, tris = *D. tristis*, fun = *D. funebris*)
- **Notes** = Space for any other observations about the individual
### raw_data_drosophila.xlsx
See above.
### site_coords.csv
This file contains the GPS data of the trap locations.
- **trap_no** = Unique trap identifier
- **lat** = Latitude of the trap in decimal degrees
- **long** = Longitude of the trap in decimal degrees
### site_coords.xlsx
See above.
### t_test_results.csv
This file contains the t-test statistics, comparing abundance across disturbed and undisturbed sites of species that were normally distributed or that could be transformed to normality.

- **Species** = Name of the species that the statistics are associated with
- **t test statistic** = The associated t test statistic
- **Degrees of freedom** = The associated degrees of freedom
- **p-value** = The associated *p*-value
### wilcoxon_results.csv
This file contains the wilcoxon rank-sum/mann-whitney U test statistics comparing the abundance across disturbed and undisturbed sites of species that could not be transformed to normal distribution.

- **Species** = Name of the species that the statistics are associated with
- **W test statistic** = The associated W test statistic
- **p-value** = The associated *p*-value

