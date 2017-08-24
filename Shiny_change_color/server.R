library(shiny)
library(ggplot2)

shinyServer(function(input, output,session) {
  output$plot = renderPlot({
    data = data.frame(x = iris[,input$sel], y = iris$Sepal.Length)
    g = ggplot(data, aes(x = x, y = y))
    g = g + geom_point(colour=input$color)
    print(g)
  })
})
