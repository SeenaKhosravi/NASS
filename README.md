# HCUP NASS 2020 Data Analysis

## Overview

This repository contains scripts and a notebook for analyzing the HCUP NASS 2020 dataset. The analysis focuses on the utilization of ambulatory surgery, examining socioeconomic and demographic drivers. The repository includes a script for loading and cleaning data, as well as a notebook documenting statistical analysis and generating visualizations.

---

## Repository Structure

- **`load_and_clean_data.R`**: Script for loading, cleaning, and preparing the HCUP NASS 2020 data.
- **`NASS_Analysis_Notebook.ipynb`**: Jupyter notebook for performing statistical analysis and generating visualizations.

---

## Scripts

### `load_and_clean_data.R`

**Description**:  
This script loads and cleans the HCUP NASS 2020 data, defines columns using specification files, merges datasets, and creates subsets for analysis. The cleaned data is saved to CSV files.

**Key Functions**:
- `install_if_missing(packages)`: Checks and installs missing packages.
- `load_libraries(packages)`: Loads required libraries.
- `define_columns(data, spec_filename)`: Reads and defines columns using HCUP NASS 2020 specification files.

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

---

### `NASS_Analysis_Notebook.ipynb`

**Description**:  
This notebook performs statistical analysis and generates visualizations for the HCUP NASS 2020 dataset. It is designed to run in Google Colab and assumes the cleaned data (`NASS_2020_all.csv`) is available in the user's Google Drive.

NOTE: Outputs limited in advance of presentation at conference. Full outputs will be displayed after Oct. 15th. 

**Table of Contents**:

1. **Sociodemographic Analysis**:
   - Setup and Load Data
   - Dataset Overview
   - Institutional Overview
   - Encounter Overview
   - Census Benchmarking
   - Procedure Code Analysis
   - ML Race Classifier Analysis
   - ML Rural-Urban Classifier Analysis
   - Appendix A: Indexing of Case Mix and Diversity vs. Government Pay Mix
   - Appendix B: Time Series of 2020 Volumes
   - Appendix C: Age Progression of Surgical Cases

2. **Poster Space Setup**:
   - Combines all visualizations into a single PDF for presentation.

---

## Data Files

- **`NASS_2020_all.csv`**: Cleaned and combined HCUP NASS 2020 data.
- **`NASS_2020_subset65.csv`**: Example subset of the HCUP NASS 2020 data for individuals aged 65 and older. Adjust to your needs.

---

## Usage

### Local Machine (16GB of RAM or more):
1. Set the working directory to the location of the raw HCUP data files and specification files.
2. Run `load_and_clean_data.R` to load, clean, and prepare the data.

### Google Colab (Higher Ram option):
1. Upload `NASS_2020_all.csv` to the root of your Google Drive (ensure it is private).
2. Open the `NASS_Analysis_Notebook.ipynb` in Google Colab (use the badge below or open the notebook directly from this repository).
3. Run the notebook to perform the analysis and generate visualizations.

<a href="https://colab.research.google.com/github/SeenaKhosravi/NASS/blob/main/NASS_Analysis_Notebook.ipynb" target="_parent">
    <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>

---

## Outputs of Notebook

- **Calculations**:
  - `NASS_2020_all_cleaned.csv`: Cleaned and combined HCUP NASS 2020 data.
- **Visualizations**:
  - `Hospitals_by_Region_and_Bed_Size.png`: Bar chart of hospitals by region and bed size.

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## Author

**Seena Khosravi** 
