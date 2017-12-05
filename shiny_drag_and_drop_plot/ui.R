library(shiny)

shinyUI(
  fluidPage(
    tags$head(tags$link(rel = "stylesheet", href = "styles.css", type = "text/css"),
              tags$script(src = "getdata3.js")),
    sidebarLayout(
      sidebarPanel(
        h2("赤枠にデータをドロップ"),
        div(id="drop-area", ondragover = "f1(event)", ondrop = "f2(event)"),
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
