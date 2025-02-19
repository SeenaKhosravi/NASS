

# Load the model from the file
model <- readRDS("model.rds")

# Print the summary of the loaded model
summary(model)

# Plot the fixed effects estimates with confidence intervals
plot_model(model, type = "est", ci.lvl = 0.95, sort.est = TRUE)

# Plot random effects with confidence intervals
plot_model(model, type = "re", ci.lvl = 0.95, sort.est = TRUE)

# Generate diagnostic plots for the linear mixed model
par(mfrow = c(2, 2))  # Set up a 2x2 plotting area

# Residuals vs Fitted
plot(model, which = 1, main = "Residuals vs Fitted")

# Normal Q-Q plot
qqnorm(resid(model), main = "Normal Q-Q")
qqline(resid(model))

# Scale-Location plot
plot(model, which = 3, main = "Scale-Location")

# Residuals vs Leverage
plot(model, which = 5, main = "Residuals vs Leverage")

par(mfrow = c(1, 1))  # Reset to default plotting area