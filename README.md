Please find work in progress script for taking in the raw HCUP NASS data files and specification files, processing the variables, constructing models, and visualizing the data patterns/models.

# HCUP NASS 2020 Data Analysis

## Overview

This repository contains scripts and data for analyzing the HCUP NASS 2020 dataset. The analysis focuses on the utilization of ambulatory surgery by White Americans, examining age and sociodemographic diversity. The repository includes scripts for loading and cleaning data, performing statistical analysis, and generating visualizations.

## Repository Structure

- `load_and_clean_data.R`: This script loads and cleans the HCUP NASS 2020 data, defines columns using specification files, merges datasets, and creates subsets for analysis. The cleaned data is saved to CSV files.

- `agesociodiv.r`: This script performs the main analysis of the HCUP NASS 2020 data. It includes model training, ROC curve generation, and the creation of summary tables and diagnostic plots for AUC, sensitivity, and specificity.

- `Overview_Graphs.R`: This script generates various overview graphs and visualizations for the HCUP NASS 2020 data.

## Scripts

### `load_and_clean_data.R`

**Description**: This script loads and cleans the HCUP NASS 2020 data and outputs the combined file.

**Key Functions**:
- `install_if_missing(packages)`: Checks and installs missing packages.
- `load_libraries(packages)`: Loads required libraries.
- `define_columns(data, spec_filename)`: Reads and defines columns using HCUP NASS specification files.

**Steps**:
1. Load required packages.
2. Define columns for each dataset using specification files.
3. Import datasets using `data.table`'s `fread` function.
4. Merge datasets by Hospital ID and Patient ID.
5. Convert merged data to a `data.table` for easier manipulation.
6. Remove duplicate columns and unnecessary suffixes.
7. Convert columns to factor variables.
8. Define coarse and granular age groups.
9. Write cleaned data to CSV files.
10. Create subsets for analysis and write to CSV files.

### `agesociodiv.r`

**Description**: This script analyzes the age and sociodemographic diversity of the HCUP NASS 2020 data.

**Key Functions**:
- `install_if_missing(packages)`: Checks and installs missing packages.
- `load_libraries(packages)`: Loads required libraries.

**Steps**:
1. Load required packages.
2. Convert categorical variables to factors.
3. Split data by age groups.
4. Define and train models for each age group.
5. Generate ROC curves and calculate AUC, sensitivity, and specificity.
6. Create summary tables and diagnostic plots.
7. Save results to CSV and PDF files.

### `Overview_Graphs.R`

**Description**: This script generates various overview graphs and visualizations for the HCUP NASS 2020 data.

**Key Functions**:
- `install_if_missing(packages)`: Checks and installs missing packages.
- `load_libraries(packages)`: Loads required libraries.

**Steps**:
1. Load required packages.
2. Generate and save overview graphs and visualizations.

## Data Files

- `NASS_2020_all.csv`: Cleaned and combined HCUP NASS 2020 data.
- `NASS_2020_subset65.csv`: Subset of the HCUP NASS 2020 data for individuals aged 65 and older.

## Output Files

- `Summary_by_Age_Group.csv`: Summary table of AUC, sensitivity, and specificity for each model and age group.
- `Diagnostic_Plots_by_Age_Group.pdf`: PDF file containing diagnostic plots for AUC, sensitivity, and specificity by age group and model.

## Usage

1. Set the working directory to the location of the raw HCUP data files and specification files.
2. Run `load_and_clean_data.R` to load, clean, and prepare the data.
3. Run `agesociodiv.r` to perform the main analysis and generate summary tables and diagnostic plots.
4. Run `Overview_Graphs.R` to generate overview graphs and visualizations.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Author

Seena Khosravi
