#install.packages("rvest", dependencies=T)
#install.packages("dplyr", dependencies=T)
#install.packages("jsonlite", dependencies=T)
#install.packages("stringr", dependencies=T)

library(rvest)
library(dplyr)
library(jsonlite)
library(stringr)
library(magrittr)

basicUrlForP = read_html("http://baseball-data.com/ranking-salary/pa/h.html")
urlListForP = basicUrlForP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
	
basicUrlForC = read_html("http://baseball-data.com/ranking-salary/ce/h.html")
urlListForC = basicUrlForC %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

urlListAll = c(urlListForP, urlListForC)

numberOfPPlayers = urlListForP %>% length
numberOfSClayers = urlListForC %>% length
numberOfAllPlayers = urlListAll %>% length

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
