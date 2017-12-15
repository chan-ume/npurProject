library(shiny)

shinyUI(
  fluidPage(
    sidebarLayout(
      sidebarPanel(
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
        actionButton("submit", "プロット")
      ),
      mainPanel(
        tabsetPanel(type = "tabs",
                    tabPanel("Table", tableOutput('table')),
                    tabPanel("Plot", plotOutput("plot"))
        )
      )
    )
  )
)
