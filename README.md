# Activity Recognition from Accelerometer Data

This repository contains R code to apply the activity classification models presented in the paper "Accelerometer-Based Classification of Walking, Running, and Jumping: A Machine Learning Approach for Mechanical Loading Assessment".

## Prerequisites

Before using this code, you need to:

1. Install R (version 4.1.0 or higher) from [https://cran.r-project.org/](https://cran.r-project.org/)
2. Install RStudio from [https://posit.co/download/rstudio-desktop/](https://posit.co/download/rstudio-desktop/)

## Setup

1. Download this project (click the green "Code" button and select "Download ZIP")
2. Unzip the downloaded file
3. Open the `activity_recognition.Rproj` file. This should open the project in RStudio
6. In the RStudio Console, run:
```r
install.packages("renv")
renv::restore()
```
This will install all required packages.

## Using the code

### Run the analysis

1. Open `main.R` in RStudio
2. Update these lines with your data details:
3. Click the "Source" button (or press Ctrl+Shift+S) to run the analysis

### Common issues

1. **"File not found" error**: Make sure the path to your CSV file is correct
2. **Column name errors**: Check that your column names match exactly what you specified
3. **Package loading errors**: Run `renv::restore()` again to ensure all packages are installed

## Need Help?

If you find any bugs or have questions, requests, or comments, please report them in this repository's [issues page](https://github.com/verasls/activity_recognition/issues)
