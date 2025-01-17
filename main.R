# Load required packages
library(here)
library(tidyverse)
library(vroom)

# Source function files
source(here("functions", "feature_extraction.R"))
source(here("functions", "activity_classification.R"))

# Read accelerometer data
# Your data should have columns for:
# - timestamp: time of measurement
# - acc_x: acceleration in X axis (in g)
# - acc_y: acceleration in Y axis (in g)
# - acc_z: acceleration in Z axis (in g)
# If your accelerometer data is stored in a csv
# file you can use the code below to read it
data <- vroom(
  "path/to/your/data", # Replace with your path
  # Usually acceleromter data in csv files have some header
  # If this is the case, replace the line below
  # with the number of lines in the header
  # If there is no header the number should be 0
  skip = 10
)

# Classify activities
# Parameters:
# - time_col: name of the timestamp column in your data
# - x_col, y_col, z_col: names of the acceleration columns
# - sampling_freq: accelerometer sampling frequency in Hz
# - placement: where the accelerometer was placed, can be
#   "ankle", "lower_back", or "hip"
# - model_type: which model to use, can be "rf" (for Random Forest),
#   "svm" (for Support Vector Machine), or "knn" (for K-Nearest Neighbors)
results <- classify_activities(
  data = data,            # Replace with the name of the variable with your data
  time_col = "timestamp", # Replace with your column name
  x_col = "acc_x",        # Replace with your column name
  y_col = "acc_y",        # Replace with your column name
  z_col = "acc_z",        # Replace with your column name
  sampling_freq = 100,    # Replace with your sampling frequency in Hz
  placement = "ankle",    # Choose: "ankle", "lower_back", or "hip"
  model_type = "rf"       # Choose: "rf", "svm", or "knn"
)

# View results
# This will show a data frame with:
# - timestamp: time of measurement
# - activity: classified activity (walking, running, or jumping)
print(results)
