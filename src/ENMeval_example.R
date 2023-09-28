# Using ENMeval to predict habitat suitability/distribution of a native bee 
# Maxine Cruz; Erin Zylstra
# 2023-09-11

require(stringr)
require(ENMeval)
require(raster)
require(dplyr)
require(dismo)
require(ggplot2)




# --- DATA PREP ---
# NOTE: everything in this section is Maxine's code, which looks great. I used 
# 3 hashmarks (###) to mark anywhere that I edited or added something. 

# Load bee data
cp_data <- read.csv("data/NAm_map_data.csv", header = TRUE)

# Isolate C. pallida records and reduce to only lat/long data
cp_data <- cp_data %>%
  filter(speciesKey == 1342915) %>%
  dplyr::select(longitude, latitude)

# Convert to spatial points (data now represents geographical location)
# CRS: Coordinate Reference System
cp_spatial <- SpatialPoints(cp_data,
                            proj4string = CRS("+proj=longlat"))

# Download climate data from WorldClim (if not done previously)
 current_env <- getData("worldclim", 
                        var = "bio", 
                        res = 2.5, 
                        path = "data/") 

# Create a list of the files in wc2-5 folder for raster stack
clim_list <- list.files(path = "data/wc2-5/", 
                        pattern = ".bil$",
                        full.names = TRUE)

# Create RasterStack (collection of objects with same spatial extent/resolution)
clim <- raster::stack(clim_list)

### Might want to think about whether you want to include all climate variables
# or just a subset of them.

# Determine extent of C. pallida presence data in order to crop the climate data
# and keep things manageable
geo_extent <- raster::extent(cp_spatial)

# Expand that extent by 25% 
geo_extent_plus <- geo_extent * 1.25

# Crop and convert to a RasterStack
clim_crop <- raster::crop(clim, geo_extent_plus)
clim_crop <- raster::stack(clim_crop)

# Thin occurrence records so there's only one per raster cell ###
occs <- dismo::gridSample(cp_data, clim_crop, n = 1)
# Just 183 locations left




# --- PSEUDO-ABSENCE POINTS ###

# We'll randomly select pseudo-absence points from the cropped raster (only one
# per cell without replacement). Using lots more pseudo-absence points than 
# presences to better sample the environment (suggested for Maxent models).
bg <- dismo::randomPoints(clim_crop[[1]], n = 10000)
colnames(bg) <- colnames(occs)




# --- RUN MAXENT MODEL, with ENMeval ###

# You'll probably want to "tune" some parameters that control the complexity of 
# the model (feature classes [fc] and regularization multipliers [rm]). To 
# start, I'd suggest trying 4 different fc (L, LQ, H, and LQH) and 3 different 
# rm (1, 2, or 3). The function will run a model for each of these fc/rm 
# combinations and evaluate model performance with a series of metrics. 
tune.args <- list(fc = c("L", "LQ", "H", "LQH"), rm = 1:3)

# The ENMevaluate function uses cross validation (CV) to evaluate models. CV 
# means the data are partitioned into folds (we'll used 4). For each fold, a 
# model is run with data from 3 folds and data in the remaining fold are used to
# evaluate the model. If you want to use a random method to partition the data, 
# you can do that by setting the following arguments in ENMevaluate: 
# method = "randomkfold", kfolds = 4. However, a random partition may not 
# provide a lot of information about how the model might perform when making 
# predictions to novel areas or future time periods. The other option is to 
# create some spatial folds. Steps for that are below:

# Create spatial blocks with ENM eval (creates 4 blocks via lat/long
# with relatively even number of occurrences in each partition)
set.seed(8)
block <- get.block(occs = occs, bg = bg)

# Check/view number of occurrences in each block
table(block$occs.grp)
evalplot.grps(pts = occs, pts.grp = block$occs.grp, envs = clim_crop)

# Check/view number of bg points in each block
table(block$bg.grp)
evalplot.grps(pts = bg, pts.grp = block$bg.grp, envs = clim_crop)

# Create a list to feed these partitions to the ENMevaluate() function
user.grp <- list(occs.grp = block$occs.grp, bg.grp = block$bg.grp)

# Specify a couple other settings for the Maxent model
os <- list(validation.bg = "partition", pred.type = "cloglog")

# For parallel processing, use 2 fewer cores than are available
num_cores <- parallel::detectCores() - 2

# Run it!
max_models <- ENMevaluate(occs = occs,
                          bg = bg,
                          envs = clim_crop,
                          algorithm = "maxnet",
                          tune.args = tune.args,
                          partitions = "user",
                          user.grp = user.grp,
                          other.settings = os,
                          parallel = TRUE,
                          numCores = num_cores)

# All results are stored in max_models. ENMeval doesn't automatically save 
# files to disk like dismo::maxent() does.




# --- EXPLORE RESULTS ###

# Use ?ENMevaluation to get a better understanding of the slots in max_models

# View a table with evaluation metrics for each set of tuning parameters
max_models@results

# Look most carefully at:
  # auc.val.avg = average AUC value across the 4 folds (higher is better)
  # cbi.val.avg = average Boyce index across the 4 folds (higher is better; negative value is very bad)
  # or.10p.avg = average 10-percentile omission rate across the 4 folds (lower is better)
  # ncoef = number of coefficients/parameters in the model

# If you wanted, you can also view a table with evaluation metrics for each set 
# of tuning parameters and each fold (though everything you need is probably in 
# the results table above)
max_models@results.partitions

# You can view predicted habitat suitability values for each of the models. eg:
plot(max_models@predictions[[1]]) # First model (fc = L; rm = 1)
plot(max_models@predictions[[4]]) # 4th model (fc = LQH; rm = 1)
plot(max_models@predictions[[9]]) # 4th model (fc = L; rm = 3)




# --- PICK A MODEL TO USE FOR INFERENCES ###

# Need to decide which set of tuning parameters is "best"
# Lots of ways to do this and it's probably worth exploring how predictions
# vary among models with different tuning parameters. 

# Here's one step-wise strategy you could use (based on Kass et al. 2022)
# 1) eliminate any models that have a negative Boyce index (cbi.val.avg < 0)
# 2) of the remaining models, pick the one with the lowest omission rate (min pr.10p.avg)
# 3) break any ties with AUC (maximum auc.val.avg)
optimal <- max_models@results %>%
  filter(cbi.val.avg > 0) %>%
  filter(or.10p.avg == min(or.10p.avg)) %>%
  filter(auc.val.avg == max(auc.val.avg))

optimal

# Extract the best model:
best <- max_models@models[[optimal$tune.args]]




# --- MAKE PREDICTIONS ###

# Generate a raster with predicted suitability values
# (Note: could generate predictions under a future climate scenario by replacing
# clim_crop with future climate layers [in a RasterStack])
preds <- enm.maxnet@predict(best, clim_crop, 
                            list(pred.type = "cloglog", doClamp = FALSE))

# Extract predicted suitability values for occurrence locations
preds_occ <- raster::extract(preds, occs)

# Extract predicted suitability values for bg locations
preds_bg <- raster::extract(preds, bg)

# Use a max(spec + sens) threshold to convert probabilities into binary values 
# (1 = part of species' predicted range; 0 = outside of range)
eval <- dismo::evaluate(preds_occ, preds_bg)
threshold <- dismo::threshold(eval, stat = "spec_sens")
range <- preds > threshold

# View predictions (can definitely make prettier figures than these!)
preds_spdf <- as(preds, "SpatialPixelsDataFrame")
preds_df <- as.data.frame(preds_spdf)
ggplot() +
  geom_raster(data = preds_df, aes(x = x, y = y, fill = layer))  + 
  scale_fill_gradientn(colours=viridis::viridis(99))

# Range prediction
raster_spdf <- as(range, "SpatialPixelsDataFrame")
range_df <- as.data.frame(raster_spdf)
range_df$layer <- as.factor(range_df$layer)
ggplot() +
  geom_raster(data = range_df, aes(x = x, y = y, fill = layer)) +
  geom_point(data = occs, aes(x = longitude, y = latitude), 
             col = "yellow", cex = 0.8)
