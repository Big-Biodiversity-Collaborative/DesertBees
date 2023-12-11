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

-   **get_climate.R**

    [Description]

    ------------------------------------------------------------------------

-   **predict.R**

    [Description]

    Separate into current and future SDM files?
