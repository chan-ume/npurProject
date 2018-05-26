library(shiny)

data_rhc = read.csv("http://biostat.mc.vanderbilt.edu/wiki/pub/Main/DataSets/rhc.csv")

shinyServer(function(input, output) {
  
  
  data = reactive({
    switch(input$select_data,
           "1" = iris,
           "2" = data_rhc,
           "3" = iris,
           "4" = data_rhc,
           "5" = iris)
  })
  
  data_regression = reactive({
    switch(input$select_data_regression,
           "1" = iris,
           "2" = data_rhc,
           "3" = iris,
           "4" = data_rhc,
           "5" = iris)
  })
  
  data_clasificagtion = reactive({
    switch(input$select_data_classfication,
           "1" = iris,
           "2" = data_rhc,
           "3" = iris,
           "4" = data_rhc,
           "5" = iris)
  })
  
  output$distPlot_shiny <- renderPlot({
    x    <- faithful[, 2]  # Old Faithful Geyser data
    bins <- seq(min(x), max(x), length.out = input$bins_shiny + 1)
    
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
  })
  
  output$histPlot <- renderPlot({
    x = data()[, input$select_columns_for_hist]
    hist(x, col = 'darkgray', border = 'white')
  })
  
  output$scatterPlot <- renderPlot({
    x = data_regression()[, input$select_columns_for_scatter_x]
    y = data_regression()[, input$select_columns_for_scatter_y]
    plot(x, y, col = 'darkgray', border = 'white')
  })
  
  output$table = DT::renderDataTable(data(), options= list(lengthMenu = c(5, 10, 20), pageLength = 5))
  
  output$plot_regression <- renderPlot({
    input$regressionButton
    
    x = isolate(data_regression())[, isolate(input$select_columns_for_regression_x)]
    y = isolate(data_regression())[, isolate(input$select_columns_for_regression_y)]
    
    lm = lm(x ~ y)
    plot(lm)
  })
  
  output$plot_classification <- renderPlot({
    input$classificationButton
    
    x = isolate(data_clasificagtion())[, isolate(input$select_columns_for_classification_x)]
    y = isolate(data_clasificagtion())[, isolate(input$select_columns_for_classification_y)]
    
    lm = lm(x ~ y)
    plot(lm)
  })
})
