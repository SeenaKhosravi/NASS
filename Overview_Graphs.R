### Overview_Graphs.R

### MIT License
### 
### Copyright (c) 2025 Seena Khosravi
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

### HCUP NASS 2020 Data Analysis
### Author: Seena Khosravi
### Date: 2025-02-10

### Description: This script generates overview graphs
### for the HCUP NASS 2020 data

### STATUS: Complete, Not Tested
### NOTE: This script is designed to be run in RStudio
### and assumes the working directory is set to the location of the data files.
### NOTE: This script assumes that the cleaned NASS 2020 data
### is available in the working directory as "NASS_2020_all.csv".

# List of required packages
required_packages <- c("data.table", "ggplot2", "dplyr")

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

# Define labels for factor variables
teach_labels <- c("0" = "Non-Teaching", "1" = "Teaching")
location_labels <- c("0" = "Rural", "1" = "Urban")
bed_labels <- c("1" = "0-99", "2" = "100-299", "3" = "300+")
region_labels <- c("1" = "Northeast", "2" = "Midwest", "3" = "South", "4" = "West")
race_labels <- c("1" = "White", "2" = "Black", "3" = "Hispanic", "4" = "Asian/Pacific", "5" = "Native", "6" = "Other")
pay_labels <- c("1" = "Medicare", "2" = "Medicaid", "3" = "Private", "4" = "Self", "5" = "No Charge", "6" = "Other")
pl_nchs_labels <- c("1" = "Large Central", "2" = "Large Fringe", "3" = "Medium", "4" = "Small", "5" = "Micro", "6" = "Non-core")

# Define a consistent theme for all plots
custom_theme <- theme_minimal() +
  theme(
    text = element_text(size = 12),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom",
    legend.title = element_blank()
  )

# FIGURE 1a: Hospital Overview by Location, Teaching Status, Region segmented by bed size
ggplot(NASS_2020_all, aes(x = HOSP_REGION, fill = HOSP_BEDSIZE_CAT)) +
  geom_bar() +
  custom_theme +
  xlab("US Region") +
  ggtitle("Hospitals within NASS 2020 Dataset", subtitle = "Segmented by Bed Size Category") +
  guides(fill = guide_legend(title = "Bed Size Category")) +
  scale_fill_discrete(labels = bed_labels) +
  facet_grid(HOSP_LOCATION ~ HOSP_TEACH, labeller = labeller(HOSP_TEACH = teach_labels, HOSP_LOCATION = location_labels, HOSP_REGION = region_labels))

# FIGURE 1b: Hospital Ambulatory surgery Encounters Distribution by Locations, Teaching Status, Region
ggplot(NASS_2020_all, aes(x = HOSP_REGION, y = TOTAL_AS_ENCOUNTERS)) +
  geom_boxplot() +
  custom_theme +
  xlab("US Region") +
  ggtitle("Hospitals within NASS 2020 Dataset", subtitle = "Distribution of Ambulatory Surgery Volumes") +
  facet_grid(HOSP_LOCATION ~ HOSP_TEACH, labeller = labeller(HOSP_TEACH = teach_labels, HOSP_LOCATION = location_labels))

# Prepare top 10 procedure list for figure 2
CCS_total <- table(NASS_2020_all$CPTCCS1)
TopCPT <- tail(names(sort(CCS_total)), 10)
NASS_2020_TopCPT <- subset(NASS_2020_all, CPTCCS1 %in% TopCPT)
NASS_2020_TopCPT$CPTCCS1 <- factor(NASS_2020_TopCPT$CPTCCS1, levels = rev(TopCPT))

# FIGURE 2a: Top 10 Most Common Ambulatory Surgeries by income quartile
ggplot(subset(NASS_2020_TopCPT, ZIPINC_QRTL > 0 & ZIPINC_QRTL < 5), aes(x = CPTCCS1, fill = ZIPINC_QRTL)) +
  geom_bar() +
  custom_theme +
  xlab("Top 10 CCS Procedure Codes") +
  ggtitle("Most Common Ambulatory Surgery Encounters in NASS 2020 Dataset", subtitle = "Segmented by Median Income Quartile by Patient Zip code") +
  guides(fill = guide_legend(title = "Income Quartile"))

# FIGURE 2b: Top 10 Most Common Ambulatory Surgeries by Race
ggplot(subset(NASS_2020_TopCPT, RACE > 0 & RACE < 7), aes(x = CPTCCS1, fill = RACE)) +
  geom_bar() +
  custom_theme +
  xlab("Top 10 CCS Procedure Codes") +
  ggtitle("Most Common Ambulatory Surgery Encounters in NASS 2020 Dataset", subtitle = "Segmented by Patient's Reported Race") +
  guides(fill = guide_legend(title = "Race")) +
  scale_fill_discrete(labels = race_labels)

# FIGURE 3a: Patient Age distributions by Urban-Rural class and US Region, segmented by Race
ggplot(subset(NASS_2020_all, FEMALE >= 0 & RACE > 0 & PL_NCHS > 0), aes(x = AGE, y = ..count..)) +
  geom_density(aes(fill = RACE), position = "stack") +
  custom_theme +
  xlab("Age") +
  xlim(0, 100) +
  ggtitle("Patients within NASS 2020 Dataset", subtitle = "Age distributions by Urban-Rural Class & US Region, Segmented by Reported Race") +
  guides(fill = guide_legend(title = "Reported Race")) +
  scale_fill_discrete(labels = race_labels) +
  facet_grid(HOSP_REGION ~ PL_NCHS, labeller = labeller(HOSP_REGION = region_labels, PL_NCHS = pl_nchs_labels))

# FIGURE 3b: Patient Age distributions by Urban-Rural class and US Region, segmented by Payer Status
ggplot(subset(NASS_2020_all, FEMALE >= 0 & PAY1 > 0 & PL_NCHS > 0), aes(x = AGE, y = ..count..)) +
  geom_density(aes(fill = PAY1), position = "stack") +
  custom_theme +
  xlab("Age") +
  xlim(0, 100) +
  ggtitle("Patients within NASS 2020 Dataset", subtitle = "Age distributions by Urban-Rural Class & US Region, Segmented by Payer Status") +
  guides(fill = guide_legend(title = "Payer Status")) +
  scale_fill_discrete(labels = pay_labels) +
  facet_grid(HOSP_REGION ~ PL_NCHS, labeller = labeller(HOSP_REGION = region_labels, PL_NCHS = pl_nchs_labels))

# FIGURE 8: Patients by Age Group Segmented by Payer and Race
NASS_2020_all$AGEGRP <- cut(NASS_2020_all$AGE, breaks = c(0, 18, 65, 120), include.lowest = TRUE, right = FALSE)
ggplot(subset(NASS_2020_all, RACE > 0 & RACE < 7 & PAY1 > 0 & PAY1 < 7 & !is.na(AGEGRP)), aes(x = RACE, fill = PAY1)) +
  geom_bar(position = "fill") +
  custom_theme +
  xlab("RACE") +
  ggtitle("Patients within NASS 2020 Dataset", subtitle = "By Age Group Segmented by Payer and Race") +
  guides(fill = guide_legend(title = "Payer")) +
  scale_fill_discrete(labels = pay_labels) +
  facet_grid(~ AGEGRP)



