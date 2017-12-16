library(shiny)

shinyUI(fluidPage(
  sidebarPanel(
    h2("クラスタリング"),
    fileInput("file", "Choose CSV File",
              accept = c(
                "text/csv",
                "text/comma-separated-values,text/plain",
                ".csv")
    ),
    tags$hr(),
    h2("プロットするデータを選択"),
    htmlOutput("colname1"),
    htmlOutput("colname2"),
    selectInput("clustering_method", "クラスタリングの種類", 
                c("階層的（complete）" = "hclust", "非階層的（k-means）" = "k-means")),
    numericInput("number", "何個のクラスターに分類？", 5,
                 min = 1, max = 20),
    actionButton("submit", "プロット")
  ),
  mainPanel(
    tabsetPanel(type = "tabs",
                tabPanel("Table", tableOutput('table')),
                tabPanel("Plot", plotOutput("plot"))
    )
  )
))
