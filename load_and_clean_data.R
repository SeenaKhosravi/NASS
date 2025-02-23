###load_and_clean_data.R

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

### Description: This script loads and cleans the
### HCUP NASS 2020 data and outputs the combined file

### STATUS: COMPLETE, TESTED, AND WORKING
### NOTE: This script is designed to be run in RStudio
### and assumes the working directory is set to the location of the
### raw HCUP data files and specification files

# List of required packages
required_packages <- 
  c("data.table", "lme4", "ggplot2", "sjPlot", "dplyr")

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

# Function to read and define columns using HCUP NASS specification files
define_columns <- function(data, spec_filename) {
  spec_file <- file.path(getwd(), spec_filename)
  spec_lines <- readLines(spec_file)
  column_info <- spec_lines[grep("NASS 2020", spec_lines)]
  column_names <- sapply(column_info, function(x) 
    trimws(paste(strsplit(x, "")[[1]][25:43], collapse = "")))
  colnames(data) <- column_names
  rm(spec_file, spec_lines, column_info, column_names)
  return(data)
}

# Import the datasets using data.table's fread function
HOSPITALS <- fread(file.path(getwd(), "NASS_2020_Hospital.csv"))
ENCOUNTERS <- fread(file.path(getwd(), "NASS_2020_Encounter.csv"))
COMORBIDITES <- fread(file.path(getwd(), "NASS_2020_DX_PR_GRPS.csv"))

# Define columns for each dataset using their respective specification files
HOSPITALS <- define_columns(HOSPITALS, "FileSpecifications_NASS_2020_Hospital.txt")
ENCOUNTERS <- define_columns(ENCOUNTERS, "FileSpecifications_NASS_2020_Encounter.txt")
COMORBIDITES <- define_columns(COMORBIDITES, "FileSpecifications_NASS_2020_DX_PR_GRPS.txt")
rm(define_columns)

# Cross-reference the first two datasets by Hospital ID (HOSP_NASS)
# Then the third dataset by Patient ID (KEY_NASS)
merged1 <- merge(HOSPITALS, ENCOUNTERS, by = "HOSP_NASS")
rm(HOSPITALS, ENCOUNTERS)
merged_all <- merge(merged1, COMORBIDITES, by = "KEY_NASS")
rm(merged1, COMORBIDITES)

# Convert the merged data to a data.table for easier manipulation
# remove unnecessary functions/data, clean memory again
gc()
NASS_2020_all <- as.data.table(merged_all)
rm(merged_all)
gc()

# Remove duplicate columns created by merging
cols_to_remove <- grep("\\.y$", names(NASS_2020_all), value = TRUE)
NASS_2020_all[, (cols_to_remove) := NULL]
rm(cols_to_remove)

# Remove .x suffix from column names
new_colnames <- gsub("\\.x$", "", names(NASS_2020_all))
setnames(NASS_2020_all, old = names(NASS_2020_all), new = new_colnames)
rm(new_colnames)
gc()

# convert all but a few columns to factor (categorical) variables

NASS_2020_all$DISCWT <- as.numeric(NASS_2020_all$DISCWT)
cols_to_factor <- setdiff(names(NASS_2020_all), c("AGE", "DISCWT", "TOTCHG","TOTAL_AS_ENCOUNTERS"))
NASS_2020_all[, (cols_to_factor) := lapply(.SD, as.factor), .SDcols = cols_to_factor]
rm(cols_to_factor)

# define coarse Age groups (peds, adult, >65)
NASS_2020_all$AGEGRP <- cut(NASS_2020_all$AGE, breaks = c(0, 18, 65, Inf), 
    labels = c("0-17", "18-64", "65+"), right = FALSE)
NASS_2020_all$AGEGRP <- as.factor(NASS_2020_all$AGEGRP)

# define more granular Age groups (peds, adult < 40, 40-54, 55-65, 65-70, 70-80, >80)
NASS_2020_all$AGEGRP2 <- cut(NASS_2020_all$AGE, breaks = c(0, 18, 40, 55, 65, 70, 80, Inf), 
    labels = c("0-17", "18-39", "40-54", "55-64", "65-69", "70-79", "80+"), right = FALSE)
NASS_2020_all$AGEGRP2 <- as.factor(NASS_2020_all$AGEGRP2)
gc()

# Write NASS_2020_all to a CSV file in the working directory
fwrite(NASS_2020_all, file.path(getwd(), "NASS_2020_all.csv"))

#####CREATE SUBSET DATA FOR ANALYSIS#####

# Create an AGE, TOTCHG and CPTCCS1 subset data.table of NASS_2020_all
# Remove unnecessary CPT and CCSR columns
NASS_2020_subset65 <- NASS_2020_all[
  TOTCHG > 1000 
  & TOTCHG < 1000000 
  & AGE > 64 
  & CPTCCS1 %in% names(sort(table(CPTCCS1), decreasing = TRUE)[1:50]),  #### Change 50 to whichever top, max 79
  .SD, .SDcols = c(1:27, 57, 87:132)]  
colnames(NASS_2020_subset65)
dim(NASS_2020_subset65)
gc()

# Write NASS_2020_subset65 to a CSV file in the working directory
fwrite(NASS_2020_subset65, file.path(getwd(), "NASS_2020_subset65.csv"))
gc()