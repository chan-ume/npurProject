library(shiny)

shinyUI(navbarPage("Shinyサンプルアプリケーション", 
                   tabPanel("Home", 
                            headerPanel("『RとShinyで作るWebアプリケーション』のサンプルアプリケーション"),
                            h2("アプリケーション概要"),
                            p("オープンソースデータを用いて可視化と分析を行えるShinyアプリです。"),
                            helpText("サンプルなので、うまく動かない可能性もあるのでご注意ください。")),
                   
                   tabPanel("Shinyとは?",
                            headerPanel("Shinyでは以下のようなアプリケーションが作成できます。"),
                            sidebarLayout(
                              sidebarPanel(
                                sliderInput("bins_shiny",
                                   "Number of bins:",
                                   min = 1,
                                   max = 50,
                                   value = 30)
                                ),
                              mainPanel(
                                plotOutput("distPlot_shiny")
                              )
                   )),
                   tabPanel("可視化",sidebarLayout(
                     sidebarPanel(
                       selectInput("select_data", label = h3("データセットを選択してください。"), 
                                   choices = list("iris" = 1, "Right heart catheterization dataset" = 2,
                                                  "Data for Titanic passengers" = 3, "Very low birth weight infant" = 4,
                                                  "Boston neighborhood housing prices data" = 5), selected = "1"),
                       numericInput("select_columns_for_hist", label = h3("ヒストグラムプロットするデータ列を指定。"), 
                                 value = "1"),
                       h3("散布図プロットするデータ列を選択。"),
                       numericInput("select_columns_for_scatter_x", label = h4("X軸"), 
                                 value = "1"),
                       numericInput("select_columns_for_scatter_y", label = h4("Y軸"), 
                                 value = "1")
                     ),
                     mainPanel(
                       tabsetPanel(type = "tabs",
                                   tabPanel("Table", DT::dataTableOutput("table")),
                                   tabPanel("ヒストグラム", plotOutput("histPlot")),
                                   tabPanel("散布図", plotOutput("scatterPlot")),
                                   tabPanel("みたいに他にも図を表示する")
                       )
                     ))),
                   tabPanel("回帰", sidebarLayout(
                     sidebarPanel(
                       h2("回帰してみる"),
                       selectInput("select_data_regression", label = h3("データセットを選択してください。"), 
                                   choices = list("iris" = 1, "Right heart catheterization dataset" = 2,
                                                  "Data for Titanic passengers" = 3, "Very low birth weight infant" = 4,
                                                  "Boston neighborhood housing prices data" = 5), selected = "1"),
                       selectInput("select_regression", label = h3("回帰手法を選択する。"), 
                                   choices = list("重回帰分析" = 1, "ランダムフォレスト" = 2,
                                                  "3層ニューラルネット" = 3), selected = "1"),
                       h3("分析対象の列を選択"),
                       numericInput("select_columns_for_regression_x", label = h4("説明変数(「1:4」や「1, 2, 3」などの表記で複数選択可能)"), 
                                    value = "1"),
                       numericInput("select_columns_for_regression_y", label = h4("目的変数"), 
                                    value = "1"),
                       actionButton("regressionButton", "回帰！")
                     ),
                     mainPanel(
                       tabsetPanel(type = "tabs",
                                   tabPanel("プロットで結果を確認", plotOutput("plot_regression")),
                                   tabPanel("みたいな要素を表示する")
                       )))),
                   tabPanel("分類", sidebarLayout(
                     sidebarPanel(
                       h2("分類してみる"),
                       selectInput("select_data_classfication", label = h3("データセットを選択してください。"), 
                                   choices = list("iris" = 1, "Right heart catheterization dataset" = 2,
                                                  "Data for Titanic passengers" = 3, "Very low birth weight infant" = 4,
                                                  "Boston neighborhood housing prices data" = 5), selected = "1"),
                       selectInput("select_classification", label = h3("分類手法を選択する。"), 
                                   choices = list("ロジスティック回帰" = 1, "ランダムフォレスト" = 2,
                                                  "3層ニューラルネット" = 3, "SVM" = 4), selected = "1"),
                       h3("分析対象の列を選択"),
                       numericInput("select_columns_for_classification_x", label = h4("説明変数(「1:4」や「1, 2, 3」などの表記で複数選択可能)"), 
                                    value = "1"),
                       numericInput("select_columns_for_classification_y", label = h4("目的変数"), 
                                    value = "1"),
                       actionButton("classificationButton", "分類！")
                     ),
                     mainPanel(
                       tabsetPanel(type = "tabs",
                                   tabPanel("プロットで結果を確認", plotOutput("plot_classification")),
                                   tabPanel("みたいな要素を表示する")
                       )))),
                   navbarMenu("その他",
                              tabPanel("About",
                                       h2("私の名前はNp-Urです。")
                              ),
                              tabPanel("ソースコード",
                                       a(href="https://github.com/chan-ume", p("https://github.com/chan-ume")))
                   )
))