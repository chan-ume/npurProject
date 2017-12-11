library(shiny)

server = function(input, output, session) {
  observeEvent(input$imgfile, {
    
    output$image = renderUI({ 
      img(src = input$imgfile, alt=input$imgfile)
    })
  })
}
