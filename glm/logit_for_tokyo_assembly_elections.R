library(rvest)
library(dplyr)
library(jsonlite)
library(stringr)
library(magrittr)
library(data.table)

basicUrl = read_html("http://www.tokyo-np.co.jp/senkyo/togisen2017/tod/tod_touha.html")
urlList = basicUrl %>% html_nodes(xpath = "//ul[@class='clearfix']//a") %>% html_attr("href")

numberOfPlace = urlList %>% length

nameInfoList = c()
careerInfoList = c()
partyInfoList = c()
recommendationInfoList = c()
newOrOldInfoList = c()
winCountInfoList = c()

for (i in 1:numberOfPlace){
  Sys.sleep(3)
  tmpHtml = read_html(paste("http://www.tokyo-np.co.jp", urlList[i], sep=""))
  tmpnameInfoList = tmpHtml %>% html_nodes(xpath = "//li[@class='name']") %>% html_text()
  tmpcareerInfoList = tmpHtml %>% html_nodes(xpath = "//li[@class='keireki']")%>% html_text()
  tmppartyInfoList = tmpHtml %>% html_nodes(xpath = "//li[@class='shozoku']")%>% html_text()
  tmprecommendationInfoList = tmpHtml %>% html_nodes(xpath = "//li[@class='suisen']")%>% html_text()
  tmpnewOrOldInfoList = tmpHtml %>% html_nodes(xpath = "//li[@class='sinkyu']")%>% html_text()
  tmpwinCountInfoList = tmpHtml %>% html_nodes(xpath = "//li[@class='kaisu']")%>% html_text()

  nameInfoList = c(nameInfoList, tmpnameInfoList)
  careerInfoList = c(careerInfoList, tmpcareerInfoList)
  partyInfoList = c(partyInfoList, tmppartyInfoList)
  recommendationInfoList = c(recommendationInfoList, tmprecommendationInfoList)
  newOrOldInfoList = c(newOrOldInfoList, tmpnewOrOldInfoList)
  winCountInfoList = c(winCountInfoList, tmpwinCountInfoList)
}

candidateInfo = cbind(nameInfoList, careerInfoList, partyInfoList, recommendationInfoList, newOrOldInfoList, winCountInfoList)
candidateInfo = cbind(candidateInfo, str_match(candidateInfo[,1],".*（(.*)）$")[,2])

urlForWinning = read_html("http://komatsudayohei.jp/seijitosyakaijosei/22055/")
winningCandidateInfoDiv = urlForWinning %>% html_nodes(xpath = "/html[@class='col2']/body[@class='single single-post postid-22055 single-format-standard']/div[@class='container']/div[@class='main-body']/div[@class='main-body-in']/main/div[@class='main-conts']/article[@id='post-22055']/div[@class='section-in']/div[@class='article-body']/div[2]")

str_match(winningCandidataInfo,"(.*)（.*\n")

winningCandidataInfo = ""
for (i in 2:13){
 p_i = paste("p[",i,"]", sep="") 
 tmp = winningCandidateInfoDiv %>% html_nodes(xpath=p_i) %>% html_text()
 winningCandidataInfo = paste(winningCandidataInfo,tmp)
}

str_match(winningCandidataInfo,"^(.*)（.*\n")

b = str_split(winningCandidataInfo, "票|\n")[[1]] %>% str_match("^(.*)[：].*$") %>% na.omit()
c = b[,2]
d = str_split(c, "（")
b = str_split(winningCandidataInfo, "票|\n")[[1]] %>% str_replace_all("　| ","")


name_only = str_match(candidateInfo[,1],"^(.*)（.*")[,2] %>% str_replace_all("　| ","")

winningList = c()
for (i in 1:length(name_only)){
  if(identical(grep(name_only[i],b),integer(0))){
    winningOrLose = 0
  }
  else{
    winningOrLose = 1
  }
  winningList = c(winningList,winningOrLose)
}

candidateInfo = cbind(candidateInfo,winningList)


urlForCandidateList = read_html("http://www.asahi.com/senkyo/togisen/2017/kaihyo/") %>% html_nodes(xpath = "//div[@id='SubLink2']/ul/li/a") %>% html_attr("href")
nameList = c() 
WinOrLoss = c()
for(i in 1:length(urlForCandidateList)){
  tmpUrl = paste("http://www.asahi.com",urlForCandidateList[i],sep="")
  tmpname = read_html(tmpUrl) %>% html_nodes(xpath="//table[@class='SnkTbl01']/tbody/tr/td[@class='Name']") %>% html_text()
  tmpWinOrLoss = read_html(tmpUrl) %>% html_nodes(xpath="//table[@class='SnkTbl01']/tbody/tr/td[@class='Rose']") %>% html_text()

  nameList = c(nameList, tmpname)
  WinOrLoss = c(WinOrLoss,tmpWinOrLoss)  
}
