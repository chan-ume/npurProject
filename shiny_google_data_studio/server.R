library(shiny)
library(googleAuthR)
library(googleAnalyticsR)
library(listviewer)
library(ggplot2)
library(gridExtra)
library(Rmisc)
library(dplyr)
library(ReporteRs)
library(rJava)
library(RColorBrewer)

options(shiny.port = 1221)
options(googleAuthR.webapp.client_id = "")
options(googleAuthR.webapp.client_secret = "")
options(googleAuthR.scopes.selected = c("https://www.googleapis.com/auth/analytics.readonly"))

shinyServer(function(input, output, session){
  
  #####--------- Setup
  token = callModule(googleAuth, "Google_login")
  
  ga_accounts = reactive({
    validate(
      need(token(), "Authenticate")
    )
    with_shiny(google_analytics_account_list, shiny_access_token = token())
  })
  
  selected_id = callModule(authDropdown, "viewId_select", ga.table = ga_accounts)
  
  #####--------- Calculated Metrics
  calc_dim = callModule(multi_select, "dimensions_calc", type = "DIMENSION", subType = "all")
  calc_met = callModule(multi_select, "metrics_calc", type = "METRIC", subType = "all")
 
  calc_data = eventReactive(input$get_calc, {
    
    viewId = selected_id()
    dims = calc_dim()
    dates = input$date_clac
    metric_name = gsub(" ", "", input$calculated_name)
    metric_exp = input$calculated_exp
    normal_metrics = calc_met()
    
    if (metric_exp ==""){
      metrics = normal_metrics  
    }
    else {
      exp_metrics = setNames(metric_exp, metric_name)
      metrics = c(exp_metrics, normal_metrics)     
    }
    
    with_shiny(google_analytics_4,
               shiny_access_token = token(),
               viewId = viewId,
               date_range = c(dates[1], dates[2]),
               metrics = metrics,
               dimensions = dims,
               metricFormat = rep("FLOAT", length = length(metrics)),
               samplingLevel = 'LARGE'
               )
  })
  
  output$calc_table = renderDataTable({
    dimension_number = length(calc_dim())
    data = calc_data()
    data[,(dimension_number+1):ncol(data)] = round(data[,(dimension_number+1):ncol(data)],3)
    data
  })
  ################################
  ###グラフ出力のための関数定義###
  ################################
  
  ## 2つ以上のディメンションが入力された場合に1つにまとめる処理
  modify_dimension_number_to_1 = function(data, dimension_number){
    paste_dimension = data[,1]
    if (dimension_number > 1){
      for (i in 2:dimension_number){
        paste_dimension = paste(paste_dimension, data[,i], sep="-")
      }
    }
    return (paste_dimension)
  }
  
  ## 3つ以上のディメンションが入力された場合に2つにまとめる処理
  modify_dimension_number_to_2 = function(data, dimension_number){
    if (dimension_number <= 2){
      paste_dimension1 = data[,1]
      paste_dimension2 = data[,2]
    }
    else {
      paste_dimension1 = data[,1]
      paste_dimension2 = data[,2]
      for (i in 3:dimension_number){
        paste_dimension2 = paste(paste_dimension2, data[,i], sep="-")
      }
    }
    return (list(paste_dimension1, paste_dimension2))
  }
  ## 4つ以上のディメンションが入力された場合に3つにまとめる処理  
  modify_dimension_number_to_3 = function(data, dimension_number){
    if (dimension_number <= 3) {
      paste_dimension1 = data[,1]
      paste_dimension2 = data[,2]
      paste_dimension3 = data[,3]
    }
    else {
      for (i in 4:dimension_number){
        paste_dimension3 = paste(paste_dimension3, data[,i], sep="-")
      }        
    }
    return (list(paste_dimension1, paste_dimension2, paste_dimension3))
  }
  ########################################################
  ###円グラフ・棒グラフ・面グラフ・折れ線グラフ・散布図###
  ########################################################
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
    data_for_pie_chart[,(dimension_number+1):ncol(data_for_pie_chart)] = round(data_for_pie_chart[,(dimension_number+1):ncol(data_for_pie_chart)],3)
    
    input_graph_type = input$graph_type

   ## 円グラフの処理
    if (input_graph_type == "円グラフ"){
      paste_dimension = modify_dimension_number_to_1(data_for_pie_chart, dimension_number)

      plots = list()
      for (i in 1:(calculated_metrics_number + metrics_number)){
        metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
        tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension = paste_dimension)
        g = ggplot(tmp_data_for_plot, aes(x = "", y = metrics, fill = dimension, label = metrics))
        g = g + geom_bar(width = 1, stat = "identity") + labs(title = metrics_name) + coord_polar("y") + geom_text(aes(x= "", y = metrics, label = metrics), size=6, position = position_stack(vjust = 0.5))
        g = g + theme(plot.title = element_text(size = 25, face = "bold"))
        g = g + scale_fill_brewer(palette = input$color_type)
        plots[[i]] = g
      } 
      return(plots)
    }
    
    ## 棒グラフ1の処理
    if (input_graph_type == "棒グラフ1"){
      if (dimension_number == 1){
        plots = list()
        for (i in 1:(calculated_metrics_number + metrics_number)){
          metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
          tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension = data_for_pie_chart[,1])
          g = ggplot(tmp_data_for_plot, aes(x = dimension, y = metrics, fill = dimension))
          g = g + geom_bar(width = 0.8, stat = "identity") + labs(title = metrics_name)
          g = g + theme(plot.title = element_text(size = 25, face = "bold"))
          g = g + scale_fill_brewer(palette = input$color_type)
          plots[[i]] = g
        } 
        return(plots)
      }
    
      paste_dimension = modify_dimension_number_to_2(data_for_pie_chart, dimension_number)
      
      plots = list()
      for (i in 1:(calculated_metrics_number + metrics_number)){
        metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
        tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension1 = paste_dimension[[1]], dimension2 = paste_dimension[[2]])
        g = ggplot(tmp_data_for_plot, aes(x = dimension1, y = metrics, fill = dimension2))
        g = g + geom_bar(width = 0.8, stat = "identity") + labs(title = metrics_name)
        g = g + theme(plot.title = element_text(size = 25, face = "bold"))
        g = g + scale_fill_brewer(palette = input$color_type)
        plots[[i]] = g
      }
      return(plots)
    }
    
    ## 棒グラフ2の処理
    if (input_graph_type == "棒グラフ2"){
      if (dimension_number == 1){
        plots = list()
        for (i in 1:(calculated_metrics_number + metrics_number)){
          metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
          tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension = data_for_pie_chart[,1])
          g = ggplot(tmp_data_for_plot, aes(x = dimension, y = metrics, fill = dimension))
          g = g + geom_bar(width = 0.8, stat = "identity") + labs(title = metrics_name)
          g = g + theme(plot.title = element_text(size = 25, face = "bold"))
          g = g + scale_fill_brewer(palette = input$color_type)
          plots[[i]] = g
        } 
        return(plots)
      }
      
      paste_dimension = modify_dimension_number_to_2(data_for_pie_chart, dimension_number)

      plots = list()
      for (i in 1:(calculated_metrics_number + metrics_number)){
        metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
        tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension1 = paste_dimension[[1]], dimension2 = paste_dimension[[2]])
        g = ggplot(tmp_data_for_plot, aes(x = dimension1, y = metrics, fill = dimension2))
        g = g + geom_bar(position = "dodge", width = 0.8, stat = "identity") + labs(title = metrics_name)
        g = g + theme(plot.title = element_text(size = 25, face = "bold"))
        g = g + scale_fill_brewer(palette = input$color_type)
        plots[[i]] = g
      }
      return(plots)
    }
    
    ## 折れ線グラフの処理
    if (input_graph_type == "折れ線グラフ"){
      if (dimension_number == 1){
        plots = list()
        for (i in 1:(calculated_metrics_number + metrics_number)){
          metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
          tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension = data_for_pie_chart[,1])
          g = ggplot(tmp_data_for_plot, aes(x = dimension, y = metrics))
          g = g + geom_point() + geom_line(linetype="solid") + labs(title = metrics_name)
          g = g + theme(plot.title = element_text(size = 25, face = "bold"))
          g = g + scale_color_brewer(palette = input$color_type)
          plots[[i]] = g
        } 
        return(plots)
      }

      paste_dimension = modify_dimension_number_to_2(data_for_pie_chart, dimension_number)
      
      plots = list()
      for (i in 1:(calculated_metrics_number + metrics_number)){
        metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
        tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension1 = paste_dimension[[1]], dimension2 = paste_dimension[[2]])
        g = ggplot(tmp_data_for_plot, aes(x = dimension1, y = metrics, color = dimension2))
        g = g + geom_point() + geom_line(linetype="solid") + labs(title = metrics_name)
        g = g + theme(plot.title = element_text(size = 25, face = "bold"))
        g = g + scale_color_brewer(palette = input$color_type)
        plots[[i]] = g
      }
      return(plots)
    }
    
    ## 散布図の処理
    if (input_graph_type == "散布図"){
      if (dimension_number == 1){
        plots = list()
        for (i in 1:(calculated_metrics_number + metrics_number)){
          metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
          tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension = data_for_pie_chart[,1])
          g = ggplot(tmp_data_for_plot, aes(x = dimension, y = metrics))
          g = g + geom_point() + labs(title = metrics_name) #+ geom_text(aes(x= "",y=y,label = metrics), size=3)
          g = g + theme(plot.title = element_text(size = 25, face = "bold"))
          g = g + scale_color_brewer(palette = input$color_type)
          plots[[i]] = g
        } 
        return(plots)
      }
      
      if (dimension_number <= 2){
        paste_dimension1 = data_for_pie_chart[,1]
        paste_dimension2 = data_for_pie_chart[,2]
        plots = list()
        for (i in 1:(calculated_metrics_number + metrics_number)){
          metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
          tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension1 = paste_dimension1, dimension2 = paste_dimension2)
          g = ggplot(tmp_data_for_plot, aes(x = dimension1, y = metrics))
          g = g + geom_point(aes(colour = dimension2)) + labs(title = metrics_name) #+ geom_text(aes(x= "",y=y,label = metrics), size=3)
          g = g + theme(plot.title = element_text(size = 25, face = "bold"))
          g = g + scale_color_brewer(palette = input$color_type)
          plots[[i]] = g
        } 
        return(plots)
      }
      
      paste_dimension = modify_dimension_number_to_3(data_for_pie_chart, dimension_number)
      
      plots = list()
      for (i in 1:(calculated_metrics_number + metrics_number)){
        metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
        tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension1 = paste_dimension[[1]], dimension2 = paste_dimension[[2]], dimension3 = paste_dimension[[3]])
        g = ggplot(tmp_data_for_plot, aes(x = dimension1, y = metrics, colour = dimension2))
        g = g + geom_point(aes(colour = dimension2, shape = dimension3)) + labs(title = metrics_name)
        g = g + theme(plot.title = element_text(size = 25, face = "bold"))
        g = g + scale_color_brewer(palette = input$color_type)
        plots[[i]] = g
      } 
      return(plots)
    }
    
    ## 面グラフの処理
    if (input_graph_type == "面グラフ"){
      if (dimension_number == 1){
        plots = list()
        for (i in 1:(calculated_metrics_number + metrics_number)){
          metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
          tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension = data_for_pie_chart[,1])
          g = ggplot(tmp_data_for_plot, aes(x = dimension, y = metrics))
          g = g + geom_area() + labs(title = metrics_name)
          g = g + theme(plot.title = element_text(size = 25, face = "bold"))
          g = g + scale_fill_brewer(palette = input$color_type)
          plots[[i]] = g
        } 
        return(plots)
      }
      
      paste_dimension = modify_dimension_number_to_2(data_for_pie_chart, dimension_number)
      
      plots = list()
      for (i in 1:(calculated_metrics_number + metrics_number)){
        metrics_name = colnames(data_for_pie_chart)[(dimension_number + i)]
        tmp_data_for_plot = data.frame(metrics = data_for_pie_chart[,(dimension_number + i)], dimension1 = paste_dimension[[1]], dimension2 = paste_dimension[[2]])
        g = ggplot(tmp_data_for_plot, aes(x = dimension1, y = metrics))
        g = g + geom_area(aes(group = dimension2, fill = dimension2)) + labs(title = metrics_name)
        g = g + theme(plot.title = element_text(size = 25, face = "bold"))
        g = g + scale_fill_brewer(palette = input$color_type)
        plots[[i]] = g
      }
      return(plots)
     }
   }
  )
  ######################
  ##グラフ出力例を表示##
  ######################
  output$image_example = renderImage({
    image_src = paste(input$graph_type, ".png", sep="")
    list(src = image_src,
         alt = image_src)
    
  }, deleteFile = FALSE)
  
  output$calc_plot = renderPlot({
    multiplot(plotlist = calc_data_for_plot(), cols = 2)
  })
  ############################
  ##pptx出力するグラフを追加##
  ############################
  graph_output = reactiveValues(z = 0)
  
  observeEvent(input$add_plot, {
    graph_list = list()
    input_graph_title = list()
    
    for (i in 1:(calc_data_for_plot() %>% length)){
      graph_list[[i]] = calc_data_for_plot()[[i]]
      input_graph_title = c(isolate(input_graph_title), input$graph_title)
    }
    graph_output$z = graph_output$z + calc_data_for_plot() %>% length
    graph_output$graph_list = c (graph_output$graph_list, graph_list)
    graph_output$input_graph_title = c (graph_output$input_graph_title, input_graph_title)
  })
  ########################
  ##グラフ追加確認メッセ##
  ########################
  message_after_adding_plot = eventReactive(input$add_plot, {
     paste(input$graph_title, "をパワーポイントに追加しました。いつでもダウンロードできます。もし他にグラフが必要な場合は追加してください。", sep = "")
  })
    
  output$message_for_adding = renderText({
    message_after_adding_plot()
  })
  ########################
  ##pptxダウンロード機能##
  ########################
  output$downloadData = downloadHandler(
    filename = "shiny.pptx",
    content = function(file){

      graph_list = graph_output$graph_list
      input_graph_title = graph_output$input_graph_title
      
      doc = pptx()
      doc = addSlide(doc, "Title Slide")
      doc = addTitle(doc,"Shinyで作ったパワーポイントです")
      doc = addSubtitle(doc, "GAのデータを可視化してみました")
      for (i in 1:(graph_list %>% length)){
        doc = addSlide(doc, "Title and Content")
        doc = addTitle(doc, input_graph_title[[i]])
        doc = addPlot(doc, fun = print, x = graph_list[[i]])  #fun = print, x = 
      }
      writeDoc(doc, file)
    }
  )
})
