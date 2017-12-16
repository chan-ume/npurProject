library(shiny)

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
    cols = colorRampPalette(c("#0068b7","white","#f39800"))
    
    csv_file = reactive(read.csv(input$file$datapath))
    
    x = csv_file()[input$x]
    y = csv_file()[input$y]
    
    data = cbind(x, y)
    
    if(input$clustering_method == "hclust"){
      hc = hclust(dist(data))
      clusters = cutree(hc, input$number)
      color = clusters
    }
    else{ #select k-means
      clusters = kmeans(data, input$number)
      color = clusters$cluster
    }
    
    output$plot = renderPlot({
      plot(data, col = color, pch = 20, cex = 3)
    })
  })
}
