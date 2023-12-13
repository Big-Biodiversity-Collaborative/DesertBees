## Description of R Script Files

*Currently reorganizing \~*

This folder contains the code used in data cleaning / analysis, and for figure generation.

-   **get_GBIF.R**

    Retrieves data from the [Global Biodiversity Information Facility](https://www.gbif.org/) of four species:

    -   Desert / Digger Bee (*Centris pallida*)

    -   Blue Palo Verde (*Parkinsonia florida*)

    -   Foothill Palo Verde (*Parkinsonia microphylla*)

    -   Desert Ironwood (*Olneya tesota*)

    The data is processed to remove those with no geographic coordinates (latitude and longitude), duplicates, and other characteristics that may contribute to the accuracy and analysis of the data. The cleaning includes consideration of the species' documented range, so a polygon is also drawn around the observations and the outliers are excluded from the analysis. This script creates the following files:

    -   data/GBIF/cleaned_species.csv

    ------------------------------------------------------------------------

-   **get_predictors.R**

    Prepares predictors for use in Maxent model. Some files are downloaded directly from the site, and others are retrieved using packages such as `geodata`. The predictors being used here include:

    -   *WorldClim (for current climate)*

        -   Site: <https://test2.biogeo.ucdavis.edu/wc2/#/>

        -   \~ 1x1 km resolution

    -   *CMIP6 (ensemble from Jeff Oliver) (for predicted climate)*

        -   Site: <https://github.com/Big-Biodiversity-Collaborative/SwallowtailClimateChange/blob/main/src/data/prep-forecast-data.R>

        -   Coupled Model Intercomparison Project (CMIP), Phase 6

        -   2041-2070

        -   SSP370

        -   \~ 4x4 km resolution

    -   *North American Environmental Atlas (for elevation)*

        -   Site: <http://www.cec.org/north-american-environmental-atlas/elevation-2023/>

        -   Digital Elevation Model (DEM)

        -   \~ 1x1 km resolution

    The resolutions and coordinate reference systems (CRS) are matched so a stack can be formed for use in `ENMevaluate`'s Maxent. This script creates the following files:

    -   [Insert files later]

        ------------------------------------------------------------------------

-   **run_maxent.R**

    [Description]

    Separate into current and future SDM files?
