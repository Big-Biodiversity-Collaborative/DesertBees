# Maxine Cruz
# tmcruz@arizona.edu
# Created: March 20, 2023
# Last edited: March 20, 2023



### ABOUT THE SCRIPT ---

# Creates R Shiny app for Occurrence map of Centris pallida
# Also includes host plants of C. pallida (taxonKey - 1342915):
  # Parkinsonia florida - 5359949
  # Parkinsonia microphylla - 5359945
  # Parkinsonia aculeata - 5357217
  # Larrea tridentata - 7568403
  # Olneya tesota - 2974564
  # Cercidium spp. - NA



### LOAD LIBRARIES ---

# For app
library(shiny)
library(shinydashboard)
library(leaflet)
library(shinythemes)
library(bslib)
library(thematic)

# For data
library(readr)
library(tidyverse)



### LOAD MAPPING DATA ---

# This is the same NAm_map_data.csv from prelim.R
map_data <- read_csv("data/NAm_map_data.csv")

map_data <- map_data %>% 
  mutate(point_color = case_when(speciesKey == 1342915 ~ "#FF3E96",
                                 speciesKey == 5359949 ~ "#C0FF3E",
                                 speciesKey == 5359945 ~ "#00FFFF",
                                 speciesKey == 5357217 ~ "#FFA500",
                                 speciesKey == 7568403 ~ "#EED2EE",
                                 speciesKey == 2974564 ~ "#E066FF"))



### DEFINE UI ---

ui <- navbarPage(
  
  # Settings for header and theme
  title = "Centris pallida & Host Plants Occurrences in North America",
  theme = bs_theme(bootswatch = "sandstone",
                   bg = "#FFF5EE",
                   fg = "#556B2F",
                   base_font = font_google("Prompt"),
                   heading_font = font_google("Hubballi")),
  
  # Add sidebar content (disabled in this case)
  dashboardSidebar(disable = TRUE),
  
  # Add content to main body of page
  dashboardBody(
    
    # Lines boxes up on dashboardBody()
    fluidRow(
      
      # Box for widgets and notes
      box(width = 4,
          
          # Add title
          h3(HTML("<b>R Shiny Map of Occurrences</b>")),
          
          # Some text
          tags$hr(),
          helpText(HTML("This map displays <em>Centris pallida</em> and its",
                        "host plants occurrences in North America. Please",
                        "select data to be displayed on the interactive map.")),
          tags$hr(),
          
          # Controls for selecting data
          checkboxGroupInput(inputId = "checkbox",
                             h4(HTML("<b>Select data:</b>")),
                             choices = list("Centris pallida" = 1,
                                            "Parkinsonia aculeata" = 2,
                                            "Parkinsonia florida" = 3,
                                            "Parkinsonia microphylla" = 4,
                                            "Larrea tridentata" = 5,
                                            "Olneya tesota" = 6),
                             selected = c(1, 2, 3, 4, 5, 6)),
          
          # Add text
          tags$hr(),
          h4(HTML("<b>About the data</b>")),
          helpText(HTML("The data used to generate this map includes data",
                        "from the Global Biodiversity Information Facility",
                        "(GBIF) (<a>https://www.gbif.org/</a>). Duplicates",
                        "were removed from the data before plotting. In",
                        "addition, observations with NA listed for the",
                        "latitude and longitude were removed as well."))
      ),
      
      # Box for map
      box(width = 8,
          
          # Add map
          tags$style(type = "text/css",
                     "#map {height: calc(100vh - 80px) !important;}"),
          leafletOutput("map")
      )
    )
  )
)



### DEFINE SERVER LOGIC ---

server <- function(input, output) {
  
  # Generate map
  output$map <- renderLeaflet({ 
    
    # Select data of interest
    
    # Part 1: use local variable "datanames" to filter on column of same name
    datanames <- ""
    if (1 %in% input$checkbox) {
      datanames <- c(datanames, "1342915")
    }    
    if (2 %in% input$checkbox) {
      datanames <- c(datanames, "5357217")
    } 
    if (3 %in% input$checkbox) {
      datanames <- c(datanames, "5359949")
    }
    if (4 %in% input$checkbox) {
      datanames <- c(datanames, "5359945")
    }    
    if (5 %in% input$checkbox) {
      datanames <- c(datanames, "7568403")
    } 
    if (6 %in% input$checkbox) {
      datanames <- c(datanames, "2974564")
    }
    plot_data <- map_data %>%
      filter(speciesKey %in% as.numeric(datanames))
    
    # Settings for map
    leaflet() %>%
      addProviderTiles("Esri.WorldImagery") %>%
      addProviderTiles("Stamen.TonerLines") %>%
      addCircles(
        data = plot_data,
        color = plot_data$point_color,
        fillColor = plot_data$point_color,
        fillOpacity = 0.8) %>%
      addLegend(position = "bottomright",
                colors = c("#FF3E96", "#FFA500", "#C0FF3E", 
                                    "#00FFFF", "#EED2EE", "#E066FF"),
                                    labels = c("Centris pallida (220)", 
                                               "Parkinsonia aculeata (6469)",
                                               "Parkinsonia florida (3056)", 
                                               "Parkinsonia microphylla (3659)",
                                               "Larrea tridentata (51215)", 
                                               "Olneya tesota (3869)"),
                title = "Legend of Species (# records in North America)",
                opacity = 1) %>%
      setView(lng = -101.030339, lat = 26.791093, zoom = 4.4)
  })
}



### RUN APP ---

shinyApp(ui = ui, server = server)


