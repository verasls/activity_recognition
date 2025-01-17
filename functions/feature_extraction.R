library(signal)
library(e1071)
library(tidyverse)

#' Calculate Time-Domain Features from Acceleration Signal
#'
#' @param x Numeric vector containing acceleration data
#' @return A tibble with the following time-domain features:
#'   \item{mean}{Mean acceleration}
#'   \item{sd}{Standard deviation}
#'   \item{cv}{Coefficient of variation}
#'   \item{skewness}{Skewness of the distribution}
#'   \item{kurtosis}{Kurtosis of the distribution}
#'   \item{min}{Minimum value}
#'   \item{q25}{25th percentile}
#'   \item{median}{Median value}
#'   \item{q75}{75th percentile}
#'   \item{max}{Maximum value}
#'   \item{mean_amplitude}{Mean of absolute acceleration}
#'   \item{sd_amplitude}{Standard deviation of absolute acceleration}
compute_time_domain_features <- function(x) {
  tibble::tibble(
    mean = mean(x),
    sd = sd(x),
    cv = sd(x) / mean(x),
    skewness = e1071::skewness(x),
    kurtosis = e1071::kurtosis(x),
    min = min(x),
    q25 = quantile(x, 0.25),
    median = median(x),
    q75 = quantile(x, 0.75),
    max = max(x),
    mean_amplitude = mean(abs(x)),
    sd_amplitude = sd(abs(x))
  )
}

#' Calculate Frequency-Domain Features from Acceleration Signal
#'
#' @param x Numeric vector containing acceleration data
#' @param sampling_freq Sampling frequency in Hz
#' @return A tibble with the following frequency-domain features:
#'   \item{dominant_frequency}{Frequency with highest magnitude}
#'   \item{dominant_magnitude}{Magnitude at dominant frequency}
#'   \item{total_power}{Total power of the signal}
#'   \item{median_frequency}{Frequency at which cumulative power reaches 50%}
compute_frequency_domain_features <- function(x, sampling_freq) {
  n <- length(x)
  freq <- seq(0, sampling_freq / 2, length.out = floor(n / 2) + 1)
  x_fft <- fft(x)[1:(floor(n / 2) + 1)]
  magnitude <- Mod(x_fft)

  total_power <- sum(magnitude^2) / n
  dominant_idx <- which.max(magnitude)

  cumulative_power <- cumsum(magnitude^2) / sum(magnitude^2)
  median_freq_idx <- which.min(abs(cumulative_power - 0.5))

  tibble::tibble(
    dominant_frequency = freq[dominant_idx],
    dominant_magnitude = magnitude[dominant_idx],
    total_power = total_power,
    median_frequency = freq[median_freq_idx]
  )
}

#' Calculate Orientation Features from Filtered Acceleration Signals
#'
#' @param x Numeric vector containing X-axis acceleration
#' @param y Numeric vector containing Y-axis acceleration
#' @param z Numeric vector containing Z-axis acceleration
#' @return A tibble with the following orientation features:
#'   \item{roll}{Mean roll angle}
#'   \item{pitch}{Mean pitch angle}
#'   \item{yaw}{Mean yaw angle}
compute_orientation <- function(x, y, z) {
  roll <- atan2(y, sqrt(x^2 + z^2))
  pitch <- atan2(-x, sqrt(y^2 + z^2))
  yaw <- atan2(z, sqrt(x^2 + y^2))

  tibble::tibble(
    roll = mean(roll),
    pitch = mean(pitch),
    yaw = mean(yaw)
  )
}

#' Extract All Features from Triaxial Acceleration Data
#'
#' @param data A tibble containing columns 'x', 'y', and 'z'
#' 'with acceleration data
#' @param sampling_freq Sampling frequency in Hz
#' @return A tibble containing all computed features:
#'   \item{corr_xy, corr_xz, corr_yz}{Correlations between axes}
#'   \item{roll, pitch, yaw}{Orientation features}
#'   \item{*_x, *_y, *_z}{Time and frequency domain features for each axis}
extract_features <- function(data, sampling_freq) {
  bf <- signal::butter(2, 1 / (sampling_freq / 2), type = "low")
  x_filtered <- signal::filtfilt(bf, data$x)
  y_filtered <- signal::filtfilt(bf, data$y)
  z_filtered <- signal::filtfilt(bf, data$z)

  features_x <- compute_time_domain_features(data$x) |>
    dplyr::bind_cols(
      compute_frequency_domain_features(data$x, sampling_freq)
    ) |>
    dplyr::rename_with(~ paste0(., "_x"))

  features_y <- compute_time_domain_features(data$y) |>
    dplyr::bind_cols(
      compute_frequency_domain_features(data$y, sampling_freq)
    ) |>
    dplyr::rename_with(~ paste0(., "_y"))

  features_z <- compute_time_domain_features(data$z) |>
    dplyr::bind_cols(
      compute_frequency_domain_features(data$z, sampling_freq)
    ) |>
    dplyr::rename_with(~ paste0(., "_z"))

  correlations <- tibble::tibble(
    corr_xy = cor(data$x, data$y),
    corr_xz = cor(data$x, data$z),
    corr_yz = cor(data$y, data$z)
  )

  orientation <- compute_orientation(x_filtered, y_filtered, z_filtered)

  dplyr::bind_cols(
    correlations, orientation, features_x, features_y, features_z
  )
}
