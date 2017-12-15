  server = function(input, output, session) {
  observeEvent(input$file, {
    
    csv_file = reactive(read.csv(input$file$datapath))
    output$table = renderTable(csv_file())
    
    output$colname1 = renderUI({ 
      selectInput("x", "x軸方向", colnames(csv_file()))
    })
    output$colname2 = renderUI({ 
      selectInput("y", "y軸方向", colnames(csv_file()))
    })
  })
  
  observeEvent(input$submit, {
    name = names(input$file)
    csv_file = reactive(read.csv(input$file$datapath))
    
    x = csv_file()[input$x]
    y = csv_file()[input$y]
    
    output$plot = renderPlot({
      plot(x[,1], y[,1])
    })
  })
}
