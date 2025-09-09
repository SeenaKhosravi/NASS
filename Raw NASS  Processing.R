### Raw_NASS_Processing.R
### 
### MIT License
### Copyright (c) 2025 Seena Khosravi
### 
### This script processes the raw 2020 DHS HCUP NASS dataset,
### creates the full dataset and a user defined subset.

### Designed to be run on local R environment.
### Please set config prior to run

# ------------------------------
# Configuration

#set to where you have stored HCUP NASS 2020 dataset and file spec files
setwd("...")

# ------------------------------

# Required packages
required_packages <- c(
  "data.table", 
  "dplyr", 
  "stringr",
  "ggplot2",
  "gtsummary",
  "corrplot",
  "parallel"  # For faster processing
)

# Install and load packages
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) install.packages(new_packages)
}

load_libraries <- function(packages) {
  invisible(lapply(packages, library, character.only = TRUE))
}

install_if_missing(required_packages)
load_libraries(required_packages)

# PART 1: LOAD AND CLEAN DATA ------------------------------

message("Starting NASS 2020 data processing...")
message(paste("Working directory:", getwd()))

# Function to read and define columns using HCUP NASS specification files
define_columns <- function(data, spec_filename) {
  spec_file <- file.path(getwd(), spec_filename)
  if(!file.exists(spec_file)) {
    stop(paste("Specification file not found:", spec_file))
  }
  spec_lines <- readLines(spec_file)
  column_info <- spec_lines[grep("NASS 2020", spec_lines)]
  column_names <- sapply(column_info, function(x) 
    trimws(paste(strsplit(x, "")[[1]][25:43], collapse = "")))
  colnames(data) <- column_names
  return(data)
}

# Import datasets
message("Loading NASS 2020 datasets...")
HOSPITALS <- fread(file.path(getwd(), "NASS_2020_Hospital.csv"))
ENCOUNTERS <- fread(file.path(getwd(), "NASS_2020_Encounter.csv"))
COMORBIDITES <- fread(file.path(getwd(), "NASS_2020_DX_PR_GRPS.csv"))

# Define columns using specification files
message("Defining columns using specification files...")
HOSPITALS <- define_columns(HOSPITALS, "FileSpecifications_NASS_2020_Hospital.txt")
ENCOUNTERS <- define_columns(ENCOUNTERS, "FileSpecifications_NASS_2020_Encounter.txt")
COMORBIDITES <- define_columns(COMORBIDITES, "FileSpecifications_NASS_2020_DX_PR_GRPS.txt")

# Merge datasets
message("Merging datasets...")
merged1 <- merge(HOSPITALS, ENCOUNTERS, by = "HOSP_NASS")
rm(HOSPITALS, ENCOUNTERS)
gc()

merged_all <- merge(merged1, COMORBIDITES, by = "KEY_NASS")
rm(merged1, COMORBIDITES)
gc()

# Clean merged data
NASS_2020_all <- as.data.table(merged_all)
rm(merged_all)
gc()

# Remove duplicate columns
cols_to_remove <- grep("\\.y$", names(NASS_2020_all), value = TRUE)
if(length(cols_to_remove) > 0) {
  NASS_2020_all[, (cols_to_remove) := NULL]
}

# Remove .x suffix from column names
new_colnames <- gsub("\\.x$", "", names(NASS_2020_all))
setnames(NASS_2020_all, old = names(NASS_2020_all), new = new_colnames)

# Convert columns to appropriate types
message("Converting column types...")
NASS_2020_all$DISCWT <- as.numeric(NASS_2020_all$DISCWT)
cols_to_factor <- setdiff(names(NASS_2020_all), 
                          c("AGE", "DISCWT", "TOTCHG", "TOTAL_AS_ENCOUNTERS"))
NASS_2020_all[, (cols_to_factor) := lapply(.SD, as.factor), .SDcols = cols_to_factor]

# Define age groups
NASS_2020_all$AGEGRP <- cut(NASS_2020_all$AGE, 
                            breaks = c(0, 18, 65, Inf), 
                            labels = c("0-17", "18-64", "65+"), 
                            right = FALSE)
NASS_2020_all$AGEGRP <- as.factor(NASS_2020_all$AGEGRP)

NASS_2020_all$AGEGRP2 <- cut(NASS_2020_all$AGE, 
                             breaks = c(0, 18, 40, 55, 65, 70, 80, Inf), 
                             labels = c("0-17", "18-39", "40-54", "55-64", 
                                       "65-69", "70-79", "80+"), 
                             right = FALSE)
NASS_2020_all$AGEGRP2 <- as.factor(NASS_2020_all$AGEGRP2)

# PART 2: SAVE FULL DATASET ------------------------------

message("Saving full NASS 2020 dataset...")
output_path <- file.path(getwd(), "nass_2020_all.csv")
fwrite(NASS_2020_all, output_path)
message(paste("Full dataset saved to:", output_path))
message(paste("Dataset dimensions:", nrow(NASS_2020_all), "rows x", 
              ncol(NASS_2020_all), "columns"))

# PART 3: CREATE SUBSET DATASET ------------------------------

message("Creating subset dataset...")

# Example subset: Medicare patients (65+) with common procedures
# Users can modify this criteria as needed
NASS_2020_subset <- NASS_2020_all[
  AGE >= 65 & 
  TOTCHG > 1000 & 
  TOTCHG < 1000000 & 
  CPTCCS1 %in% names(sort(table(CPTCCS1), decreasing = TRUE)[1:50]),
  .SD, 
  .SDcols = c(1:27, 57, 87:132)
]

message(paste("Subset dataset dimensions:", nrow(NASS_2020_subset), "rows x", 
              ncol(NASS_2020_subset), "columns"))

subset_path <- file.path(getwd(), "nass_2020_subset.csv")
fwrite(NASS_2020_subset, subset_path)
message(paste("Subset dataset saved to:", subset_path))

# PART 4: GENERATE SUMMARY STATISTICS ------------------------------

message("Generating summary statistics...")

# Summary for full dataset
summary_stats <- list(
  n_hospitals = length(unique(NASS_2020_all$HOSP_NASS)),
  n_encounters = nrow(NASS_2020_all),
  n_procedures = length(unique(NASS_2020_all$CPTCCS1)),
  age_summary = summary(NASS_2020_all$AGE),
  charge_summary = summary(NASS_2020_all$TOTCHG)
)

# Print summary
cat("\n========== NASS 2020 Dataset Summary ==========\n")
cat("Number of hospitals:", summary_stats$n_hospitals, "\n")
cat("Number of encounters:", summary_stats$n_encounters, "\n")
cat("Number of unique procedures:", summary_stats$n_procedures, "\n")
cat("\nAge distribution:\n")
print(summary_stats$age_summary)
cat("\nTotal charge distribution:\n")
print(summary_stats$charge_summary)

# Save summary to file
summary_path <- file.path(getwd(), "nass_2020_summary.txt")
sink(summary_path)
cat("NASS 2020 Data Processing Summary\n")
cat("Generated on:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("=====================================\n\n")
for(name in names(summary_stats)) {
  cat(name, ":\n")
  print(summary_stats[[name]])
  cat("\n")
}
sink()

message(paste("Summary statistics saved to:", summary_path))

# PART 5: VALIDATION CHECKS ------------------------------

message("Running validation checks...")

# Check for missing values
missing_check <- sapply(NASS_2020_all, function(x) sum(is.na(x)))
high_missing <- missing_check[missing_check > nrow(NASS_2020_all) * 0.1]

if(length(high_missing) > 0) {
  print("Columns with >10% missing values:")
  print(high_missing)
}

# Check data ranges
if(any(NASS_2020_all$AGE < 0 | NASS_2020_all$AGE > 120, na.rm = TRUE)) {
  print("Invalid age values detected")
}

if(any(NASS_2020_all$TOTCHG < 0, na.rm = TRUE)) {
  print("Negative charge values detected")
}

message("\nProcessing complete!")
message("Generated files:")
message(paste("  1. Full dataset:", output_path))
message(paste("  2. Subset dataset:", subset_path))
message(paste("  3. Summary statistics:", summary_path))
