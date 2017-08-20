library(shiny)
library(googleAuthR)
library(googleAnalyticsR)
library(listviewer)
library(ggplot2)
library(gridExtra)
library(Rmisc)

navbarPage("疑似Google Data Studio",
           tabPanel("Google アカウント連携", tabName = "setup", icon = icon("cogs"),
                    h1("Setup"),
                    googleAuthUI("Google_login"),
                    authDropdownUI("viewId_select")
           ),
           tabPanel("metricsとdimention指定", tabName = "calc_metrics", icon = icon("calculator"),
                    h2("Calculated Metrics"),
                    fluidRow(
                      column(width = 6,
                             textInput("calculated_name", label = "Calculated Name", value = "Sessions Per Pageview")
                      ),
                      column(width = 6,
                             textInput("calculated_exp", label = "Calculated Expression", value = "ga:sessions / ga:pageviews")   
                      )
                    ),
                    fluidRow(
                      column(width = 6,
                             multi_selectUI("metrics_calc", "Normal Metrics")     
                      ),
                      column(width = 6,
                             multi_selectUI("dimensions_calc", "Dimensions")  
                      )
                    ),
                    fluidRow(
                      column(width = 6,
                             dateRangeInput("date_clac", "Date Range") 
                      ),
                      column(width = 6,
                             br()
                      )
                    ),
                    helpText("Calculated Metricsのところは適当なmetrics同士を計算させることができます"),
                    h2("表出力"),
                    actionButton("get_calc", "Calculated Metric dataを取得！", icon = icon("download"), class = "btn-success"),
                    hr(),
                    dataTableOutput("calc_table"),
                    h2("グラフ出力"),
                    fluidRow(
                      column(width = 3,
                        selectInput("graph_type", 
                                label = "出力したいグラフの種類を選んでください。右にグラフ例が出力されます。",
                                choices = c("円グラフ", "棒グラフ1", "棒グラフ2", "折れ線グラフ",
                                            "散布図", "面グラフ"),
                                selected = "円グラフ")),
                      column(width = 6, 
                        h3("画像出力例"),
                        imageOutput("image_example"))
                    ),
                    actionButton("get_plot", "グラフを出力", icon = icon("download"), class = "btn-success"),
                    plotOutput("calc_plot")
           )
)
