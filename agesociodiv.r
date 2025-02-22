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
# "PROFILE OF GENERAL POPULATION AND HOUSING CHARACTERISTICS." Decennial Census, 
# DEC Demographic Profile, Table DP1, 2020

# Set up your Census API key
census_api_key("YOUR_CENSUS_API_KEY", install = TRUE)

# Function to get population data by state, age, and gender with an optional race/ethnic group filter
get_population_data <- function(variables, labels, race_filter = NULL) {
  # Extract population data by state, age, and gender from the 2020 Census DP1 file
  population_data <- get_decennial(
    geography = "state",
    variables = variables,
    year = 2020,
    survey = "dec",
    summary_var = race_filter
  )
  
  # Replace variable codes with labels
  population_data <- population_data %>%
    mutate(variable = recode(variable, !!!labels))
  
  # Reshape the data for better analysis
  population_data <- population_data %>%
    pivot_wider(names_from = variable, values_from = value)
  
  return(population_data)
}

# Define variables and labels for population by age and gender
population_variables <- c(
  "P1_001N", "P1_003N", "P1_004N", "P1_005N", "P1_006N", "P1_007N", "P1_008N", "P1_009N", "P1_010N", "P1_011N",
  "P1_012N", "P1_013N", "P1_014N", "P1_015N", "P1_016N", "P1_017N", "P1_018N", "P1_019N", "P1_020N",
  "P1_021N", "P1_022N", "P1_023N", "P1_024N", "P1_025N", "P1_026N", "P1_027N", "P1_028N", "P1_029N", "P1_030N",
  "P1_031N", "P1_032N", "P1_033N", "P1_034N", "P1_035N", "P1_036N", "P1_037N", "P1_038N", "P1_039N", "P1_040N"
)
population_labels <- c(
  "P1_001N" = "Total",
  "P1_003N" = "Under 5 years (Male)",
  "P1_004N" = "5 to 9 years (Male)",
  "P1_005N" = "10 to 14 years (Male)",
  "P1_006N" = "15 to 19 years (Male)",
  "P1_007N" = "20 to 24 years (Male)",
  "P1_008N" = "25 to 29 years (Male)",
  "P1_009N" = "30 to 34 years (Male)",
  "P1_010N" = "35 to 39 years (Male)",
  "P1_011N" = "40 to 44 years (Male)",
  "P1_012N" = "45 to 49 years (Male)",
  "P1_013N" = "50 to 54 years (Male)",
  "P1_014N" = "55 to 59 years (Male)",
  "P1_015N" = "60 to 64 years (Male)",
  "P1_016N" = "65 to 69 years (Male)",
  "P1_017N" = "70 to 74 years (Male)",
  "P1_018N" = "75 to 79 years (Male)",
  "P1_019N" = "80 to 84 years (Male)",
  "P1_020N" = "85 years and over (Male)",
  "P1_021N" = "Under 5 years (Female)",
  "P1_022N" = "5 to 9 years (Female)",
  "P1_023N" = "10 to 14 years (Female)",
  "P1_024N" = "15 to 19 years (Female)",
  "P1_025N" = "20 to 24 years (Female)",
  "P1_026N" = "25 to 29 years (Female)",
  "P1_027N" = "30 to 34 years (Female)",
  "P1_028N" = "35 to 39 years (Female)",
  "P1_029N" = "40 to 44 years (Female)",
  "P1_030N" = "45 to 49 years (Female)",
  "P1_031N" = "50 to 54 years (Female)",
  "P1_032N" = "55 to 59 years (Female)",
  "P1_033N" = "60 to 64 years (Female)",
  "P1_034N" = "65 to 69 years (Female)",
  "P1_035N" = "70 to 74 years (Female)",
  "P1_036N" = "75 to 79 years (Female)",
  "P1_037N" = "80 to 84 years (Female)",
  "P1_038N" = "85 years and over (Female)"
)

# Summary variables for different races and ethnicities
# Total Population: P1_001N
# White alone: P1_003N
# Black or African American alone: P1_004N
# American Indian and Alaska Native alone: P1_005N
# Asian alone: P1_006N
# Native Hawaiian and Other Pacific Islander alone: P1_007N
# Some Other Race alone: P1_008N
# Two or More Races: P1_009N
# Hispanic or Latino: P2_002N
# White alone, not Hispanic or Latino: P2_003N

# Get total population data
total_population_by_age_gender <- get_population_data(population_variables, population_labels)
print(total_population_by_age_gender)

# Get White only, Not Hispanic or Latino population data
white_population_by_age_gender <- get_population_data(population_variables, population_labels, race_filter = "P2_003N")
print(white_population_by_age_gender)

