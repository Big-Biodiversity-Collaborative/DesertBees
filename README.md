# Investigating the Distributions of *Centris pallida* and Nectar Plants in Response to Climate Change

![](images/github_banner.png)

**Manuscript:** https://www.mdpi.com/2075-4450/15/10/793

**Github archive:** [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.13777361.svg)](https://doi.org/10.5281/zenodo.13777361)


## 🐝 Summary

This repository stores materials for generating figures and running models for the predicted current (2000-2021) and forecasted (2021-2040) distributions of the desert pallid bee (*Centris pallida*) and some of its major nectar plants -- the desert ironwood (*Olneya tesota*), blue palo verde (*Parkinsonia florida*), and yellow palo verde (*Parkinsonia microphylla*).

The distributions are modeled using the maximum entropy model (MaxEnt), and the most fitting model is determined through cross-validation with the `ENMeval` package. Predictions are made with `terra::predict()` over the time periods 2000-2021 and 2021-2040. Historical climate data is attained from WorldClim version 2.1, and forecasted climate data from AdaptWest.

These figures will help assess possible changes in distribution overlap as a warming climate ensues, which can aid in conservation planning and provide insight into the responses of desert organisms.

## 📚 Libraries

The R packages used may be found in `packages.csv`. Each script may use some or all that are listed.

## 📂 Folder Contents

1.  ***data:*** Contains data from the following sites --

    -   [Global Biodiversity Information Facility](https://www.gbif.org/) (GBIF) (species occurrence data)

    -   [WorldClim (version 2.1)](http://www.worldclim.com/version2) (historical climate data)

    -   [AdaptWest](https://adaptwest.databasin.org/) / [Coupled Model Intercomparison Project, Phase 6](https://wcrp-cmip.org/cmip-phase-6-cmip6/) (CMIP6) (forecasted climate data)

    -   [North American Atlas](http://www.cec.org/north-american-environmental-atlas/elevation-2023/) (elevation data)

2.  ***scripts:*** Contains code for cleaning the data, running models, and generating figures.

3.  ***output:*** Contains figures, shapefiles, and model outputs.

## 📑 Order of Script Use

1.  ***get_gbif.R***
    -   Acquires data from GBIF through the `rgbif` package. The data is filtered to remove duplicate entries (e.g. the same record was published in different sources), erroneous observations, and limit the observations to those in North and Central America (most of them are, anyway).
    -   We further limit the observations to those within the known range, as some may be the result of incorrect identification or geographic coordinate error.
2.  ***combine_elevation_and_gbif.R***
    -   The data from GBIF has a column for elevation at which the observation was taken at, but is mostly void of data. This script will use data from the DEM to amend the elevations to the GBIF observations. This helps us account for elevation in the model.
3.  ***species_occurrence_maps.R***
    -   Plots point observations on a map of North and Central America. Maps are separated by species. This also generates a map that contains all four maps in one file.
4.  ***prep_forecast_data.R***
    -   This was created by Jeff Oliver (here: <https://github.com/Big-Biodiversity-Collaborative/SwallowtailClimateChange/blob/main/src/data/prep-forecast-data.R>) and I ended up using it to get data for the 2021-2040 time period with a Shared Socioeconomic Pathway (SSP) scenario of 2-4.5. This SSP represents a forecasted climate scenario where there is a moderate amount of CO2 input into the atmosphere that results in an additional radiative forcing of 4.5 W/m\^2 by the year 2100.
5.  ***run_maxent.R***
    -   The actual script containing the observation data, environmental variables, and MaxEnt parameter set-up is in `functions.R` (located in the main directory). The `run_maxent.R` script pulls in the function created to run MaxEnt in a loop for all four species, resulting in a model and predictions for each species -- which is stored in respective folders under `output`.
6.  ***species_distribution_maps.R***
    -   Takes in the prediction data (both current and forecasted time periods) outputted from `run_maxent.R` and generates predicted distribution maps for each species. The maps show the distributions where there is a greater than 50% chance of environmental suitability for the respective species. Much like `run_maxent.R`, the settings used to create each ggplot2 map are stored in `functions.R` to help create a more refined-looking code.
7.  Extra code for manuscript summary tables:
    -   ***observation_counts.R***
        -   Counts how many of the observations are in each country. The resulting table shows counts for each species.
    -   ***optimal_tables.R***
        -   Creates a table that shows the best-fitting model for each species.
    -   ***find_avg_elevations.R***
        -   Finds the average elevation across the predicted distribution area (current and forecasted) for each species.

*Last updated: June 25, 2024*
