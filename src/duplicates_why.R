# Maxine Cruz
# tmcruz@arizona.edu
# Created: 21 March 2023
# Last modified: 21 March 2023



### ABOUT THE SCRIPT ---

# For finding origin of ~700 duplicates in Centris pallida data



### LOAD LIBRARIES ---

library(tidyverse)
library(readr)



### LOAD DATA WITH C. PALLIDA

data <- read_csv("data/gbif_rawdata_full.csv")



### FIGURE OUT WHAT'S UP WITH MANY DUPLICATES

# Filter for only C. pallida (speciesKey 1342915)
data <- filter(data, speciesKey == 1342915)

# 976 observations, 259 variables

# Function to remove columns with all NA
not_all_na <- function(x) any(!is.na(x))

# Remove columns with all NA
data <- data %>% select(where(not_all_na))

# 976 observations, 136 variables

# Remove where lat/long is NA
data <- data[!is.na(data$decimalLatitude), ]
data <- data[!is.na(data$decimalLongitude), ]

# 867 observations, 136 variables

# Find duplicates in data rows
which_are_dups <- matrix(duplicated(data))
unique(which_are_dups)

# All are FALSE, which means something happened in the mapping data

# Actually, what happened was that I removed many columns in the
# mapping data, and then ran unique(). So I will fix that in prelim.R.


