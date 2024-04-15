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

-   **run_maxent.R**

    Runs the Maxent model on each of the four species. The code is separated into current (using [WorldClim](http://www.worldclim.com/version2)) and future (using [CMIP6)](https://wcrp-cmip.org/cmip-phase-6-cmip6/) prediction loops, and the results are stored in the following folders under output/:

    -   Centris pallida

    -   Olneya tesota

    -   Parkinsonia florida

    -   Parkinsonia microphylla

    ------------------------------------------------------------------------

-   **species_occurrence_maps.R**

    Generates occurrence maps for each of the four species, and makes a composite map as well. This script stores the maps in the following folder:

    -   output/occurrence_maps/
