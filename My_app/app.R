library(shiny)
library(shinydashboard)
library(XML)
library(weathermetrics)

ui <- dashboardPage(
  
  # Header
  dashboardHeader(title="First dashboard"),
  
  # Menu sidebar
  dashboardSidebar(
    sidebarMenu(
      menuItem("Weather", tabName = "weather", icon = icon("cloud")),
      menuItem("Planets", tabName = "planets", icon = icon("moon"))
    )
  ),
  
  # Contents
  dashboardBody(
    tabItems(
      
      # Weather tab
      tabItem(tabName = "weather",
          fluidRow(
            column(width = 3,
              box(width = NULL, status = "primary",
                h1(textOutput(outputId = "city")),
                textOutput(outputId = "weather"),
                textOutput(outputId = "temp"),
                textOutput(outputId = "tempfeel"),
                textOutput(outputId = "time")
              ),
              box(width = NULL, status = "warning",
                  selectInput(inputId = "select_city", label = "Select a different city", choices = c("Uppsala", "Stockholm", "Kiruna", "Malaga"))
              )
            )
          )
      ),
      
      # Planet tab
      tabItem(tabName = "planets",
              
        h1("Rise and set times in Uppsala"),
        
        # Select box
        fluidRow(
          box(width = 3,
              selectInput(inputId = "select_planet", label = "Select planet", choices = c("Sun", "Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"))
          )
        ),
        # Display boxes
        fluidRow(
          valueBoxOutput("riseBox", width = 2),
          valueBoxOutput("setBox", width = 2)
        )
      )
      
    )
  )
)

server <- function(input, output) {
  
  # Weather page
  
  # Function for transforming the temp data
  toCelsius <- function(temp) {
    return(fahrenheit.to.celsius(as.numeric(temp), round = 1))
  }
  
  # Get weather data from Accuweather
  weather <- eventReactive(input$select_city, {
    val <- input$select_city
    data <- xmlParse(paste("http://apple.accuweather.com/adcbin/apple/Apple_Weather_Data.asp?location=",val))
    data <- xmlToList(data)
    return(data[["CurrentConditions"]])

  })
  
  output$city <- renderText({paste("Weather in ", weather()[["City"]])})
  output$time <- renderText({paste("Last updated: ", weather()[["Time"]])})
  output$weather <- renderText({paste("Weather: ", weather()[["WeatherText"]])})
  output$temp <- renderText({paste("Temperature: ", toCelsius(weather()[["Temperature"]]), " C")})
  output$tempfeel <- renderText({paste("Feels like: ", toCelsius(weather()[["RealFeel"]]), " C")})
  
  # Planet page
  
  # Get planet data from Accuweather
  planet <- eventReactive(input$select_planet, {
    val <- input$select_planet
    data <- xmlParse(paste("http://apple.accuweather.com/adcbin/apple/Apple_Weather_Data.asp?location=Uppsala"))
    data <- xmlToList(data)
    data <- data[["Planets"]]
    return(data[[val]])
    
  })
  
  output$riseBox <- renderValueBox({
    valueBox(
      planet()[["rise"]], "Rise", icon = icon("globe"), color = "yellow"
    )
  })
  
  output$setBox <- renderValueBox({
    valueBox(
      planet()[["set"]], "Set", icon = icon("globe"), color = "purple"
    )
  })
}

shinyApp(ui = ui, server = server)

