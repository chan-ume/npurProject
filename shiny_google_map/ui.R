library(shiny)
library(leaflet)
library(ggmap)

shinyUI(fluidPage(
  titlePanel("Google Mapを描写"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("search_word1", "ワード1", value="東京"),
      textInput("search_word2", "ワード2", value="千葉"),
       
      h4("実行に数秒時間がかかります。"),
      h4("また、Gmap APIがエラーを返す場合があります"),
      actionButton("submit", "地図を描写")
    ),
    mainPanel(
      leafletOutput("plot", width="100%", height = "900px")
    )
  )
))
