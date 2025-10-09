# NASS 2020 Research Analysis Pipeline

[![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/SeenaKhosravi/NASS/blob/main/Analysis_NASS.ipynb)
[![Launch on GCE](https://img.shields.io/badge/Google%20Cloud-Launch%20Instance-4285F4?style=flat-square&logo=google-cloud)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/SeenaKhosravi/NASS&cloudshell_tutorial=deploy/gce-tutorial.md)
[![Python](https://img.shields.io/badge/Python-3.8+-blue?style=flat-square&logo=python)](https://python.org)
[![R](https://img.shields.io/badge/R-4.0+-276DC3?style=flat-square&logo=r)](https://r-project.org)

> **Scalable, Multi-Platform, Open-Access, Reproducible Data Pipeline**  
> Analyzing socioeconomic and demographic drivers of ambulatory surgery usage using the 2020 HCUP National Ambulatory Surgery Sample

## Overview

This repository provides a comprehensive analysis pipeline for examining socioeconomic and demographic factors influencing ambulatory surgery usage patterns using the [HCUP National Ambulatory Surgery Sample (NASS) 2020](https://hcup-us.ahrq.gov/db/nation/nass/NASS_Introduction_2020.jsp). The pipeline combines Python for data processing with R for statistical analysis and visualization, producing publication-ready research outputs including an automated poster generation system.

### Key Features

- **Multi-Platform Compatibility**: Runs on local environments, Jupyter servers, Google Colab, and cloud VM instances
- **Dual Data Access**: Public simulated dataset (no DUA required) and full encrypted dataset (DUA compliant)
- **Hybrid Architecture**: Python primary with R integration via `rpy2` for specialized statistical analysis
- **Advanced Analytics**: Descriptive statistics, Census comparisons, multi-level modeling, and machine learning
- **Automated Visualization**: Unified theming system with automated poster generation
- **Cloud-Ready**: Supports Google Cloud Storage, encrypted authentication, and scalable compute resources
- **Security-First**: Encrypted key management for sensitive data and API access

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Data Sources  │    │  Compute Layer  │    │     Outputs     │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • GitHub (Sim.) │───▶│ Python Primary  │───▶│ • Research Plots│
│ • GCS (Full)    │    │ • Data Loading  │    │ • Statistics    │
│ • Local Files   │    │ • Preprocessing │    │ • ML Models     │
│ • Google Drive  │    │                 │    │ • Final Poster  │
│                 │    │ R Integration   │    │                 │
│ • Census API    │───▶│ • Statistics    │───▶│ • Text Outputs  │
│ • Encrypted     │    │ • Modeling      │    │ • Manifest      │
│   Authentication│    │ • Visualization │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Quick Start

### Option 1: Google Colab (Recommended for Beginners)

1. **Click the Colab badge** at the top of this README
2. **Run the configuration cell** and enter `asa` when prompted for Census data
3. **Execute cells sequentially** - the notebook will auto-install dependencies
4. **Access outputs** in the generated `saved_plots/` and `saved_outputs/` directories

### Option 2: Local Environment

#### Prerequisites

- **Python 3.8+** with Jupyter Lab/Notebook
- **R 4.0+** (4.4+ recommended) 
- **Git** for repository cloning

#### Installation

```bash
# Clone repository
git clone https://github.com/SeenaKhosravi/NASS.git
cd NASS

# Create virtual environment (recommended)
python -m venv nass-env
source nass-env/bin/activate  # Linux/Mac
# or
nass-env\Scripts\activate     # Windows

# Install Python dependencies
pip install jupyter pandas requests rpy2 google-cloud-storage pycryptodome

# Launch Jupyter
jupyter lab Analysis_NASS.ipynb
```

#### R Dependencies

The notebook automatically installs required R packages, but you can pre-install:

```r
# Essential packages
install.packages(c("data.table", "ggplot2", "scales", "survey"))

# Optional packages (installed as needed)
install.packages(c("tidycensus", "lme4", "randomForest", "xgboost"))
```

### Option 3: Cloud VM Deployment

Deploy a pre-configured VM instance with all dependencies:

```bash
# Using Google Cloud Shell
git clone https://github.com/SeenaKhosravi/NASS.git
cd NASS
bash deploy/setup-gce.sh
```

## Data Sources & Configuration

### Simulated Dataset (Default)

- **Source**: GitHub Releases (public access)
- **Size**: ~0.2GB, 139k records
- **DUA**: Not required
- **Usage**: Ideal for testing, development, and demonstrations

### Full Dataset (Research)

- **Source**: [HCUP NASS 2020](https://hcup-us.ahrq.gov/tech_assist/centdist.jsp) via cloud storage
- **Size**: ~12GB, 7.8M records  
- **DUA**: [Nationwide DUA required](https://hcup-us.ahrq.gov/team/NationwideDUA.jsp)
- **Usage**: Complete research analysis

### Configuration Options

Edit the configuration cell to customize data sources:

```python
# Data Source Options
DATA_SOURCE = "github"      # "github", "local", "gcs", "drive"
VERBOSE_PRINTS = True       # Debug output control

# GitHub (default - simulated data)
GITHUB_URL = "https://github.com/SeenaKhosravi/NASS/releases/download/v1.0.0/nass_2020_simulated.csv"

# Local file
LOCAL_FILENAME = "nass_2020_local.csv"

# Google Cloud Storage (encrypted access)
GCS_BUCKET = "nass_2020"
GCS_BLOB = "nass_2020_all.csv"
```

## Security & Authentication

### Census API Access

For Census data comparisons, obtain a free API key:

1. **Register**: [Census API Key Signup](https://api.census.gov/data/key_signup.html)
2. **Configure**: Enter key when prompted, or use `asa` for cached data
3. **Usage**: Automated 2020 DHC population data retrieval

### Encrypted Cloud Access

For full dataset access with cloud storage:

1. **Encryption**: Service account keys encrypted with AES-256-CBC
2. **Storage**: GitHub releases with password protection  
3. **Decryption**: Automatic in-notebook with secure memory cleanup
4. **Fallback**: Graceful degradation to public datasets

```python
# Secure authentication flow
GCS_PASSWORD, CENSUS_PASSWORD, USE_CACHED_CENSUS = configure_access()
```

## Analysis Components

### 1. Data Processing Pipeline

```python
# Automated preprocessing
- Variable filtering (removes 500+ DXCCSR columns)
- Data type cleaning (rpy2 compatibility)
- Variable creation (demographics, income levels)
- Missing data handling
```

### 2. Statistical Analysis

- **Descriptive Statistics**: Hospital characteristics, procedure patterns, demographics
- **Census Comparisons**: Age-gender stratified validation against 2020 US Census
- **Advanced Modeling**: Multi-level logistic regression with hospital clustering
- **Machine Learning**: Random Forest, SVM, LASSO, XGBoost with performance comparison

### 3. Visualization System

```r
# Unified theming system
theme_poster <- theme_minimal() + custom_styling()

# Consistent color palettes
primary_colors    # Professional analysis plots
race_colors_unified   # Demographic visualizations  
census_colors     # Red-white-blue for validation
```

### 4. Output Generation

- **Research Plots**: High-resolution PNG/PDF with consistent styling
- **Text Outputs**: Statistical summaries and model results  
- **Automated Poster**: Publication-ready research poster with QR codes
- **Metadata Tracking**: Complete analysis provenance

## Generated Outputs

### Plot Categories

| Category | Description | Examples |
|----------|-------------|----------|
| **Descriptive** | Hospital and procedure patterns | `hospital_distribution.png`, `top_procedures_income.png` |
| **Validation** | Census comparisons | `census_comparison_lines.png`, `census_comparison_hourglass.png` |
| **Analysis** | Statistical modeling results | `odds_ratios_forest_plot.png`, `ml_combined_importance_roc.png` |
| **Reference** | Supporting documentation | `top_10_procedures_table.txt`, `comprehensive_dataset_summary.txt` |

### Automated Poster

The pipeline generates a publication-ready research poster:

- **Format**: 32"×18" (16:9 ratio) suitable for conference presentation
- **Layout**: 4×3 grid with introduction, methodology, results, and interactive elements
- **Quality**: 300 DPI PNG and PDF outputs
- **Interactive**: QR code linking to live Colab notebook

## Advanced Configuration

### Environment Variables

```bash
# Census API configuration
export CENSUS_API_KEY="your_census_api_key"
export USE_CACHED_CENSUS="true"  # Use pre-saved data

# Cloud storage configuration  
export GCS_ENCRYPTED_KEY_URL="https://github.com/.../gcs_key.enc"
export CENSUS_ENCRYPTED_KEY_URL="https://github.com/.../census_key.enc"
```

### Performance Tuning

```python
# Memory optimization for large datasets
- Chunked CSV reading for files >500MB
- Smart sampling for ML demonstrations  
- Efficient data.table operations in R
- Automatic garbage collection
```

### Custom Analysis Extensions

```r
# Add custom visualizations
save_plot_for_poster(plot_object, 
                    name = "custom_analysis", 
                    description = "Custom Analysis Description",
                    category = "analysis")

# Add text outputs
save_text_output(analysis_results, 
                 name = "custom_results",
                 description = "Custom Results Summary")
```

## Troubleshooting

### Common Issues

**rpy2 Installation Failures**
```bash
# Windows: Install Visual Studio Build Tools
# Linux: sudo apt-get install r-base-dev
# macOS: xcode-select --install
conda install -c conda-forge rpy2  # Alternative installation
```

**R Package Installation**
```r
# Set alternative repositories
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Install from source if binary fails
install.packages("package_name", type = "source")
```

**Memory Issues with Large Data**
```python
# Enable memory optimization
VERBOSE_PRINTS = False  # Reduce output
# Use smaller sample sizes for ML demonstrations
# Ensure adequate RAM (8GB+ recommended for full dataset)
```

### Environment Recovery

Use the built-in status check and recovery system:

```python
# In notebook: run the status check cell
quick_health_check()  # Diagnose issues
quick_recovery()      # Attempt automatic fixes
mini_reset()          # Clean restart if needed
```

## Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/enhancement`)
3. **Test** with both simulated and full datasets (if available)
4. **Commit** changes (`git commit -am 'Add enhancement'`)
5. **Push** to branch (`git push origin feature/enhancement`)
6. **Create** a Pull Request

### Development Guidelines

- Maintain Python 3.8+ and R 4.0+ compatibility
- Follow existing code style and documentation patterns
- Test multi-platform compatibility (local, Colab, cloud)
- Update README.md for significant changes
- Ensure DUA compliance for any full dataset modifications

## Citations & References

### Data Source
Agency for Healthcare Research and Quality (AHRQ). (2020). *Healthcare Cost and Utilization Project (HCUP) National Ambulatory Surgery Sample (NASS)*. U.S. Department of Health & Human Services. Available: https://hcup-us.ahrq.gov/db/nation/nass/

### Software & Tools

**Core Languages:**
- R Core Team. (2024). *R: A Language and Environment for Statistical Computing*. R Foundation for Statistical Computing. https://www.R-project.org/
- Python Software Foundation. (2024). *Python Programming Language*. https://python.org/

**Key Python Packages:**
- McKinney, W. (2010). *pandas: A foundational Python library for data analysis and statistics*. https://pandas.pydata.org/
- Gautier, L. (2024). *rpy2: A simple and efficient access to R from Python*. https://rpy2.github.io/

**Key R Packages:**
- Dowle, M. & Srinivasan, A. (2024). *data.table: Extension of data.frame*. https://r-datatable.com/
- Wickham, H. (2016). *ggplot2: Elegant Graphics for Data Analysis*. Springer-Verlag New York. https://ggplot2.tidyverse.org/
- Lumley, T. (2024). *survey: Analysis of complex survey samples*. https://r-survey.r-forge.r-project.org/

**Cloud & Infrastructure:**
- Google LLC. (2024). *Google Cloud Platform*. https://cloud.google.com/
- Google LLC. (2024). *Google Colaboratory*. https://colab.research.google.com/

**Census Data:**
- U.S. Census Bureau. (2020). *2020 Demographic and Housing Characteristics File (DHC)*. https://www.census.gov/programs-surveys/decennial-census/data/datasets.html

---

*For questions, issues, or contributions, please use the [GitHub Issues](https://github.com/SeenaKhosravi/NASS/issues) system or submit a pull request.*

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## Author

**Seena Khosravi** 
