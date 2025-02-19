### HCUP NASS 2020 Data Analysis
### Author: SgtKlinger
### Date: 2025-02-10

### Description: This script loads and cleans the
# HCUP NASS 2020 data, performs a linear mixed model
# analysis, and generates various plots and summary statistics.


# List of required packages
required_packages <- 
  c("data.table", "lme4", "ggplot2", "sjPlot", "dplyr", "haven")

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
# define Age groups
NASS_2020_all$DISCWT <- as.numeric(NASS_2020_all$DISCWT)
cols_to_factor <- setdiff(names(NASS_2020_all), c("AGE", "DISCWT", "TOTCHG","TOTAL_AS_ENCOUNTERS"))
NASS_2020_all[, (cols_to_factor) := lapply(.SD, as.factor), .SDcols = cols_to_factor]
rm(cols_to_factor)
NASS_2020_all$AGEGRP <- cut(NASS_2020_all$AGE, breaks = c(0, 18, 40, 55, 65, 70, 80, Inf), labels = c("0-17", "18-39", "40-54", "55-64", "65-69", "70-79", "80+"), right = FALSE)
NASS_2020_all$AGEGRP <- as.factor(NASS_2020_all$AGEGRP)
gc()

# Create subset data.table of NASS_2020_all for analysis
subset_65_50_NASS_2020 <- NASS_2020_all[
  TOTCHG > 1000 & TOTCHG < 1000000 & AGE > 64 & CPTCCS1 %in% names(sort(table(CPTCCS1), decreasing = TRUE)[1:50]),
  .SD, .SDcols = 1:132]
gc()

# Fit the linear mixed models
model <- 
  lmer(TOTCHG ~ CPTCCS1 + (1 | HOSP_NASS), 
    data = subset_65_50_NASS_2020, weights = DISCWT)

# Print the summary of the model
summary(model)

# Plot the fixed effects estimates with confidence intervals
plot_model(model, type = "est", show.values = TRUE, value.offset = .3, ci.lvl = 0.95)

# Plot random effects with confidence intervals
plot_model(model, type = "re", show.values = TRUE, ci.lvl = 0.95)

# Create diagnostic plots
# 1. Residuals vs Fitted with confidence interval
ggplot(model, aes(.fitted, .resid)) +
  geom_point() +
  geom_smooth(method = "loess", se = TRUE) +
  theme_minimal() +
  labs(title = "Residuals vs Fitted")

# 2. Q-Q plot for residuals (Q-Q plots do not typically include confidence intervals)
ggplot(model, aes(sample = .resid)) +
  stat_qq() +
  stat_qq_line() +
  theme_minimal() +
  labs(title = "Q-Q Plot of Residuals")

# Summary table of customer demographics
demographics <- NASS_2020_all %>% 
  group_by(Customer) %>% 
  summarise(
    Age = mean(AGE, na.rm = TRUE),
    Gender = unique(FEMALE),
    Income = mean(PAY1, na.rm = TRUE),
    Region = unique(HOSP_REGION)
  )

# Print the demographics table
print(demographics)

# Plotting distributions
# 1. Distribution of Sales
ggplot(NASS_2020_all, aes(Sales)) +
  geom_histogram(binwidth = 10, fill = "blue", color = "black") +
  theme_minimal() +
  labs(title = "Distribution of Sales", x = "Sales", y = "Frequency")

# 2. Distribution of Customer Ages
ggplot(NASS_2020_all, aes(Age)) +
  geom_histogram(binwidth = 5, fill = "green", color = "black") +
  theme_minimal() +
  labs(title = "Distribution of Customer Ages", x = "Age", y = "Frequency")

# 3. Distribution of Income
ggplot(NASS_2020_all, aes(Income)) +
  geom_histogram(binwidth = 5000, fill = "purple", color = "black") +
  theme_minimal() +
  labs(title = "Distribution of Income", x = "Income", y = "Frequency")

# 4. Sales by Region
ggplot(NASS_2020_all, aes(Region, Sales)) +
  geom_boxplot(fill = "orange") +
  theme_minimal() +
  labs(title = "Sales by Region", x = "Region", y = "Sales")
