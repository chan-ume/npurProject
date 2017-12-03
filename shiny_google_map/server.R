library(shiny)
library(leaflet)
library(ggmap)

shinyServer(function(input, output) {
  
  values = reactiveValues(geocodes = rbind(c(139.6917, 35.68949), c(140.1233, 35.60506)))
    
  observeEvent(input$submit, {
    geo1 = geocode(input$search_word1)
    geo2 = geocode(input$search_word2)
    
    if(is.na(geo1[1,1])){
      geo1[1,] = values$geocodes[1,]
    }
    
    if(is.na(geo2[1,1])){
      geo2[1,] = values$geocodes[2,]
    }
    
    values$geocodes = rbind(geo1, geo2)
  })
  
  output$plot = renderLeaflet({

    geo1_lng = values$geocodes[1,1]
    geo1_lat = values$geocodes[1,2]
    geo2_lng = values$geocodes[2,1]
    geo2_lat = values$geocodes[2,2]

    map_data = leaflet() %>% 
      addTiles() %>%
      setView(lng = (geo1_lng + geo2_lng)/2,
              lat = (geo1_lat + geo2_lat)/2, zoom = 10) %>%
      addMarkers(lng = geo1_lng, lat = geo1_lat,
                 label = input$search_word1) %>%
      addMarkers(lng = geo2_lng, lat = geo2_lat,
                 label = input$search_word2) %>%
      addMeasure(position = "topright", primaryLengthUnit = "meters", 
                 primaryAreaUnit = "sqmeters", activeColor = "#3D535D",
                 completedColor = "#7D4479")
    return(map_data)
  })
})
