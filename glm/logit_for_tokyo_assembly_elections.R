## インストールがまだの場合は下記のコメントを外してそれぞれインストール
#install.packages("rvest", dependencies=T)
#install.packages("dplyr", dependencies=T)
#install.packages("jsonlite", dependencies=T)
#install.packages("stringr", dependencies=T)
#install.packages("magrittr", dependencies=T)

# ライブラリの読み込み
library(rvest)
library(dplyr)
library(jsonlite)
library(stringr)
library(magrittr)

## 候補者の属性データを取得

# 対象サイトを読み込み
basicUrl = read_html("http://www.tokyo-np.co.jp/senkyo/togisen2017/tod/tod_touha.html")
# 選挙区別立候補者URLを取得
candidateInfoUrlList = basicUrl %>% html_nodes(xpath = "//ul[@class='clearfix']//a") %>% html_attr("href")

# 属性データを格納するハコを用意
nameInfoList = c()
partyInfoList = c()
newOrOldInfoList = c()
winCountInfoList = c()

for (i in 1:(urlList %>% length)){
  Sys.sleep(3)
  tmpHtml = read_html(paste("http://www.tokyo-np.co.jp", candidateInfoUrlList[i], sep=""))
  tmpnameInfoList = tmpHtml %>% html_nodes(xpath = "//li[@class='name']") %>% html_text()
  tmppartyInfoList = tmpHtml %>% html_nodes(xpath = "//li[@class='shozoku']")%>% html_text()
  tmpnewOrOldInfoList = tmpHtml %>% html_nodes(xpath = "//li[@class='sinkyu']")%>% html_text()
  tmpwinCountInfoList = tmpHtml %>% html_nodes(xpath = "//li[@class='kaisu']")%>% html_text()
  # 属性データをハコに追加
  nameInfoList = c(nameInfoList, tmpnameInfoList)
  partyInfoList = c(partyInfoList, tmppartyInfoList)
  newOrOldInfoList = c(newOrOldInfoList, tmpnewOrOldInfoList)
  winCountInfoList = c(winCountInfoList, tmpwinCountInfoList)
}
# 取得した各属性データを一つにまとめる
candidateInfo = cbind(nameInfoList, partyInfoList, newOrOldInfoList, winCountInfoList)
# 年齢のデータを追加
candidateInfo = cbind(0,candidateInfo, str_match(candidateInfo[,1],"(.*)（.*）$")[,2]%>% str_replace_all("　| ",""), str_match(candidateInfo[,1],".*（(.*)）$")[,2])

# 当選情報を取得する
# 当選情報のURLリストを取得
winningInfoUrlList = read_html("http://www.asahi.com/senkyo/togisen/2017/kaihyo/") %>% html_nodes(xpath = "//div[@id='SubLink2']/ul/li/a") %>% html_attr("href")

# 当選情報を格納するハコを用意
nameList = c() 
WinOrLoss = c()

for(i in 1:length(winningInfoUrlList)){
  Sys.sleep(3)
  tmpUrl = paste("http://www.asahi.com",winningInfoUrlList[i],sep="")
  tmpname = read_html(tmpUrl) %>% html_nodes(xpath="//table[@class='SnkTbl01']/tbody/tr/td[@class='Name']") %>% html_text()
  tmpWinOrLoss = read_html(tmpUrl) %>% html_nodes(xpath="//table[@class='SnkTbl01']/tbody/tr/td[@class='Rose']") %>% html_text()
 
   # 当選情報をハコに追加
  nameList = c(nameList, tmpname)
  WinOrLoss = c(WinOrLoss,tmpWinOrLoss)  
}
# 取得したデータを一つにまとめる
nameAndWinOrLoss = cbind(nameList,WinOrLoss)
WinList = subset(nameAndWinOrLoss, nameAndWinOrLoss[,2]=="")[,1] %>% str_replace_all("　| ","")

# 当選リストに含まれる候補者データの1列目に'1'を代入する，落選者は'0'のまま
candidateInfo[candidateInfo[,6] %in% WinList,1] = 1

p = as.numeric(candidateInfo[,1])
age = as.numeric(candidateInfo[,7])
numberOfWinning = as.numeric(candidateInfo[,5])

result = glm(p ~ age + numberOfWinning + candidateInfo[,3] + candidateInfo[,4], family=binomial(link="logit"))
summary(result)
step(result)
