## Description of Data Files

The data used in this project are downloaded directly from the source site, with the exception of GBIF (the script used to retrieve the occurrence data is in src/get_GBIF.R). The sites that the data were collected from is listed below.

-   **GBIF:** Organism data from the [Global Biodiversity Information Facility](https://www.gbif.org/)

    -   The zip file is the raw download after requesting the data from GBIF.

    -   cleaned_species.csv

    -   raw_species.csv

        ------------------------------------------------------------------------

-   **CMIP6:** Forecast climate data from the [Coupled Model Intercomparison Project, Phase 6](https://wcrp-cmip.org/cmip-phase-6-cmip6/)

    -   An ensemble of the CMIP6 climate models under the SSP370 emissions scenario for 2041-2070.

    -   Data retrieval and preparation is done by Jeff Oliver here: [prep-forecast-data.R · Big-Biodiversity-Collaborative/SwallowtailClimateChange (github.com)](https://github.com/Big-Biodiversity-Collaborative/SwallowtailClimateChange/blob/main/src/data/prep-forecast-data.R).

    -   Resolution: \~ 4 x 4 km

    -   bio1.tif - bio19.tif

        ------------------------------------------------------------------------

-   **WORLDCLIM:** Current climate data from [WorldClim (version 2.1)](http://www.worldclim.com/version2)

    -   Used historical monthly data from 2000-2018 ([link to site](https://worldclim.org/data/monthlywth.html)) for calculation of the 19 bioclimatic variables that are used for the model.

    -   Data retrieval and preparation is also done by Jeff Oliver here: [prep-climate-data.R · Big-Biodiversity-Collaborative/SwallowtailClimateChange (github.com)](https://github.com/Big-Biodiversity-Collaborative/SwallowtailClimateChange/blob/main/src/data/prep-climate-data.R)

    -   Resolution: \~ 21 x 21 km (2.5 minutes of a degree)

    -   bio1.tif - bio19.tif

        ------------------------------------------------------------------------

-   **DEM:** Elevation data from the [North American Environmental Atlas](http://www.cec.org/north-american-environmental-atlas/elevation-2007/) (Elevation, 2023)

    -   Terrain of North America in relation to mean sea level. Utilizes elevation data sourced from the Global Multi-resolution Terrain Elevation Data 2010 (GMTED2010).
    -   Resolution: \~ 1 x 1 km
    -   northamerica_elevation_cec_2023.tif
