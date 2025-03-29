# HCUP NASS 2020 Data Analysis

## Overview

This repository contains script for analyzing the HCUP NASS 2020 dataset. The analysis focuses on the utilization of ambulatory surgery, examining geosocioeconomic and demographic drivers. The repository includes a script for loading and cleaning data, and then a notebook documenting the statistical analysis with generated visualizations.

## Repository Structure

- `load_and_clean_data.R`: This script loads and cleans the HCUP NASS 2020 data, defines columns using specification files, merges datasets, and creates subsets for analysis. The cleaned data is saved to CSV files.

- 'NASS_analysis_notebook.npyb': This is the notebook of the analysis. Includes p

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

## Data Files

- `NASS_2020_all.csv`: Cleaned and combined HCUP NASS 2020 data.
- `NASS_2020_subset65.csv`: Example Subset of the HCUP NASS 2020 data for individuals aged 65 and older. Adjust to your needs.

## Usage

Local Machine (16Gb of RAM or more):
1. Set the working directory to the location of the raw HCUP data files and specification files.
2. Run `load_and_clean_data.R` to load, clean, and prepare the data.

Google Colab ("Higher RAM" seting used):
4. Upload the NASS_2020_all.csv to root of your Google drive. Be sure it is private.  
5. Run the NASS_Analysis_Notebook.ipynb (either via opening this repo in Google Colab, or using the link at head of the notebook).

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Author

Seena Khosravi
