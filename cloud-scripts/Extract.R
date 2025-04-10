# Loading Libraries
library(googleCloudStorageR)

bucket_name <- "bus-delay-modeling-stan4bart-models"
gcs_file_path <- "models/stan4bart_rapidride_model.RData"
local_file_path <- "cloud-scripts/stan4bart_rapidride_model.RData"

# Create local directory if it doesn't exist
local_dir <- dirname(local_file_path)
if (!dir.exists(local_dir)) {
  dir.create(local_dir, recursive = TRUE)
}

# Download the model file from GCS
gcs_get_object(
  object_name = gcs_file_path,
  bucket = bucket_name,
  saveToDisk = local_file_path,
  overwrite = TRUE
)

cat("Model downloaded from GCS to", local_file_path, "\n")

# Optional: Load the model to verify it works
cat("Loading model to verify integrity...\n")
load(local_file_path)
cat("Model loaded successfully.\n")