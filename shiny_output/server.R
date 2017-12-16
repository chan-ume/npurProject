#server.R
library(shiny)
library(DT)
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  #データのインポート
  data <- reactive({
    iris
  })
  
  #text
  output$text <- renderPrint(
    "text test >>%% \n
    bbbb"
  )
  
  #table
  output$table <- renderTable({
    data()
  })
  
  #plot
  output$distPlot <- renderPlot({
    hist(data()[,1])
  })
  
  #dataTable
  output$dataTable <- renderDataTable({
    data()
  })
  #image
  output$image <- renderImage({
    #fileを指定する
    outfile <- './sample.jpg'
    list(src = outfile)
  }, deleteFile = FALSE)
  
  #verbatemText
  output$vtext <- renderText({
    "aaaa >> %% $$ \n
    bbbb"
  })
  
  #html output
  output$html <- renderUI({
    tagList(
      sliderInput("n", "N", 1, 1000, 500),
      textInput("label", "Label")
    )
  })
    
  #ui output
  output$ui <- renderUI({
      tagList(
        sliderInput("n", "N", 1, 1000, 500),
        textInput("label", "Label")
      )
  })
})
