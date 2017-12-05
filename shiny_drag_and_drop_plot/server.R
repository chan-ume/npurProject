server = function(input, output, session) {
  observeEvent(input$mydata, {

    name = names(input$mydata)
    csv_file = reactive(read.csv(text=input$mydata[[name]]))
    output$table = renderTable(csv_file())
  
    output$colname1 = renderUI({ 
      selectInput("x", "x軸方向", colnames(csv_file()))
    })
    output$colname2 = renderUI({ 
      selectInput("y", "y軸方向", colnames(csv_file()))
    })
  })
  
  observeEvent(input$submit, {
    name = names(input$mydata)
    csv_file = reactive(read.csv(text=input$mydata[[name]]))
    
    x = csv_file()[input$x]
    y = csv_file()[input$y]
    
    output$plot = renderPlot({
      plot(x[,1], y[,1])
    })
  })
}
