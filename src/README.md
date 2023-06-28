## Description of R Script Files

-   **maxent.R**

    Runs Maximum Entropy model on Centris pallida observations in NAm_map_data.csv. Current climate data is from [WorldClim](https://worldclim.org/), and predicted climate data is from the [Coupled Model Intercomparison Project 5 (CMIP5)](https://esgf-node.llnl.gov/projects/cmip5/). Output is stored in the [outputs folder](https://github.com/Big-Biodiversity-Collaborative/DesertBees/tree/main/output) under maxent_outputs. Figures (also in the outputs folder) include:

    -   current_cpallida_sdm.jpg

    -   current_future_SDM.jpg

    -   future_cpallida_sdm_50yrs.jpg

    -   future_cpallida_sdm_70yrs.jpg

-   **NAm_data_further_reduced.R**

    Reduces NAm_map_data.csv to select species: *C. pallida*, *O. tesota*, *P. florida*, and *P. microphylla*. Draws boundary around observations and removes outliers based on requests -- desired boundary images are stored in [images](https://github.com/Big-Biodiversity-Collaborative/DesertBees/tree/main/images) as \~\_bounds.png files.

-   **prelim.R**

    Pulls GBIF data and generates the following raw and cleaned data files, stored in the [data folder](https://github.com/Big-Biodiversity-Collaborative/DesertBees/tree/main/data):

    -   full_map_data.csv

    -   gbif_rawdata_otesota.csv

    -   map_data.csv

    -   map_data2.csv

    -   NAm_map_data.csv

    Also generates a leaflet() map of the occurrence data from NAm_map_data.csv. With each species having their own point color.
