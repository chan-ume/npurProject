library(shiny)
library(rJava)
library(ReporteRsjars)

shinyUI(
  
  fluidPage(    
    selectInput("sel",label = "col",choices = colnames(iris)[2:4]),
    selectInput("color",label = "col",choices = c("red", "black", "blue", "green")),
    plotOutput("plot"),
    downloadButton('downloadData', 'Download')
  )
)
