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

# Load required packages
required_packages <- c("data.table", "dplyr", "survey", "tidyverse")

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

# Calculate the weighted proportion of WHITE using DISCWT
weighted_proportion_white <- svymean(~WHITE, design = svydesign(ids = ~KEY_NASS, weights = ~DISCWT, data = NASS_2020_all))
print(paste("Weighted proportion of WHITE:", coef(weighted_proportion_white)))

# Reference value for White Only proportion for the whole US from the 2020 US Census
us_census_white_proportion <- 0.601  # Actual value from the 2020 US Census

# Perform a simple statistical test for the unadjusted proportion
unadjusted_test <- prop.test(sum(NASS_2020_all$WHITE), nrow(NASS_2020_all), p = us_census_white_proportion)
print(unadjusted_test)

# Perform a simple statistical test for the weighted proportion
weighted_test <- svyttest(WHITE ~ 1, design = svydesign(ids = ~KEY_NASS, weights = ~DISCWT, data = NASS_2020_all), mu = us_census_white_proportion)
print(weighted_test)

##########################################
# Stage 2 Analysis
##########################################

# List of states included in NASS_2020_all
states_in_nass <- c("Alaska", "California", "Colorado", "Connecticut", "District of Columbia", "Florida", "Georgia", "Hawaii", "Iowa",
                    "Illinois", "Indiana", "Kansas", "Kentucky", "Maryland", "Maine", "Michigan", "Minnesota", "Missouri", "North Carolina",
                    "North Dakota", "Nebraska", "New Jersey", "Nevada", "New York", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "South Carolina",
                    "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Wisconsin")

# Load the Census CSV data with specified encoding from working directory
data <- read_csv(file.path(getwd(), "state-raceprevalence-2020.csv"), col_types = cols(.default = "c"), locale = locale(encoding = "UTF-8"))

# Reshape the data for better analysis
reshaped_census_data <- data %>%
  pivot_longer(
    cols = -State,
    names_to = c("Age_Group", "Racial_Ethnic_Group", "Metric"),
    names_sep = " - ",
    values_to = "Value"
  ) %>%
  pivot_wider(
    names_from = Metric,
    values_from = Value
  )


############################################################################NOT TESTED BELOW
# Convert necessary columns to numeric
reshaped_census_data <- reshaped_census_data %>%
  mutate(
    Number = parse_number(Number),
    Percent = parse_number(Percent)
  )

# Save the reshaped data to a new CSV file
write_csv(reshaped_census_data, "c:/Users/laure/Downloads/reshaped_state_raceprevalence_2020.csv")

# Example analysis: Calculate the proportion of White Americans in the whole country
total_white <- reshaped_census_data %>%
  filter(Racial_Ethnic_Group == "White alone, not Hispanic or Latino") %>%
  summarise(Total_Number = sum(Number, na.rm = TRUE))

total_population <- reshaped_census_data %>%
  group_by(State) %>%
  summarise(State_Population = sum(Number, na.rm = TRUE)) %>%
  summarise(Total_Population = sum(State_Population, na.rm = TRUE))

proportion_white <- total_white$Total_Number / total_population$Total_Population
print(proportion_white)

# Example analysis: Calculate the proportion of White Americans in a specific state and age group
state_age_group_white <- reshaped_census_data %>%
  filter(State == "California", Age_Group == "All ages", Racial_Ethnic_Group == "White alone, not Hispanic or Latino") %>%
  summarise(Total_Number = sum(Number, na.rm = TRUE))

state_age_group_population <- reshaped_census_data %>%
  filter(State == "California", Age_Group == "All ages") %>%
  summarise(State_Age_Group_Population = sum(Number, na.rm = TRUE))

proportion_state_age_group_white <- state_age_group_white$Total_Number / state_age_group_population$State_Age_Group_Population
print(proportion_state_age_group_white)
