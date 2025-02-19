

# Fit the linear mixed models
model <- 
  lmer(TOTCHG ~ CPTCCS1 + (1 | HOSP_NASS), 
    data = subset_65_50_NASS_2020, weights = DISCWT)

# Print the summary of the model
summary(model)

# Fit the linear mixed model
model <- lmer(TOTCHG ~ CPTCCS1 + (1 | HOSP_NASS), 
              data = subset_65_50_NASS_2020, weights = DISCWT)

# Save the model to a file
saveRDS(model, file = "model.rds")