# Loading libraries
library(readr)
library(processx)
library(rstan)
library(rstanarm)

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

options(mc.cores = 4) 

# Training the stan4bart model
fit <- stan_glmer(log(abs_dev + 1) ~ 
                    rapid_ride + 
                    shape_dist_traveled + 
                    avg_traffic_dayhour + 
                    spatial_congestion + 
                    pop_density + 
                    route_ridership + 
                    perc_white + 
                    median_hhi + 
                    (1 + rapid_ride | g_weekday) + 
                    (1 + rapid_ride | g_hr),
                  data = df,
                  prior_aux = exponential(1, autoscale = TRUE),
                  cores = 4)

# Save the model to a local directory.
save(fit, file = file.path("local_model_dir", "stanglmer_rapidride_model.RData"))

# Copy the model to Google Cloud Storage using gsutil.
if(model_dir != "models"){
  local_file_path <- file.path("local_model_dir", "stanglmer_rapidride_model.RData")
  gs_destination <- file.path(model_dir, "stanglmer_rapidride_model.RData")
  
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
  cat("Model training completed and saved locally to", file.path("local_model_dir", "stanglmer_rapidride_model.RData"), "\n")
}