library(shiny)
library(XML)

for(name in names(planets)) {
  print(name)
  print(planets[[name]][["rise"]])
}

planets$Moon[["rise"]]

ui <- fluidPage(
  actionButton(inputId = "update", label = "Update")
)

server <- function(input, output) {
  observeEvent(input$update, {
    data <- xmlParse("http://apple.accuweather.com/adcbin/apple/Apple_Weather_Data.asp?zipcode=lid_315524")
    data <- xmlToList(data)
    planets <- data[["Planets"]]
    print(planets$Sun)
  })
  
  currentData <- reactive(planets)
}

shinyApp(ui = ui, server = server)
