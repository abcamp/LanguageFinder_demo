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
available_languages <- unique(county_data$language)

# Define UI
ui <- fluidPage(
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
  
  titlePanel(
    div(
      img(src = "SpiceLogo1.png", height = "50px", 
          style = "vertical-align: middle; margin-right: 10px;"),
      span("LanguageFinder", class = "language-title")
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
          <p>Understanding how speakers of a certain language are distributed across the U.S. can help organizations 
          find collaborative partners in creating translations and interpretive services for that language.</p>")
      )
    ),
    
    mainPanel(
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
          values = c(0, 2, 5, 10, 15, 20, 25, 30, 45, 50),
          stops = magma(10),
          na_color = "lightgrey"
        ),
        fill_opacity = 0.7,
        tooltip = "percent_speakers"
      ) |>
      add_continuous_legend(
        "Percent of Population Speaking Language",
        values = c(0, 2, 5, 10, 15, 20, 25, 30, 45, 50),
        colors = magma(10),
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

