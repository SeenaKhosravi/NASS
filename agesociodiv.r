### agesociodiv.r

### MIT License
### 
### Copyright (c) 2025 SgtKlinger
### 
### Permission is hereby granted, free of charge, to any person obtaining a copy
### of this software and associated documentation files (the "Software"), to deal
### in the Software without restriction, including without limitation the rights
### to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
### copies of the Software, and to permit persons to whom the Software is
### furnished to do so, subject to the following conditions:
### 
### The above copyright notice and this permission notice shall be included in all
### copies or substantial portions of the Software.
### 
### THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
### IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
### FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
### AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
### LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
### OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
### SOFTWARE.

### HCUP NASS 2020 Data Analysis - Age and Sociodemographic Diversity
### Author: SgtKlinger
### Date: 2025-02-10

### STATUS: Partially Tested

### Description: This script analyzes the age and sociodemographic diversity
### of the HCUP NASS 2020 data.

YOUR_CENSUS_API_KEY <- "YOUR_CENSUS_API_KEY"  # Replace with your actual Census API key

##########################
# Setup
##########################

# Load required packages
required_packages <- c("data.table", "dplyr", "survey", "tidyverse", "tidycensus")

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

########################################
# Stage 1 Analysis
########################################

# Create a dummy variable WHITE which is 1 when RACE = 1, and 0 otherwise
NASS_2020_all[, WHITE := ifelse(RACE == 1, 1, 0)]

# Calculate the unadjusted proportion of WHITE
unadjusted_proportion_white <- mean(NASS_2020_all$WHITE)
print(paste("Unadjusted proportion of WHITE:", unadjusted_proportion_white))

# Reference value for White Only proportion for the whole US from the 2020 US Census
us_census_white_proportion <- 0.601  # Actual value from the 2020 US Census

# Perform a simple statistical test for the unadjusted proportion
unadjusted_test <- prop.test(sum(NASS_2020_all$WHITE), nrow(NASS_2020_all), p = us_census_white_proportion)
print(unadjusted_test)

##########################################
# Stage 2 Analysis
##########################################

# List of states included in NASS_2020_all
states_in_nass <- c("Alaska", "California", "Colorado", "Connecticut", "District of Columbia", "Florida", "Georgia", "Hawaii", "Iowa",
                    "Illinois", "Indiana", "Kansas", "Kentucky", "Maryland", "Maine", "Michigan", "Minnesota", "Missouri", "North Carolina",
                    "North Dakota", "Nebraska", "New Jersey", "Nevada", "New York", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "South Carolina",
                    "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Wisconsin")


# Import data for total population by state by age from the 2020 Census
# U.S. Census Bureau, U.S. Department of Commerce. 
# 2020 Decennial Census, DHC-A

# Set up your Census API key
census_api_key("YOUR_CENSUS_API_KEY", install = TRUE)

# Function to get population data by state, age, and gender from the 2020 Census DHC-A file
get_population_data <- function(pop_code) {
  variables <- paste0("T01001", "_", sprintf("%03dN", 1:49))
  population_data <- get_decennial(
    geography = "state",
    variables = variables,
    year = 2020,
    pop_group = pop_code,
    sumfile = "ddhca"
  )
  labels <- c(
    "Total",
    "Male: Total",
    "Male: Under 5 years",
    "Male: 5 to 9 years",
    "Male: 10 to 14 years",
    "Male: 15 to 17 years",
    "Male: 18 and 19 years",
    "Male: 20 years",
    "Male: 21 years",
    "Male: 22 to 24 years",
    "Male: 25 to 29 years",
    "Male: 30 to 34 years",
    "Male: 35 to 39 years",
    "Male: 40 to 44 years",
    "Male: 45 to 49 years",
    "Male: 50 to 54 years",
    "Male: 55 to 59 years",
    "Male: 60 and 61 years",
    "Male: 62 to 64 years",
    "Male: 65 and 66 years",
    "Male: 67 to 69 years",
    "Male: 70 to 74 years",
    "Male: 75 to 79 years",
    "Male: 80 to 84 years",
    "Male: 85 years and over",
    "Female: Total",
    "Female: Under 5 years",
    "Female: 5 to 9 years",
    "Female: 10 to 14 years",
    "Female: 15 to 17 years",
    "Female: 18 and 19 years",
    "Female: 20 years",
    "Female: 21 years",
    "Female: 22 to 24 years",
    "Female: 25 to 29 years",
    "Female: 30 to 34 years",
    "Female: 35 to 39 years",
    "Female: 40 to 44 years",
    "Female: 45 to 49 years",
    "Female: 50 to 54 years",
    "Female: 55 to 59 years",
    "Female: 60 and 61 years",
    "Female: 62 to 64 years",
    "Female: 65 and 66 years",
    "Female: 67 to 69 years",
    "Female: 70 to 74 years",
    "Female: 75 to 79 years",
    "Female: 80 to 84 years",
    "Female: 85 years and over"
  )
  
  # Replace variable codes with labels
  population_data <- population_data %>%
    mutate(variable = recode(variable, !!!labels))
  
  # Reshape the data for better analysis
  population_data <- population_data %>%
    pivot_wider(names_from = variable, values_from = value)
  
  return(population_data)
}

# Get the total population data by state, age, and gender
total_population_by_age_gender <- get_population_data("all")

# Print the total population data
print(total_population_by_age_gender)
