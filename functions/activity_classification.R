library(here)
library(tidyverse)
library(tidymodels)
library(kernlab)

#' Classify Physical Activities from Accelerometer Data
#'
#' This function processes raw accelerometer data to classify physical
#' activities into walking, running, or jumping categories using
#' machine learning models.
#'
#' @param data A data frame containing accelerometer data
#' @param time_col Name of the column containing timestamps
#' @param x_col Name of the column containing X-axis acceleration
#' @param y_col Name of the column containing Y-axis acceleration
#' @param z_col Name of the column containing Z-axis acceleration
#' @param sampling_freq Sampling frequency in Hz
#' @param placement Accelerometer placement ("ankle", "lower_back", or "hip")
#' @param model_type Model to use ("rf", "svm", or "knn")
#' @param window_size Window size in seconds (default: 1)
#' @param chunk_size Number of windows to process at once (default: 1000)
#'
#' @return A data frame with two columns:
#'   \item{timestamp}{Time of measurement}
#'   \item{activity}{Classified activity (walking, running, or jumping)}
classify_activities <- function(data,
                                time_col,
                                x_col,
                                y_col,
                                z_col,
                                sampling_freq,
                                placement,
                                model_type,
                                window_size = 1,
                                chunk_size = 1000) {

  valid_placements <- c("ankle", "lower_back", "hip")
  valid_models <- c("rf", "svm", "knn")

  if (!placement %in% valid_placements) {
    stop("Invalid placement. Must be one of: ",
         paste(valid_placements, collapse = ", "))
  }

  if (!model_type %in% valid_models) {
    stop("Invalid model type. Must be one of: ",
         paste(valid_models, collapse = ", "))
  }

  message("Processing data...")

  window_length <- window_size * sampling_freq

  message("Creating windows...")

  data_windows <- data |>
    dplyr::mutate(
      window_id = ((dplyr::row_number() - 1) %/% window_length) + 1
    ) |>
    dplyr::group_by(window_id) |>
    tidyr::nest()

  message("Loading model...")
  model_path <- here("models", placement, paste0(model_type, "_model.rds"))
  model <- readRDS(model_path)

  n_chunks <- ceiling(nrow(data_windows) / chunk_size)
  message(glue::glue("Processing {n_chunks} chunks..."))

  results_list <- vector("list", n_chunks)

  for (i in seq_len(n_chunks)) {
    message(glue::glue("Processing chunk {i} of {n_chunks}"))

    start_idx <- (i - 1) * chunk_size + 1
    end_idx <- min(i * chunk_size, nrow(data_windows))

    chunk_data <- data_windows |>
      dplyr::slice(start_idx:end_idx)

    features <- chunk_data |>
      dplyr::mutate(
        features = purrr::map(data, function(window) {
          window_data <- tibble::tibble(
            x = window[[x_col]],
            y = window[[y_col]],
            z = window[[z_col]]
          )
          extract_features(window_data, sampling_freq)
        })
      ) |>
      tidyr::unnest(features)

    predictions <- predict(model, features)

    results_list[[i]] <- tibble::tibble(
      timestamp = purrr::map_dbl(chunk_data$data, ~ first(.[[time_col]])),
      activity = predictions
    ) |>
      dplyr::mutate(timestamp = as.POSIXct(timestamp, origin = "1970-01-01"))
  }

  message("Combining results...")
  results <- dplyr::bind_rows(results_list)

  message("Done!")
  return(results)
}
