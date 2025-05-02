# Loading libraries
library(stan4bart)
library(dbarts)
library(here)
library(bartCause)
library(readr)
library(processx)

print(installed.packages())

# Get environment variables set by Vertex AI
model_dir <- "gs://bus-delay-modeling-stan4bart-models/models/"
print(paste("AIP_MODEL_DIR:", model_dir))

#remove trailing slashes.
model_dir <- gsub("/+$", "", model_dir)

if (model_dir == "") {
  model_dir <- "models"  # Fallback for local testing
  dir.create(model_dir, recursive = TRUE, showWarnings = FALSE)
} else {
  #create local model folder to save model to before copying to gs.
  dir.create("local_model_dir", recursive = TRUE, showWarnings = FALSE)
}

# Loading and preparing data
df <- read_csv("train_data.csv")
df_test <- read_csv("test_data.csv")

# Training the stan4bart model
fit <- stan4bart(abs_dev ~ bart(.-g_peak-rapid_ride) + rapid_ride + (1 + rapid_ride | g_peak),
                   data = df,
                   treatment = rapid_ride,
                   bart_args = list(keepTrees = TRUE),
                   seed = 50,
                   cores = 16,
                   verbose = 2)

# Save the model to a local directory.
save(fit, file = file.path("local_model_dir", "stan4bart_rapidride_model.RData"))

# Copy the model to Google Cloud Storage using gsutil.
if(model_dir != "models"){
  local_file_path <- file.path("local_model_dir", "stan4bart_rapidride_model.RData")
  gs_destination <- file.path(model_dir, "stan4bart_rapidride_model.RData")
  
  # Run gsutil cp command
  result <- processx::run("gsutil", c("cp", local_file_path, gs_destination))
  
  if (result$status == 0) {
    cat("Model training completed and saved to", gs_destination, "\n")
  } else {
    cat("Error copying model to Google Cloud Storage.\n")
    cat("gsutil output:\n", rawToChar(result$stdout), "\n")
    cat("gsutil error:\n", rawToChar(result$stderr), "\n")
  }
  
} else {
  cat("Model training completed and saved locally to", file.path("local_model_dir", "stan4bart_rapidride_model.RData"), "\n")
}

# Extract Fitted Values
factual_predictions <- extract(
  fit,
  type = "ppd",
  sample = "train"
)

counterfactual_predictions <- extract(
  fit,
  type = "ppd",
  sample = "test"
)

# Predict Test Set
outofsample_test <- predict(fit, 
                            newdata = df_test,
                            type = "ev")

stan4bart_sigma <- extract(fit, type = "sigma")

save(factual_predictions, counterfactual_predictions, outofsample_test, stan4bart_sigma, file = file.path("local_model_dir", "stan4bart_rapidride_outputs_ppd.RData"))

# Copy the model to Google Cloud Storage using gsutil.
if(model_dir != "models"){
  local_file_path <- file.path("local_model_dir", "stan4bart_rapidride_outputs_ppd.RData")
  gs_destination <- file.path(model_dir, "stan4bart_rapidride_outputs_ppd.RData")
  
  # Run gsutil cp command
  result <- processx::run("gsutil", c("cp", local_file_path, gs_destination))
  
  if (result$status == 0) {
    cat("Model extraction completed and saved to", gs_destination, "\n")
  } else {
    cat("Error copying output to Google Cloud Storage.\n")
    cat("gsutil output:\n", rawToChar(result$stdout), "\n")
    cat("gsutil error:\n", rawToChar(result$stderr), "\n")
  }
  
} else {
  cat("Model extraction completed and saved locally to", file.path("local_model_dir", "stan4bart_rapidride_outputs_ppd.RData"), "\n")
}
