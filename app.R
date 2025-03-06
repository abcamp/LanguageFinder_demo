## This is the LanguageFinder demo app created to present at ICLDC9
## This version is county-level only
## 6 March 2025

library(shiny)
library(mapgl)
library(here)
library(sf)
library(reactable)
library(viridis)
library(tidyverse)

# Load Data
county_data <- st_read(here("data/county_data.gpkg"))

# Get unique languages for dropdown
available_languages <- sort(unique(county_data$language))

# Define UI
ui <- fluidPage(
  tags$head(tags$title("LanguageFinder demo - Counties by Language"), # added to edit browser title
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
  
  titlePanel(
    div(
      img(src = "SpiceLogo1.png", height = "50px", 
          style = "vertical-align: middle; margin-right: 10px;"),
      span("LanguageFinder demo", class = "language-title") 
    )
  ),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "language_choice", 
        "Choose a Language:", 
        choices = available_languages, 
        selected = "Hawaiian"
      ),
      
      div(
        HTML("<p><strong>Find out which languages other than English are spoken in particular places.</strong></p>
          <p>Translations and interpretation services are key tools to increase accessibility to information. 
          Access to information is especially important in relation to:</p>
          <ul>
            <li>Disaster warnings and disaster response;</li>
            <li>Healthcare, especially treatment options and recovery instructions;</li>
            <li>Local government engagement;</li>
            <li>Environmental justice;</li>
            <li>Workplace safety.</li>
          </ul>
          <p>See how many people speak a particular language in different places.</p>
          <p>Understanding how speakers of a certain language are distributed across the U.S. can help organizations 
          find collaborative partners in creating translations and interpretive services for that language.</p>
          <p>Organizations that serve particular language communities can use this information to identify key service areas.</p>
          <p>This project seeks to make data about languages spoken in the U.S. accessible to decision-makers in social sector enterprises. 
          Key variables for decision-makers include the detailed language spoken, ability to speak English, and potentially age, for 
          organizations that serve specific age groups, e.g., voting-age population, K-12 children, seniors, etc.</p>
          
          <h3>About the Data</h3>
          <p>The data comes from the <a href='https://www.census.gov/' target='_blank'>US Census Bureau</a> 
          <a href='https://www.census.gov/programs-surveys/acs' target='_blank'>American Community Survey</a>, 
          5-year estimates from 2019-2023. This is the most reliable and most recent data available on languages spoken at home in the US. 
          This data is collected using the following questions:</p>
          
          <img src='language_600_q14.avif' width='50%' alt='Language Spoken at Home question on the American Community Survey'>
          
          <p>The US Census Bureau reports 130 language categories, including 105 individual languages (e.g., Spanish, Hawaiian) and 25 aggregated language categories (e.g., Other Malayo-Polynesian languages, Aleut languages).</p>
          <p>Where age information is given, ages were divided into three categories: Youth (age 5-17), Working Age (18-64), and Senior (65-99). 
          Data for individuals under age 5 and above age 99 are not provided by the US Census Bureau.</p>
          <p>Where Ability to Speak English is given, this data is self-reported in part C of the question shown above.</p>
          <p>Updated March 2025</p>")
      )
    ),
    
    mainPanel(
      h3("Interactive Map of U.S. Counties where Selected Language is Spoken"),
      maplibreOutput("language_map", height = "600px"),
      br(),
      h3("Top 20 Counties with the Highest Percentage of Speakers"),
      reactableOutput("top_counties_table")
    )
  )
)

# Define Server Logic
server <- function(input, output, session) {
  
  selected_data <- reactive({
    county_data %>%
      filter(language == input$language_choice)
  })
  
  output$language_map <- renderMaplibre({
    data <- selected_data()
    
    maplibre(
      style = carto_style("positron"),
      center = c(-98.5795, 39.8283),
      zoom = 3
    ) |>
      set_projection("globe") |>
      add_fill_layer(
        id = "county-fill-layer",
        source = data,
        fill_color = interpolate(
          column = "percent_speakers",
          type = "linear",
          values = c(0, 0.5, 1, 2, 5, 10, 20, 30, 50), # edited breaks, was 0, 2, 5, 10, 15, 20, 25, 30, 45, 50
          stops = rev(mako(9)), # was magma
          na_color = "lightgrey"
        ),
        fill_opacity = 0.7,
        tooltip = "percent_speakers"
      ) |>
      add_continuous_legend(
        "Percent of Population Speaking Language",
        values = c(0, 0.5, 1, 2, 5, 10, 20, 30, 50),
        colors = rev(mako(9)),
        width = "250px"
      )  
  })
  
  output$top_counties_table <- renderReactable({
    data <- selected_data() %>%
      st_drop_geometry() %>%
      select(geoname, speakers, percent_speakers) %>%
      arrange(desc(percent_speakers)) %>%
      head(20)
    
    reactable(data, 
              columns = list(
                geoname = colDef(name = "County"),
                speakers = colDef(name = "Speakers", format = colFormat(separators = TRUE)),
                percent_speakers = colDef(name = "Percent Speakers", format = colFormat(suffix = "%", digits = 2))
              ),
              highlight = TRUE,
              bordered = TRUE,
              striped = TRUE
    )
  })
}

# Run the Shiny App
shinyApp(ui, server)

