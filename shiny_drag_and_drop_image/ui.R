library(shiny)

shinyUI(
  fluidPage(
    tags$head(tags$link(rel = "stylesheet", href = "style.css", type = "text/css"),
              tags$script(src = "drag_and_drop.js")),
    sidebarLayout(
      sidebarPanel(
        h2("赤枠に画像ファイルをドロップ"),
        div(id="drop-area", ondragover = "f1(event)", ondrop = "f2(event)")
      ),
      mainPanel(
        htmlOutput("image")
      )
    )
  )
)
