# Maxine Cruz
# tmcruz@arizona.edu
# Created: 27 September 2023
# Last modified: 23 October 2023




# ----- ABOUT THE SCRIPT -----

# Attempts implementing ENMeval / Maxent based on ENMeval_example.R from Erin.

# Also this vignette: 
  # https://jamiemkass.github.io/ENMeval/articles/ENMeval-2.0-vignette.html

# Hopefully the formatting here will help me format the loop for all species in 
  # another script. So then everything can be consolidated into one script.

# A lot of this will be repeat from ENMeval_example.R, but typing it myself
  # helps me to learn the mechanics and concepts. But this will also include
  # the future distribution predictions from predicted climate changes.

# Changes will need to be made once raster is retired.
  # Also transition to geodata: https://github.com/rspatial/geodata




# ----- LOAD LIBRARIES -----

library(gridExtra)
library(rJava)
library(cowplot)
library(ggplot2)
library(stringr)
library(ENMeval)
library(raster)
library(dplyr)
library(dismo)

# For later
library(geodata)




# ----- LOAD DATA -----

# Full data set
full_set <- read.csv("data/NAm_map_data_final.csv")

# Only C. pallida
cp_data <- full_set %>%
  filter(speciesKey == 1342915) %>%
  dplyr::select(longitude, latitude)

# Convert to spatial points (data now represents geographical location)
# CRS: Coordinate Reference System
cp_spatial <- SpatialPoints(cp_data,
                            proj4string = CRS("+proj=longlat"))

# Determine extent of C. pallida presence data in order to crop the climate data
# to appropriate values
geo_extent <- raster::extent(cp_spatial)

# Expand that extent by 50% to account for predicted distribution outside of
# the expected range
geo_extent_plus <- geo_extent * 1.5




# ----- CURRENT PREDICTED SDM -----

# DEAL WITH CLIMATE DATA --

# Download climate data from WorldClim (if not done previously)
current_env <- getData("worldclim", 
                       var = "bio", 
                       res = 2.5, 
                       path = "data/") 

# --

# *** TO DO: MOVE TO GEODATA PACKAGE - DOWNLOADING WORLDCLIM DATA ***

# worldclim_country(country = c("US", "MX"),
#                  var = "bio",
#                  res = 2.5,
#                  path = "data/worldclim_2-5")

# --

# Create a list of the files in wc2-5 folder for raster stack
clim_list <- list.files(path = "data/wc2-5/", 
                        pattern = ".bil$",
                        full.names = TRUE)

# Create RasterStack (collection of objects with same spatial extent/resolution)
bio_names <- raster::stack(clim_list)

# Only keep certain bioclimatic variables since some are just functions of others
# (a.k.a. they are redundant, and this can lead to over fitting)

# Removing bio3, bio7, bio10, bio11, and bio17 
# See https://www.worldclim.org/data/bioclim.html
clim <- dropLayer(bio_names, c("bio3", "bio7", "bio10", "bio11", "bio17"))

# The class of geo_extent and geo_extent_plus is Extent

# Crop climate variables to the 150% extent of C. pallida
clim_crop <- raster::crop(clim, geo_extent_plus)

# clim_crop results in a RasterBrick, so we convert it back into a RasterStack
clim_crop <- raster::stack(clim_crop)

# Thin occurrence records so there's only one per raster cell
occurrences <- dismo::gridSample(cp_spatial, clim_crop, n = 1)

# Just 178 observations left

# A raster is a matrix of cells / pixels organized in a grid and represents info.
  # The matrix would be the study area.
  # Now there is only one C. pallida occurrence in each of those cells.


# PSEUDO-ABSENCE POINTS --

# Randomly select pseudo-absence points from the cropped raster (one per cell 
# without replacement). 
  # We'll use 100x the number of observations since the pseudo-absenses act as
  # a background of environmental variables.

# Generating random points only requires the raster grid format, so we'll just
# use one layer of clim_crop to do this.
background <- dismo::randomPoints(clim_crop[[1]], n = 17800)

# Use column names from occs df in background df
colnames(background) <- colnames(occurrences)


# PARAMETER SETTINGS --

# Tuning some parameters can control the complexity of the model.

  # Feature classes (fc) - sets relationship of climate variables to the
    # probability of species occurrence. Example: The linear feature class says
    # as the climate values increase, so does the probability of that species
    # occurring. Similarly, the quadratic would suggest that the species is more
    # likely to exist at moderate climate values as opposed to the extremes.

  # Regularization multipliers (rm) - dictates how smooth the model is. Helps
    # avoid over fitting the model and helps to regularize / generalize the
    # predictions.

# Here we first try modeling with fc = L, LQ, H, and LQH, and rm = 1, 2, and 3
tune.args <- list(fc = c("L", "LQ", "H", "LQH"), rm = 1:3)

# ENMevaluate is a cross-validation (CV) function.

  # ENM = Ecological Niche Model

  # Occurrence data is partitioned into validation and training bins (folds).

  # This is a k-fold CV method. Where the data is split into k groups ("folds")
    # of roughly equal size. One of the folds is used to create a model, and
    # this model is tested on the remaining k-1 folds. This is repeated k times
    # with each fold having a turn as model. More folds reduce bias but
    # increase variance, whereas the reverse increases bias but reduces variance.
  
# Here we will use the block method.
  # Splits data into four groups, each having roughly the same number of
  # occurrences. There are two bisections - one latitude and one longitude.

# Set seed for reproducibility purposes
set.seed(8)

# Create blocks with the occurrence and background (pseudo-absence) data
block <- get.block(occs = occurrences,
                   bg = background)

# Table to check number of occurrences in each block
table(block$occs.grp)

# Plot to check number of occurrences in each block
# evalplot.grps(pts = occurrences,
#               pts.grp = block$occs.grp,
#               envs = clim_crop)

# Table to check number of background points in each block
table(block$bg.grp)

# Plot to check number of background points in each block
# evalplot.grps(pts = background,
#               pts.grp = block$bg.grp,
#               envs = clim_crop)

# Create a list to feed these partitions to the ENMevaluate() function
user.grp <- list(occs.grp = block$occs.grp, 
                 bg.grp = block$bg.grp)

# Specify a couple other settings for the Maxent model
  # Default validation.g is "full" - CV is with respsect to full background.
  # The "partition" with respect to the partitioned background only 
    # (i.e. training occurrences are compared to training background, and 
    # validation occurrences compared to validation background). 

# We will use the partition method because it creates a more independent model
# to be tested against the others. There are other options for modifications:
# https://rdocumentation.org/packages/ENMeval/versions/2.0.4/topics/ENMevaluate
other.settings <- list(validation.bg = "partition")

# For parallel processing, use 2 fewer cores than are available
# (Creates less load on the CPU?)
num_cores <- parallel::detectCores() - 2


# MAXENT WITH ENMEVAL --

maxent_results <- ENMevaluate(occs = occurrences,
                              bg = background,
                              envs = clim_crop,
                              algorithm = "maxnet", # Maxent model
                              tune.args = tune.args,
                              partitions = "user", # User-defined partitions
                              user.grp = user.grp,
                              other.settings = other.settings,
                              parallel = TRUE, # Allow parallel processing
                              numCores = num_cores)


# PICK "BEST" MODEL FOR INFERENCES --

# Look at table with evaluation metrics for each set of tuning parameters
eval_table <- maxent_results@results

# Save this table
write.csv(eval_table, "output/enmeval_test_run_results_table.csv")

# NOTE TO SELF:
  # AUC = Area Under (ROC) Curve
    # A measure of the overall performance of the binary classification model.
  # CBI =
    #
  # AIC = Akaike Information Criterion
    # A metric that is used to compare the fit of different regression models.
  # OR = 
    #

# Here's one step-wise strategy you could use (based on Kass et al. 2022)
  # 1) Eliminate any models that have a negative Boyce index (cbi.val.avg < 0)
  # 2) Of the remaining models, pick the one with the lowest omission rate 
    # (min pr.10p.avg)
  # 3) Break any ties with AUC (maximum auc.val.avg)
optimal <- maxent_results@results %>%
  filter(cbi.val.avg > 0) %>%
  filter(or.10p.avg == min(or.10p.avg)) %>%
  filter(auc.val.avg == max(auc.val.avg))

# Extract the optimal model
best <- maxent_results@models[[optimal$tune.args]]


# USING OPTIMAL MODEL FOR PREDICTIONS --

# [Predicted distribution]

# Generate raster with predicted suitability values
predicted_vals <- enm.maxnet@predict(best, clim_crop,
                                     list(pred.type = "cloglog", 
                                          doClamp = FALSE))

# [Following lines are for finding predicted range]

# Extract predicted suitability values for occurrence locations
predicted_occ <- raster::extract(predicted_vals, occurrences)

# Extract predicted suitability values for background locations
predicted_bg <- raster::extract(predicted_vals, background)

# Sensitivity - measures proportion of correctly identified true positives
# Specificity - "" negatives
# S and S are statistical measures of the performance of a binary 
  # classification test. How accurate is this test for presence / absence?

# Maximization of the Sum of Sensitivity and Specificity (MaxSSS) threshold
  # Equivalent to minimization of false negative and false positive
    # misclassification likelihoods.
  # Maximizing overall correct diagnosis rate / minimizing "" misdiagnosis rate.

# Evaluate models - gives ModelEvaluation object
eval <- dismo::evaluate(predicted_occ, predicted_bg)

# Use a max(spec + sens) threshold to convert probabilities into binary values 
# (1 = part of species' predicted range; 0 = outside of range) - gives a Value
threshold <- dismo::threshold(eval, stat = "spec_sens")

# For predicting range, find predicted values greater than the threshold
range <- predicted_vals > threshold


# PREP DATA FOR PLOTTING LATER --

# Environmental suitability plots
pred_spdf <- as(predicted_vals, "SpatialPixelsDataFrame")

current_pred_df <- as.data.frame(pred_spdf)

# Range plots
raster_spdf <- as(range, "SpatialPixelsDataFrame")

current_range_df <- as.data.frame(raster_spdf)

current_range_df$layer <- as.factor(current_range_df$layer)




# ----- FUTURE PREDICTED SDM -----

# Mostly same as all the code above
  # Only difference is that we're using CMIP5 climate prediction data here


# DEAL WITH CLIMATE DATA --

# ---

# *** TO DO: MOVE TO GEODATA PACKAGE - DOWNLOADING CMIP DATA ***

# Newest climate data looks like it is CMIP6

# https://www.carbonbrief.org/cmip6-the-next-generation-of-climate-models-explained/

# Representative concentration Pathways (RCPs): Pathways for greenhouse gas / 
  # radiative forcings that might occur in the future.

# Shared Socioeconomic Pathways (SSPs): Pathways for how the world might
  # evolve in the absence of climate policy / varying levels of climate change 
  # mitigation.
  # SSP1-2.6: scenarios aiming to limit the increase of global mean 
    # temperature to 2°C
  # SSP2-4.5: scenario that stabilizes radiative forcing at 4.5 W m−2 in the 
    # year 2100 without ever exceeding that value
  # SSP3-7.0: middle of the road (new scenario)
  # SSP5-8.5: pathway with the highest greenhouse gas emissions (worst case)

# cmip6_world(model = ,
#            ssp = "370",
#            time = "2021-2040",
#            var = "bioc",
#            res = 2.5,
#            path = "data")

# *** NEED TO FIGURE OUT WHAT CLIMATE MODEL TO USE !!! ***
  # Not sure how that works - maybe ask Jeff / Erin
  # Descriptions: https://wcrp-cmip.org/cmip-model-and-experiment-documentation/

# ---

# Download climate data from CMIP5
future_env <- raster::getData(name = "CMIP5", 
                              var = "bio", 
                              res = 2.5,
                              rcp = 45, 
                              model = "IP", 
                              year = 50, 
                              path = "data") 

# Rename future_env bioclimatic variables to match "bio_" format
names(future_env) = names(bio_names)

# Removing bio3, bio7, bio10, bio11, and bio17
future_env <- dropLayer(future_env, c("bio3", "bio7", "bio10", "bio11", "bio17"))

# Crop climate variables to the 150% extent of C. pallida
future_clim_crop <- raster::crop(future_env, geo_extent_plus)

# clim_crop results in a RasterBrick, so we convert it back into a RasterStack
future_clim_crop <- raster::stack(future_clim_crop)

# Thin occurrence records so there's only one per raster cell
occurrences <- dismo::gridSample(cp_spatial, future_clim_crop, n = 1)


# PSEUDO-ABSENCE POINTS --

# Generating random points only requires the raster grid format, so we'll just
# use one layer of clim_crop to do this.
background <- dismo::randomPoints(future_clim_crop[[1]], n = 17800)

# Use column names from occs df in background df
colnames(background) <- colnames(occurrences)


# PARAMETER SETTINGS --

# The following have been set earlier during the current predictions:
  # tune.args
  # other.settings
  # numCores

# Set seed for reproducibility purposes
set.seed(8)

# Create blocks with the occurrence and background (pseudo-absence) data
block <- get.block(occs = occurrences,
                   bg = background)

# Table to check number of occurrences in each block
table(block$occs.grp)

# Plot to check number of occurrences in each block
# evalplot.grps(pts = occurrences,
#               pts.grp = block$occs.grp,
#               envs = clim_crop)

# Table to check number of background points in each block
table(block$bg.grp)


# MAXENT WITH ENMEVAL --

future_maxent_results <- ENMevaluate(occs = occurrences,
                                     bg = background,
                                     envs = future_clim_crop,
                                     algorithm = "maxnet", # Maxent model
                                     tune.args = tune.args,
                                     partitions = "user", # User-defined partitions
                                     user.grp = user.grp,
                                     other.settings = other.settings,
                                     parallel = TRUE, # Allow parallel processing
                                     numCores = num_cores)


# PICK "BEST" MODEL FOR INFERENCES --

# Look at table with evaluation metrics for each set of tuning parameters
eval_table <- future_maxent_results@results

# Save this table
write.csv(eval_table, "output/enmeval_test_run_results_future_table.csv")

# Filter for optimal model
optimal <- future_maxent_results@results %>%
  filter(cbi.val.avg > 0) %>%
  filter(or.10p.avg == min(or.10p.avg)) %>%
  filter(auc.val.avg == max(auc.val.avg))

# Extract the optimal model
best <- future_maxent_results@models[[optimal$tune.args]]


# USING OPTIMAL MODEL FOR PREDICTIONS --

# [Predicted distribution]

# Generate raster with predicted suitability values
future_predicted_vals <- enm.maxnet@predict(best, future_clim_crop,
                                            list(pred.type = "cloglog", 
                                                 doClamp = FALSE))

# [Following lines are for finding predicted range]

# Extract predicted suitability values for occurrence locations
future_predicted_occ <- raster::extract(future_predicted_vals, occurrences)

# Extract predicted suitability values for background locations
future_predicted_bg <- raster::extract(future_predicted_vals, background)

# Evaluate models - gives ModelEvaluation object
eval <- dismo::evaluate(future_predicted_occ, future_predicted_bg)

# Use a max(spec + sens) threshold to convert probabilities into binary values 
# (1 = part of species' predicted range; 0 = outside of range) - gives a Value
future_threshold <- dismo::threshold(eval, stat = "spec_sens")

# For predicting range, find predicted values greater than the threshold
future_range <- future_predicted_vals > future_threshold


# PREP DATA FOR PLOTTING LATER --

# Environmental suitability plots
pred_spdf <- as(future_predicted_vals, "SpatialPixelsDataFrame")

future_pred_df <- as.data.frame(pred_spdf)

# Range plots
raster_spdf <- as(future_range, "SpatialPixelsDataFrame")

future_range_df <- as.data.frame(raster_spdf)

future_range_df$layer <- as.factor(future_range_df$layer)




# ----- PLOT DISTRIBUTION MAPS -----

# Collect data for map borderlines
wrld <- ggplot2::map_data("world")


# CURRENT --

# Set boundaries where map should be focused
xmax <- max(current_pred_df$x)
xmin <- min(current_pred_df$x)
ymax <- max(current_pred_df$y)
ymin <- min(current_pred_df$y)

# Environmental suitability prediction map
current_dis <- ggplot() +
  geom_raster(data = current_pred_df, 
              aes(x = x, y = y, fill = layer))  + 
  scale_fill_gradientn(colours=viridis::viridis(99)) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("state") +
  labs(title = bquote(bold("under Current Climate Conditions")),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(legend.box.background = element_rect(color = NA),
        legend.position = "bottom")

# Save
rstudioapi::savePlotAsImage(file = "output/enmeval_test_current_distribution.png",
                            format = "png",
                            width = 750,
                            height = 584)

# Range prediction map
current_range <- ggplot() +
  geom_raster(data = current_range_df, 
              aes(x = x, y = y, fill = layer)) +
  scale_fill_manual(values = c("orangered3", "mediumturquoise")) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("state") +
  labs(title = bquote(bold("under Current Climate Conditions")),
       x = "Longitude",
       y = "Latitude") + 
  theme(legend.position = "none")

# Save
rstudioapi::savePlotAsImage(file = "output/enmeval_test_current_range.png",
                            format = "png",
                            width = 750,
                            height = 584)


# FUTURE --

# Set boundaries where map should be focused
xmax2 <- max(future_pred_df$x)
xmin2 <- min(future_pred_df$x)
ymax2 <- max(future_pred_df$y)
ymin2 <- min(future_pred_df$y)

# Environmental suitability prediction map
future_50_dis <- ggplot() +
  geom_raster(data = future_pred_df, 
              aes(x = x, y = y, fill = layer))  + 
  scale_fill_gradientn(colours=viridis::viridis(99)) +
  coord_fixed(xlim = c(xmin2, xmax2), 
              ylim = c(ymin2, ymax2), 
              expand = F) +
  scale_size_area() +
  borders("state") +
  labs(title = bquote(bold("50 Years into the Future")),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(legend.box.background = element_rect(color = NA),
        legend.position = "bottom")

# Save
rstudioapi::savePlotAsImage(file = "output/enmeval_test_future_distribution.png",
                            format = "png",
                            width = 750,
                            height = 584)

# Range prediction map
future_50_range <- ggplot() +
  geom_raster(data = future_range_df, 
              aes(x = x, y = y, fill = layer)) +
  scale_fill_manual(values = c("orangered3", "mediumturquoise")) +
  coord_fixed(xlim = c(xmin2, xmax2), 
              ylim = c(ymin2, ymax2), 
              expand = F) +
  scale_size_area() +
  borders("state") +
  labs(title = bquote(bold("50 Years into the Future")),
       x = "Longitude",
       y = "Latitude") + 
  theme(legend.position = "none")

# Save
rstudioapi::savePlotAsImage(file = "output/enmeval_test_future_range.png",
                            format = "png",
                            width = 750,
                            height = 584)



# PLOT MAPS TOGETHER --

# ENVIRONMENTAL SUITABILITY ---

# Combine plots for current and 50 years
plot_row <- plot_grid(current_dis, future_50_dis)

# Generate common plot title
title <- ggdraw() + 
  draw_label(bquote("Predicted Distribution of" ~italic("Centris pallida")),
             fontface = "bold",
             hjust = 0.5,
             size = 20)

# Add title to combined plots
combined_plots <- plot_grid(title,
                            plot_row,
                            ncol = 1,
                            rel_heights = c(0.1, 1))

# Save combined plots
ggsave(filename = "enmeval_test_current_future_SDM_cpallida.jpg",
       plot = combined_plots,
       path = "output",
       width = 3000,
       height = 2338,
       units = "px")


# RANGE ---

# Combine plots for current and 50 years
plot_row <- plot_grid(current_range, future_50_range)

# Generate common plot title
title <- ggdraw() + 
  draw_label(bquote("Predicted Range of" ~italic("Centris pallida")),
             fontface = "bold",
             hjust = 0.5,
             size = 20)

# Add title to combined plots
combined_plots <- plot_grid(title,
                            plot_row,
                            ncol = 1,
                            rel_heights = c(0.1, 1))

# Save combined plots
ggsave(filename = "enmeval_test_current_future_range_cpallida.jpg",
       plot = combined_plots,
       path = "output",
       width = 3000,
       height = 2122,
       units = "px")

