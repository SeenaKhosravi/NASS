### Overview_Graphs.R

### HCUP NASS 2020 Data Analysis
### Author: SgtKlinger
### Date: 2025-02-10

### Description: This script generates overview graphs
### for the HCUP NASS 2020 data

# List of required packages
required_packages <- 
  c("data.table", "ggplot2", "dplyr")

# Function to check and install missing packages
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) install.packages(new_packages)
}

# Function to load all required libraries
load_libraries <- function(packages) {
  lapply(packages, library, character.only = TRUE)
}

# Check and install missing packages, then load packages
install_if_missing(required_packages)
load_libraries(required_packages)
rm(required_packages, install_if_missing, load_libraries)

# Load the cleaned NASS 2020 data
NASS_2020_all <- fread(file.path(getwd(), "NASS_2020_all.csv"))

# ...additional code for generating graphs...

