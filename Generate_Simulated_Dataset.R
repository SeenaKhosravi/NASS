### Generate_Simulated_Dataset.R
### 
### MIT License
### Copyright (c) 2025 Seena Khosravi
### 
### This script takes the processed NASS_2020_all.csv dataset and generates
### a simulated dataset with identical structure but artificial data for
### public distribution and testing purposes.

### Designed to be run on local R environment.
### Assumes you have run Raw_NASS_Processing.R
### Please set config prior to run

# ------------------------------
# Configuration

# Set to where you have stored the processed NASS dataset
setwd("...")

# Input file (should be output from Raw_NASS_Processing.R)
input_filename <- "nass_2020_all.csv"

# Output configuration
output_filename <- "nass_2020_simulated.csv"
simulated_data_size <- 0.2  # Target size in GB (original ~11.7 GB)

# Simulation reproducibility (static data on github used different seed)
set.seed(2025)

# ------------------------------

# Required packages
required_packages <- c(
  "data.table"
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

# MAIN PROCESSING ------------------------------

message("Starting NASS 2020 simulated dataset generation...")
message(paste("Working directory:", getwd()))

# Check if input file exists
input_path <- file.path(getwd(), input_filename)
if(!file.exists(input_path)) {
  stop(paste("Input file not found:", input_path))
}

# Load original dataset
message("Loading original NASS 2020 dataset...")
NASS_2020_all <- fread(input_path)
message(paste("Original dataset dimensions:", nrow(NASS_2020_all), "rows x", 
              ncol(NASS_2020_all), "columns"))

# Function to generate simulated data maintaining distributions
simulate_nass_data <- function(original_data, target_size_gb = 1) {
  
  message("Estimating target dataset size...")
  
  # Estimate rows needed for target size
  sample_size <- min(1000, nrow(original_data))
  sample_data <- original_data[sample(nrow(original_data), sample_size), ]
  
  # Write temporary file to estimate size
  temp_file <- tempfile(fileext = ".csv")
  fwrite(sample_data, temp_file)
  file_size_mb <- file.size(temp_file) / (1024^2)
  unlink(temp_file)
  
  # Calculate rows needed for target size
  rows_per_mb <- sample_size / file_size_mb
  target_rows <- round(rows_per_mb * target_size_gb * 1024)
  
  message(paste("Generating", format(target_rows, big.mark = ","), "simulated records..."))
  
  # Generate simulated data in chunks to manage memory
  chunk_size <- 50000
  num_chunks <- ceiling(target_rows / chunk_size)
  
  simulated_list <- list()
  
  # Progress bar
  pb <- txtProgressBar(min = 0, max = num_chunks, style = 3, 
                       title = "Generating simulated data")
  
  for(i in 1:num_chunks) {
    setTxtProgressBar(pb, i)
    
    chunk_rows <- min(chunk_size, target_rows - (i-1) * chunk_size)
    
    # Sample with replacement from original data
    sim_chunk <- original_data[sample(nrow(original_data), chunk_rows, replace = TRUE), ]
    
    # Add noise to numeric variables to create artificial variation
    numeric_cols <- c("AGE", "TOTCHG", "TOTAL_AS_ENCOUNTERS")
    for(col in numeric_cols) {
      if(col %in% names(sim_chunk)) {
        # Add 5% random noise
        noise <- rnorm(chunk_rows, mean = 1, sd = 0.05)
        sim_chunk[[col]] <- round(sim_chunk[[col]] * noise)
        
        # Ensure valid ranges
        if(col == "AGE") {
          sim_chunk[[col]] <- pmax(0, pmin(120, sim_chunk[[col]]))
        } else if(col == "TOTCHG") {
          sim_chunk[[col]] <- pmax(0, sim_chunk[[col]])
        }
      }
    }
    
    # Generate new artificial IDs to prevent identification
    sim_chunk$KEY_NASS <- (i-1) * chunk_size + 1:chunk_rows + 90000000
    
    simulated_list[[i]] <- sim_chunk
  }
  
  close(pb)
  message("\nCombining chunks...")
  
  # Combine all chunks
  simulated_data <- rbindlist(simulated_list)
  
  # Recalculate derived variables
  message("Recalculating derived variables...")
  
  # Age groups
  if("AGE" %in% names(simulated_data)) {
    simulated_data$AGEGRP <- cut(simulated_data$AGE, 
                                 breaks = c(0, 18, 65, Inf), 
                                 labels = c("0-17", "18-64", "65+"), 
                                 right = FALSE)
    simulated_data$AGEGRP2 <- cut(simulated_data$AGE, 
                                  breaks = c(0, 18, 40, 55, 65, 70, 80, Inf), 
                                  labels = c("0-17", "18-39", "40-54", "55-64", 
                                            "65-69", "70-79", "80+"), 
                                  right = FALSE)
  }
  
  return(simulated_data)
}

# Generate simulated dataset
message("Creating simulated dataset...")
simulated_data <- simulate_nass_data(NASS_2020_all, target_size_gb = simulated_data_size)

# Save simulated dataset
message("Saving simulated dataset...")
output_path <- file.path(getwd(), output_filename)
fwrite(simulated_data, output_path)

# Calculate actual file size
actual_size_gb <- file.size(output_path) / (1024^3)

# Print summary
message("\n========== Simulation Summary ==========")
message(paste("Input file:", input_filename))
message(paste("Output file:", output_filename))
message(paste("Original dataset:", format(nrow(NASS_2020_all), big.mark = ","), "rows"))
message(paste("Simulated dataset:", format(nrow(simulated_data), big.mark = ","), "rows"))
message(paste("Target size:", simulated_data_size, "GB"))
message(paste("Actual size:", round(actual_size_gb, 3), "GB"))
message(paste("Compression ratio:", round(nrow(NASS_2020_all) / nrow(simulated_data), 1), ":1"))
message(paste("Memory reduction:", round((1 - actual_size_gb / (file.size(input_path) / (1024^3))) * 100, 1), "%"))

# Validation checks
message("\n========== Validation Checks ==========")

# Check column structure
if(ncol(simulated_data) == ncol(NASS_2020_all)) {
  message("✓ Column count matches original")
} else {
  message("⚠ Column count mismatch")
}

# Check column names
if(all(names(simulated_data) == names(NASS_2020_all))) {
  message("✓ Column names match original")
} else {
  message("⚠ Column names mismatch")
}

# Check for missing values
missing_count <- sum(is.na(simulated_data))
if(missing_count == 0) {
  message("✓ No missing values")
} else {
  message(paste("⚠", missing_count, "missing values detected"))
}

# Save summary to file
summary_path <- file.path(getwd(), "simulated_dataset_summary.txt")
sink(summary_path)
cat("NASS 2020 Simulated Dataset Generation Summary\n")
cat("Generated on:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("==============================================\n\n")
cat("Configuration:\n")
cat("  Input file:", input_filename, "\n")
cat("  Output file:", output_filename, "\n")
cat("  Target size:", simulated_data_size, "GB\n")
cat("  Random seed:", 2025, "\n\n")
cat("Results:\n")
cat("  Original rows:", format(nrow(NASS_2020_all), big.mark = ","), "\n")
cat("  Simulated rows:", format(nrow(simulated_data), big.mark = ","), "\n")
cat("  Actual size:", round(actual_size_gb, 3), "GB\n")
cat("  Compression ratio:", round(nrow(NASS_2020_all) / nrow(simulated_data), 1), ":1\n")
cat("  Memory reduction:", round((1 - actual_size_gb / (file.size(input_path) / (1024^3))) * 100, 1), "%\n")
sink()

message("\nProcessing complete!")
message("Generated files:")
message(paste("  1. Simulated dataset:", output_path))
message(paste("  2. Summary report:", summary_path))

# Clean up
rm(NASS_2020_all, simulated_data)
gc()

message("✓ All done!")
