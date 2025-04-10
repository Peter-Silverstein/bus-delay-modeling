# Loading libraries
library(stan4bart)
library(dbarts)
library(here)
library(bartCause)

# Get environment variables set by Vertex AI
model_dir <- Sys.getenv("AIP_MODEL_DIR", "")

# Loading and preparing data
df <- read_csv("train_data.csv")

# Training the stan4bart model *****MAKE SURE TO FINALIZE THIS DESIGN*****
fit <- stan4bart(log(abs_dev + 1) ~ bart(.-g_weekday-g_hr-g_weekend-g_peak) + rapid_ride + (1 + rapid_ride | g_weekday/g_hr),
                   data = df,
                   treatment = rapid_ride,
                   cores = 4,
                   chains = 10,
                   iter = 2000,
                   seed = 50,
                   verbose = 2,
                   bart_args = list(n.trees = 150))

# Create a director if doesn't exist
if (!dir.exists(model_dir)) {
  dir.create(model_dir, recursive = TRUE)
}

# Save the model to specified directory
# Handling an issue with saving stan4bart models
fit@bart$fit@.xData$control <- fit@bart$fit@.xData$control[!names(fit@bart$fit@.xData$control) %in% c("callbacks")]

# Saving the model
save(fit, file = file.path(model_dir, "stan4bart_rapidride_model.RData"))

cat("Model training completed and saved to", file.path(model_dir, "stan4bart_rapidride_model.RData"), "\n")