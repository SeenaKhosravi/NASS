### TKA.r

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

### HCUP NASS 2020 Data Analysis - TKA Subset
### Author: SgtKlinger
### Date: 2025-02-10

### Description: This script creates a subset of the HCUP NASS 2020 data
### for Total Knee Arthroplasty (TKA) analysis and prepares for binomial prediction models.

### STATUS: IN PROGRESS, NOT TESTED
### NOTE: This script is designed to be run in RStudio
### and assumes the working directory is set to the location of the data files,
### and the NASS_2020_all.csv file is present in the working directory
### after running load_and_clean_data.R.

# Load required packages
required_packages <- c("data.table", "dplyr", "lme4", "randomForest", "caret", "ROSE", "e1071", "parallel", "pROC")

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
NASS_2020_all <- fread(file.path(getwd(), "NASS_2020_all.csv"), select = c(1:27, 57:132))

# Filter for Total Knee Arthroplasty (TKA) cases
TKA_subset <- NASS_2020_all[PAY1 = is not NA & CPTCCS1 == "152"]

#calculate the percentage of TKA cases included in subset
TKA_retained <- nrow(TKA_subset) / nrow(NASS_2020_all[CPTCCS1 == "152"])

# Write TKA_subset to a CSV file in the working directory
fwrite(TKA_subset, file.path(getwd(), "TKA_subset.csv"))
gc()

# Example code for logistic regression model
logistic_model <- glm(outcome ~ ., data = TKA_subset, family = binomial)

# Example code for GLMM
glmm_model <- glmer(outcome ~ (1|random_effect) + fixed_effect, data = TKA_subset, family = binomial)

# Example code for balanced random forest
balanced_rf_model <- randomForest(outcome ~ ., data = TKA_subset, sampsize = c(100, 100), strata = TKA_subset$outcome, ntree = 500, do.trace = TRUE, nthread = detectCores())

# Example code for SVM
svm_model <- svm(outcome ~ ., data = TKA_subset, probability = TRUE)

# Example code for model evaluation
confusionMatrix(predict(logistic_model, TKA_subset, type = "response"), TKA_subset$outcome)
confusionMatrix(predict(glmm_model, TKA_subset, type = "response"), TKA_subset$outcome)
confusionMatrix(predict(balanced_rf_model, TKA_subset), TKA_subset$outcome)
confusionMatrix(predict(svm_model, TKA_subset), TKA_subset$outcome)

# Generate ROC curves
logistic_probs <- predict(logistic_model, TKA_subset, type = "response")
glmm_probs <- predict(glmm_model, TKA_subset, type = "response")
rf_probs <- predict(balanced_rf_model, TKA_subset, type = "prob")[,2]
svm_probs <- attr(predict(svm_model, TKA_subset, probability = TRUE), "probabilities")[,2]

roc_logistic <- roc(TKA_subset$outcome, logistic_probs)
roc_glmm <- roc(TKA_subset$outcome, glmm_probs)
roc_rf <- roc(TKA_subset$outcome, rf_probs)
roc_svm <- roc(TKA_subset$outcome, svm_probs)

# Plot ROC curves
plot(roc_logistic, col = "blue", main = "ROC Curves for Different Models")
lines(roc_glmm, col = "red")
lines(roc_rf, col = "green")
lines(roc_svm, col = "purple")
legend("bottomright", legend = c("Logistic Regression", "GLMM", "Random Forest", "SVM"), col = c("blue", "red", "green", "purple"), lwd = 2)

# Clean up memory
rm(NASS_2020_all, TKA_subset, logistic_model, glmm_model, balanced_rf_model, svm_model, logistic_probs, glmm_probs, rf_probs, svm_probs, roc_logistic, roc_glmm, roc_rf, roc_svm)
gc()
