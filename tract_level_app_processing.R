library(tidyverse)
library(here)
library(arrow)
library(janitor)
library(tigris)
library(tidycensus)
library(mapgl)
library(shiny)
library(sf)

# Read in Data

tract_level_19_23_data <- read_feather(here("data/tract_level_19_23_data.feather"))

tract_level_19_23_data <- tract_level_19_23_data %>% 
  clean_names()

tract_level_19_23_data$cest <- as.numeric(tract_level_19_23_data$cest)


tract_level_19_23_data <- tract_level_19_23_data %>% 
  filter(age == "Total", ability_to_speak_english == "Total")


tract_level_sums_per_language <- tract_level_19_23_data %>% 
  group_by(geoname, language) %>% 
  summarize(speakers = sum(cest, na.rm = TRUE))

county_level_sums_per_language <- tract_level_sums_per_language %>% 
  mutate(geoname = stringr::str_extract(geoname, "(?<=, ).*")) %>%
  group_by(geoname, language) %>%
  summarise(speakers = sum(speakers, na.rm = TRUE))
  

# Add shapefiles with populations for tracts

tract_pops <- get_acs(
  geography = "tract",
  variables = "B01003_001",  # Total Population
  state = c(state.abb, "DC", "PR"),
  year = 2023,
  geometry = TRUE,
  resolution = "5m"
)

tract_pops <- tract_pops %>% 
  rename(geoname = "NAME")

tract_level_sums_per_language <- tract_level_sums_per_language %>% 
  mutate(geoname = stringr::str_replace_all(geoname, ",", ";"))

tract_data <- full_join(tract_level_sums_per_language, tract_pops, 
                        by = "geoname")


# Add shapefiles with populations for counties

county_pops <- get_acs(
  geography = "county",
  variables = "B01003_001",  # Total Population
  state = c(state.abb, "DC", "PR"),
  year = 2023,
  geometry = TRUE,
  resolution = "5m"
)

county_pops <- county_pops %>% 
  rename(geoname = "NAME")


county_data <- full_join(county_level_sums_per_language, county_pops,
                         by = c("geoname"))

# Set as sf objects
tract_data <- st_as_sf(tract_data)
county_data <- st_as_sf(county_data)


# define speakers as percentage of speakers per tract or per county

tract_data <- tract_data %>% 
  mutate(percent_speakers = round((speakers / estimate) * 100, 2))

county_data <- county_data %>% 
  mutate(percent_speakers = round((speakers / estimate) * 100, 2))



# Write as sf objects

st_write(county_data, here("data/county_data.gpkg"), delete_layer = TRUE)
st_write(tract_data, here("data/tract_data.gpkg"), delete_layer = TRUE)
  
  
# # county_data <- county_data %>% 
# #   mutate(geoname = stringr::str_replace_all(geoname, ",", ";"))
# 
# 
# ### Visualize with mapgl TEST
# 
# spanish_tract_data <- tract_data %>% 
#   filter(language == "Spanish")
# 
# spanish_county_data <- county_data %>% 
#   filter(language == "Spanish")
# 
# spanish_tract_data <- st_as_sf(spanish_tract_data)
# 
# spanish_county_data <- st_as_sf(spanish_county_data)
# 
# # spanish_tract_data <- st_transform(spanish_tract_data, 4326)
# # spanish_county_data <- st_transform(spanish_county_data, 4326)
# 
# 
# maplibre(
#   style = carto_style("positron"),
#   center = c(-98.5795, 39.8283),
#   zoom = 3
# ) |>
#   set_projection("globe") |>
#   add_fill_layer(
#     id = "fill-layer",
#     source = spanish_tract_data,
#     fill_color = interpolate(
#       column = "speakers",
#       values = c(100, 5000, 50000),
#       stops = c("#edf8b1", "#7fcdbb", "#2c7fb8"),
#       na_color = "lightgrey"
#     ),
#     fill_opacity = 0.7,
#     min_zoom = 8,
#     tooltip = "speakers"
#   ) |>
#   add_fill_layer(
#     id = "county-fill-layer",
#     source = spanish_county_data,
#     fill_color = interpolate(
#       column = "speakers",
#       type = "linear",
#       values = c(1000, 25000, 150000),
#       stops = c("#edf8b1", "#7fcdbb", "#2c7fb8"),
#       na_color = "lightgrey"
#     ),
#     fill_opacity = 0.7,
#     max_zoom = 7.99,
#     tooltip = "speakers"
#   ) |>
#   add_continuous_legend(
#     "Spanish Speakers",
#     values = c("1K", "25K", "150K"),
#     colors = c("#edf8b1", "#7fcdbb", "#2c7fb8")
#   )
# 
# 
# 
# ### Test shiny app
# 
# 
# 
# # Get unique languages for dropdown
# available_languages <- unique(tract_data$language)
# 
# # Define UI
# ui <- fluidPage(
#   titlePanel("Language Distribution Map"),
#   
#   sidebarLayout(
#     sidebarPanel(
#       selectInput(
#         "language_choice", 
#         "Choose a Language:", 
#         choices = available_languages, 
#         selected = "Spanish"
#       )
#     ),
#     
#     mainPanel(
#       maplibreOutput("language_map", height = "600px")
#     )
#   )
# )
# 
# # Define Server Logic
# server <- function(input, output, session) {
#   
#   # Reactive dataset based on selected language
#   selected_data <- reactive({
#     tract_filtered <- tract_data %>%
#       filter(language == input$language_choice)
#     
#     county_filtered <- county_data %>%
#       filter(language == input$language_choice)
#     
#     list(tract = tract_filtered, county = county_filtered)
#   })
#   
#   # Render the Map
#   output$language_map <- renderMaplibre({
#     data <- selected_data()
#     
#     maplibre(
#       style = carto_style("positron"),
#       center = c(-98.5795, 39.8283),
#       zoom = 3
#     ) |>
#       set_projection("globe") |>
#       add_fill_layer(
#         id = "fill-layer",
#         source = data$tract,
#         fill_color = interpolate(
#           column = "percent_speakers",  # Use precomputed percent
#           type = "linear",
#           values = c(0, 10, 50),  # Adjust based on distribution
#           stops = c("#edf8b1", "#7fcdbb", "#2c7fb8"),
#           na_color = "lightgrey"
#         ),
#         fill_opacity = 0.7,
#         min_zoom = 8,
#         tooltip = "percent_speakers"
#       ) |>
#       add_fill_layer(
#         id = "county-fill-layer",
#         source = data$county,
#         fill_color = interpolate(
#           column = "percent_speakers",  # Use precomputed percent
#           type = "linear",
#           values = c(0, 5, 25),  # Adjust based on distribution
#           stops = c("#edf8b1", "#7fcdbb", "#2c7fb8"),
#           na_color = "lightgrey"
#         ),
#         fill_opacity = 0.7,
#         max_zoom = 7.99,
#         tooltip = "percent_speakers"
#       ) |>
#       add_continuous_legend(
#         "Percent of Population Speaking Language",
#         values = c("0%", "10%", "50%"),
#         colors = c("#edf8b1", "#7fcdbb", "#2c7fb8")
#       )
#   })
# }
# 
# # Run the Shiny App
# shinyApp(ui, server)
