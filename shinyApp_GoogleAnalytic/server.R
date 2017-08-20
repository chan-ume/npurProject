library(shiny)
library(googleAuthR)
library(googleAnalyticsR)
library(listviewer)
library(ggplot2)
library(gridExtra)
library(Rmisc)

options(shiny.port = 1221)
options(googleAuthR.webapp.client_id = "")
options(googleAuthR.webapp.client_secret = "")
options(googleAuthR.scopes.selected = c("https://www.googleapis.com/auth/analytics.readonly"))

shinyServer(function(input, output, session){
  
  #####--------- Setup
  token <- callModule(googleAuth, "Google_login")
  
  ga_accounts <- reactive({
    validate(
      need(token(), "Authenticate")
    )
    with_shiny(google_analytics_account_list, shiny_access_token = token())
  })
  
  selected_id <- callModule(authDropdown, "viewId_select", ga.table = ga_accounts)
  
  #####--------- Calculated Metrics
  calc_dim <- callModule(multi_select, "dimensions_calc", type = "DIMENSION", subType = "all")
  calc_met <- callModule(multi_select, "metrics_calc", type = "METRIC", subType = "all")
  
  calc_data <- eventReactive(input$get_calc, {
    
    viewId <- selected_id()
    dims <- calc_dim()
    dates <- input$date_clac
    metric_name <- gsub(" ", "", input$calculated_name)
    metric_exp <- input$calculated_exp
    normal_metrics <- calc_met()
    
    if (metric_exp ==""){
      metrics = normal_metrics  
    }
    else {
      exp_metrics <- setNames(metric_exp, metric_name)
      metrics <- c(exp_metrics, normal_metrics)     
    }
    
    with_shiny(google_analytics_4,
               shiny_access_token = token(),
               viewId = viewId,
               date_range = c(dates[1], dates[2]),
               metrics = metrics,
               dimensions = dims)
  })
  
  output$text1 = renderText({
    paste("メトリクスの数は", length(calc_met()))
  })
  
  output$text2 = renderText({
    paste("ディメンションの数は", length(calc_dim()))
  })

  output$text3 = renderText({
    paste("calcメトリクスの数は", length(input$calculated_exp))
  })
  
  output$calc_table = renderDataTable({
    calc_data()
  })
  ## 円グラフ・棒グラフ・面グラフ・折れ線グラフ・散布図
  calc_data_for_plot = eventReactive(input$get_plot, {
    metrics_number = length(calc_met())
    dimension_number = length(calc_dim())
    
    if (input$calculated_exp ==""){
      calculated_metrics_number = 0
    }
    else {
      calculated_metrics_number = 1
    } 
    
    data_for_pie_chart = as.data.frame(calc_data())
    
    input_graph_type = input$graph_type
    ## 円グラフの処理
    if (input_graph_type == "円グラフ"){
      paste_dimension = data_for_pie_chart[,1]
      if (dimension_number > 1){
        for (i in 2:dimension_number){
          paste_dimension = paste(paste_dimension, data_for_pie_chart[,i], sep="-")
        }
      }
      data_for_pie_chart = cbind(data_for_pie_chart, paste_dimension)

      plots <- list()
      for (i in 1:(calculated_metrics_number + metrics_number)){
        metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
        tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension = data_for_pie_chart[,ncol(data_for_pie_chart)])
        g = ggplot(tmp_data_for_plot, aes(x = "", y = metrics, fill = dimension, label = metrics))
        g = g + geom_bar(width = 1, stat = "identity") + labs(title = metrics_name) + coord_polar("y") + geom_text(aes(x= "", y = metrics, label = metrics), size=6, position = position_stack(vjust = 0.5))
        g = g + theme(plot.title = element_text(size = 25, face = "bold"))
        plots[[i]] = g
      } 
      return(multiplot(plotlist = plots, cols = 2))
    }
    ## 棒グラフ1の処理
    if (input_graph_type == "棒グラフ1"){
      if (dimension_number == 1){
        plots <- list()
        for (i in 1:(calculated_metrics_number + metrics_number)){
          metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
          tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension = data_for_pie_chart[,1])
          g = ggplot(tmp_data_for_plot, aes(x = dimension, y = metrics, fill = dimension))
          g = g + geom_bar(width = 0.8, stat = "identity") + labs(title = metrics_name) #+ geom_text(aes(x= "",y=y,label = metrics), size=3)
          g = g + theme(plot.title = element_text(size = 25, face = "bold"))
          plots[[i]] = g
        } 
        return(multiplot(plotlist = plots, cols = 2))
      }
    
      if (dimension_number <= 2){
        paste_dimension1 = data_for_pie_chart[,1]
        paste_dimension2 = data_for_pie_chart[,2]
      }
      else {
        paste_dimension1 = data_for_pie_chart[,1]
        paste_dimension2 = data_for_pie_chart[,2]
        for (i in 3:dimension_number){
          paste_dimension2 = paste(paste_dimension2, data_for_pie_chart[,i], sep="-")
        }
        
      }

      plots <- list()
      for (i in 1:(calculated_metrics_number + metrics_number)){
        metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
        tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension1 = paste_dimension1, dimension2 = paste_dimension2)
        g = ggplot(tmp_data_for_plot, aes(x = dimension1, y = metrics, fill = dimension2))
        g = g + geom_bar(width = 0.8, stat = "identity") + labs(title = metrics_name) #+ geom_text(aes(x= "",y=y,label = metrics), size=3)
        g = g + theme(plot.title = element_text(size = 25, face = "bold"))
        plots[[i]] = g
      }
      return(multiplot(plotlist = plots, cols = 2))
    }
    
    ## 棒グラフ2の処理
    if (input_graph_type == "棒グラフ2"){
      if (dimension_number == 1){
        plots <- list()
        for (i in 1:(calculated_metrics_number + metrics_number)){
          metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
          tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension = data_for_pie_chart[,1])
          g = ggplot(tmp_data_for_plot, aes(x = dimension, y = metrics, fill = dimension))
          g = g + geom_bar(width = 0.8, stat = "identity") + labs(title = metrics_name) #+ geom_text(aes(x= "",y=y,label = metrics), size=3)
          g = g + theme(plot.title = element_text(size = 25, face = "bold"))
          plots[[i]] = g
        } 
        return(multiplot(plotlist = plots, cols = 2))
      }
      
      if (dimension_number <= 2){
        paste_dimension1 = data_for_pie_chart[,1]
        paste_dimension2 = data_for_pie_chart[,2]
      }
      else {
        paste_dimension1 = data_for_pie_chart[,1]
        paste_dimension2 = data_for_pie_chart[,2]
        for (i in 3:dimension_number){
          paste_dimension2 = paste(paste_dimension2, data_for_pie_chart[,i], sep="-")
        }
        
      }

      plots <- list()
      for (i in 1:(calculated_metrics_number + metrics_number)){
        metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
        tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension1 = paste_dimension1, dimension2 = paste_dimension2)
        g = ggplot(tmp_data_for_plot, aes(x = dimension1, y = metrics, fill = dimension2))
        g = g + geom_bar(position = "dodge", width = 0.8, stat = "identity") + labs(title = metrics_name) #+ geom_text(aes(x= "",y=y,label = metrics), size=3)
        g = g + theme(plot.title = element_text(size = 25, face = "bold"))
        plots[[i]] = g
      }
      return(multiplot(plotlist = plots, cols = 2))
    }
    
    ## 折れ線グラフの処理
    if (input_graph_type == "折れ線グラフ"){
      if (dimension_number == 1){
        plots <- list()
        for (i in 1:(calculated_metrics_number + metrics_number)){
          metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
          tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension = data_for_pie_chart[,1])
          g = ggplot(tmp_data_for_plot, aes(x = dimension, y = metrics))
          g = g + geom_point() + geom_line(linetype="solid") + labs(title = metrics_name) #+ geom_text(aes(x= "",y=y,label = metrics), size=3)
          g = g + theme(plot.title = element_text(size = 25, face = "bold"))
          plots[[i]] = g
        } 
        return(multiplot(plotlist = plots, cols = 2))
      }
      
      if (dimension_number <= 2){
        paste_dimension1 = data_for_pie_chart[,1]
        paste_dimension2 = data_for_pie_chart[,2]
      }
      else {
        paste_dimension1 = data_for_pie_chart[,1]
        paste_dimension2 = data_for_pie_chart[,2]
        for (i in 3:dimension_number){
          paste_dimension2 = paste(paste_dimension2, data_for_pie_chart[,i], sep="-")
        }
        
      }

      plots <- list()
      for (i in 1:(calculated_metrics_number + metrics_number)){
        metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
        tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension1 = paste_dimension1, dimension2 = paste_dimension2)
        g = ggplot(tmp_data_for_plot, aes(x = dimension1, y = metrics, colour = dimension2))
        g = g + geom_point() + geom_line(linetype="solid") + labs(title = metrics_name) #+ geom_text(aes(x= "",y=y,label = metrics), size=3)
        g = g + theme(plot.title = element_text(size = 25, face = "bold"))
        plots[[i]] = g
      }
      return(multiplot(plotlist = plots, cols = 2))
    }
    
    ## 散布図の処理
    if (input_graph_type == "散布図"){
      if (dimension_number == 1){
        plots <- list()
        for (i in 1:(calculated_metrics_number + metrics_number)){
          metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
          tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension = data_for_pie_chart[,1])
          g = ggplot(tmp_data_for_plot, aes(x = dimension, y = metrics))
          g = g + geom_point() + labs(title = metrics_name) #+ geom_text(aes(x= "",y=y,label = metrics), size=3)
          g = g + theme(plot.title = element_text(size = 25, face = "bold"))
          plots[[i]] = g
        } 
        return(multiplot(plotlist = plots, cols = 2))
      }
      
      if (dimension_number <= 2){
        paste_dimension1 = data_for_pie_chart[,1]
        paste_dimension2 = data_for_pie_chart[,2]
        plots <- list()
        for (i in 1:(calculated_metrics_number + metrics_number)){
          metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
          tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension1 = paste_dimension1, dimension2 = paste_dimension2)
          g = ggplot(tmp_data_for_plot, aes(x = dimension1, y = metrics, colour = dimension2))
          g = g + geom_point() + labs(title = metrics_name) #+ geom_text(aes(x= "",y=y,label = metrics), size=3)
          g = g + theme(plot.title = element_text(size = 25, face = "bold"))
          plots[[i]] = g
        } 
        return(multiplot(plotlist = plots, cols = 2))
      }
      else if (dimension_number <= 3) {
        paste_dimension1 = data_for_pie_chart[,1]
        paste_dimension2 = data_for_pie_chart[,2]
        paste_dimension3 = data_for_pie_chart[,3]
      }
      else {
        for (i in 4:dimension_number){
          paste_dimension3 = paste(paste_dimension3, data_for_pie_chart[,i], sep="-")
        }        
      }
      
      plots <- list()
      for (i in 1:(calculated_metrics_number + metrics_number)){
        metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
        tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension1 = paste_dimension1, dimension2 = paste_dimension2, dimension3 = paste_dimension3)
        g = ggplot(tmp_data_for_plot, aes(x = dimension1, y = metrics, colour = dimension2))
        g = g + geom_point(aes(colour = dimension2, shape = dimension3)) + labs(title = metrics_name) #+ geom_text(aes(x= "",y=y,label = metrics), size=3)
        g = g + theme(plot.title = element_text(size = 25, face = "bold"))
        plots[[i]] = g
      } 
      return(multiplot(plotlist = plots, cols = 2))
    }
    
    ## 面グラフの処理
    if (input_graph_type == "面グラフ"){
      if (dimension_number == 1){
        plots <- list()
        for (i in 1:(calculated_metrics_number + metrics_number)){
          metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
          tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension = data_for_pie_chart[,1])
          g = ggplot(tmp_data_for_plot, aes(x = dimension, y = metrics))
          g = g + geom_area() + labs(title = metrics_name) #+ geom_text(aes(x= "",y=y,label = metrics), size=3)
          g = g + theme(plot.title = element_text(size = 25, face = "bold"))
          plots[[i]] = g
        } 
        return(multiplot(plotlist = plots, cols = 2))
      }
      
      if (dimension_number <= 2){
        paste_dimension1 = data_for_pie_chart[,1]
        paste_dimension2 = data_for_pie_chart[,2]
      }
      else {
        paste_dimension1 = data_for_pie_chart[,1]
        paste_dimension2 = data_for_pie_chart[,2]
        for (i in 3:dimension_number){
          paste_dimension2 = paste(paste_dimension2, data_for_pie_chart[,i], sep="-")
        }
        
      }
      
      plots <- list()
      for (i in 1:(calculated_metrics_number + metrics_number)){
        metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
        tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension1 = paste_dimension1, dimension2 = paste_dimension2)
        g = ggplot(tmp_data_for_plot, aes(x = dimension1, y = metrics))
        g = g + geom_area(aes(group = dimension2, fill = dimension2)) + labs(title = metrics_name) #+ geom_text(aes(x= "",y=y,label = metrics), size=3)
        g = g + theme(plot.title = element_text(size = 25, face = "bold"))
        plots[[i]] = g
      }
      return(multiplot(plotlist = plots, cols = 2))
     }
   }
  )
  
  output$image_example <- renderImage({
    image_src = paste(input$graph_type, ".png", sep="")
    list(src = image_src,
         alt = image_src)
    
  }, deleteFile = FALSE)
  
  output$calc_plot = renderPlot({
    calc_data_for_plot()
  })
})
