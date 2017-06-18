#install.packages("rvest", dependencies=T)
#install.packages("dplyr", dependencies=T)
#install.packages("jsonlite", dependencies=T)
#install.packages("stringr", dependencies=T)

library(rvest)
library(dplyr)
library(jsonlite)
library(stringr)
library(magrittr)

# URLの一覧を取得する
basicUrlForP = read_html("http://baseball-data.com/ranking-salary/pa/h.html")
urlListForP = basicUrlForP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
	
basicUrlForC = read_html("http://baseball-data.com/ranking-salary/ce/h.html")
urlListForC = basicUrlForC %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

urlListAll = c(urlListForP, urlListForC)

numberOfPPlayers = urlListForP %>% length
numberOfSClayers = urlListForC %>% length
numberOfAllPlayers = urlListAll %>% length

## データを取得してまとめる
playerInformationAndRecordAll = c()
for (i in 1:numberOfAllPlayers){
  tmphtml = read_html(urlListAll[i])
  recordList = tmphtml %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//tr")
  numberOfRecordList = recordList %>% length
  for (j in 1:numberOfRecordList){
    if(identical(grep("<td style=\"text-align:center;\">2016",recordList[j]), integer(0))){next}
    lastYearRecord = recordList[j] %>%  html_nodes("td") %>% html_text() %>% as.vector()
    playerInformation = tmphtml %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@class='player-info']//td") %>% html_text() %>% as.vector()
    playerInformationAndRecord = c(playerInformation, lastYearRecord) %>% as.matrix()
  }
  playerInformationAndRecordAll = cbind(playerInformationAndRecordAll, playerInformationAndRecord)
}

# データを整形する
tableHead1 = tmphtml %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@class='player-info']//th") %>% html_text() %>% as.vector()
tableHead2 = tmphtml %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']//th") %>% html_text() %>% as.vector()
colnames(playerInformationAndRecordAll) = c(tableHead1,tableHead2)

# 必要なデータのみ使う
dataForLinearRegression = playerInformationAndRecordAll[,c("球団","ポジション","年齢","年俸","試合","打席数","打数","得点","安打","二塁打","三塁打","本塁打","塁打","打点","盗塁","盗塁刺","犠打","犠飛","四球","死球","三振","併殺打","打率","長打率","出塁率","OPS")]

# 不要な部分を削除する
dataForLinearRegression[,"年齢"] = gsub("歳","",dataForLinearRegression[,"年齢"])
dataForLinearRegression[,"年俸"] = gsub("万円（推定）","",dataForLinearRegression[,"年俸"])
dataForLinearRegression[,"年俸"] = gsub(",","",dataForLinearRegression[,"年俸"])

dataForLinearRegression[,3:ncol(dataForLinearRegression)] = 

data = as.data.frame(dataForLinearRegression)
result = lm(data[,4]~data[,-4],data=data)	

y = data[,4]
x = data[,-4]

lm(y~x)
data = c()
for (i in 3:ncol(dataForLinearRegression)){
  data = cbind(data, as.numeric(dataForLinearRegression[,i]))
}
colnames(data) = c("年齢","年俸","試合","打席数","打数","得点","安打","二塁打","三塁打","本塁打","塁打","打点","盗塁","盗塁刺","犠打","犠飛","四球","死球","三振","併殺打","打率","長打率","出塁率","OPS")
Y = data[,2]
X = data[,-2]
Category = as.factor(dataForLinearRegression[,1:2])

result = lm(Y~X+as.factor(dataForLinearRegression[,1])+as.factor(dataForLinearRegression[,2]))	
