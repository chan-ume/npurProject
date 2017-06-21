## インストールがまだの場合は下記のコメントを外してそれぞれインストール
#install.packages("rvest", dependencies=T)
#install.packages("dplyr", dependencies=T)
#install.packages("jsonlite", dependencies=T)
#install.packages("stringr", dependencies=T)
#install.packages("wle", dependencies=T)

# ライブラリの読み込み
library(dplyr)
library(jsonlite)
library(stringr)
library(magrittr)
library(data.table)
# rvestライブラリを使って各球団の選手情報を持つURLを取得する
#　広島の野手データのあるページを取得
cURLforH = read_html("http://baseball-data.com/ranking-salary/c/h.html")
#　広島の投手データのあるページを取得
cURLforP = read_html("http://baseball-data.com/ranking-salary/c/p.html")
# 2秒停止
Sys.sleep(2)
# 広島の野手のURLを一覧で取得
urlListForCH = cURLforH %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
# 広島の投手のURLを一覧で取得
urlListForCP = cURLforP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

#　巨人のデータ
gURLforH = read_html("http://baseball-data.com/ranking-salary/g/h.html")
gURLforP = read_html("http://baseball-data.com/ranking-salary/g/p.html")
Sys.sleep(2)
urlListForGH = gURLforH %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
urlListForGP = gURLforP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

# 横浜のデータ
ybURLforH = read_html("http://baseball-data.com/ranking-salary/yb/h.html")
ybURLforP = read_html("http://baseball-data.com/ranking-salary/yb/p.html")
Sys.sleep(2)
urlListForYbH = ybURLforH %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
urlListForYbP = ybURLforP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

# 阪神のデータ
tURLforH = read_html("http://baseball-data.com/ranking-salary/t/h.html")
tURLforP = read_html("http://baseball-data.com/ranking-salary/t/p.html")
Sys.sleep(2)
urlListForTH = tURLforH %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
urlListForTP = tURLforP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

# ヤクルトのデータ
sURLforH = read_html("http://baseball-data.com/ranking-salary/s/h.html")
sURLforP = read_html("http://baseball-data.com/ranking-salary/s/p.html")
Sys.sleep(2)
urlListForSH = sURLforH %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
urlListForSP = sURLforP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

# 中日のデータ
dURLforH = read_html("http://baseball-data.com/ranking-salary/g/h.html")
dURLforP = read_html("http://baseball-data.com/ranking-salary/g/p.html")
Sys.sleep(2)
urlListForDH = dURLforH %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
urlListForDP = dURLforP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

# 日本ハムのデータ
fURLforH = read_html("http://baseball-data.com/ranking-salary/f/h.html")
fURLforP = read_html("http://baseball-data.com/ranking-salary/f/p.html")
Sys.sleep(2)
urlListForFH = fURLforH %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
urlListForFP = fURLforP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

# ソフトバンクのデータ
hURLforH = read_html("http://baseball-data.com/ranking-salary/h/h.html")
hURLforP = read_html("http://baseball-data.com/ranking-salary/h/p.html")
Sys.sleep(2)
urlListForHH = hURLforH %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
urlListForHP = hURLforP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

# ロッテのデータ
mURLforH = read_html("http://baseball-data.com/ranking-salary/m/h.html")
mURLforP = read_html("http://baseball-data.com/ranking-salary/m/p.html")
Sys.sleep(2)
urlListForMH = mURLforH %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
urlListForMP = mURLforP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

# 楽天のデータ
eURLforH = read_html("http://baseball-data.com/ranking-salary/e/h.html")
eURLforP = read_html("http://baseball-data.com/ranking-salary/e/p.html")
Sys.sleep(2)
urlListForEH = eURLforH %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
urlListForEP = eURLforP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

# 西武のデータ
lURLforH = read_html("http://baseball-data.com/ranking-salary/l/h.html")
lURLforP = read_html("http://baseball-data.com/ranking-salary/l/p.html")
Sys.sleep(2)
urlListForLH = lURLforH %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
urlListForLP = lURLforP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

# オリックスのデータ
bsURLforH = read_html("http://baseball-data.com/ranking-salary/bs/h.html")
bsRLforP = read_html("http://baseball-data.com/ranking-salary/bs/p.html")
Sys.sleep(2)
urlListForBsH = bsURLforH %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
urlListForBsP = bsRLforP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

# 野手のデータをまとめる
urlListAllH = c (urlListForCH, urlListForGH,urlListForYbH,urlListForTH,urlListForSH,urlListForDH, urlListForFH, urlListForHH,urlListForMH, urlListForEH, urlListForLH,urlListForBsH)
# 投手のデータをまとめる
urlListAllP = c (urlListForCP, urlListForGP,urlListForYbP,urlListForTP,urlListForSP,urlListForDP, urlListForFP, urlListForHP,urlListForMP, urlListForEP, urlListForLP,urlListForBsP)

# 野手データの人数
numberOfAllHPlayers = urlListAllH %>% length
# 投手データの人数
numberOfAllPPlayers = urlListAllP %>% length

## 先ほどまとめた野手URLから，それぞれ2016年の成績を取得
playerInformationAndRecordAll = c()
for (i in 1:numberOfAllHPlayers){
  tmphtml = read_html(urlListAllH[i])
  recordList = tmphtml %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//tr")
  numberOfRecordList = recordList %>% length
  for (j in 1:numberOfRecordList){
    if(identical(grep("<td style=\"text-align:center;\">2016",recordList[j]), integer(0))){next}
    lastYearRecord = recordList[j] %>%  html_nodes("td") %>% html_text() %>% as.vector()
    playerName = tmphtml %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/h2[@class='pname']") %>% html_text()
    playerInformation = tmphtml %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@class='player-info']//td") %>% html_text() %>% as.vector()
    playerInformationAndRecord = c(playerName, playerInformation, lastYearRecord) %>% as.matrix()
  }
  # 2016年のデータが無い場合はスキップする
  if (!is.null(playerInformationAndRecord)){
    playerInformationAndRecordAll = cbind(playerInformationAndRecordAll, playerInformationAndRecord)
    Sys.sleep(2)
  }
}
HplayerInformationAndRecordAll = t( playerInformationAndRecordAll)

## 先ほどまとめた投手URLから，それぞれ2016年の成績を取得
## 本当は関数にしてまとめたいところ，コピペ良くない……
playerInformationAndRecordAll = c()
for (i in 1:numberOfAllPPlayers){
  tmphtml = read_html(urlListAllP[i])
  recordList = tmphtml %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//tr")
  numberOfRecordList = recordList %>% length
  for (j in 1:numberOfRecordList){
    playerInformationAndRecord = c() 
    if(identical(grep("<td style=\"text-align:center;\">2016",recordList[j]), integer(0))){next}
    lastYearRecord = recordList[j] %>%  html_nodes("td") %>% html_text() %>% as.vector()
    playerName = tmphtml %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/h2[@class='pname']") %>% html_text()
    playerInformation = tmphtml %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@class='player-info']//td") %>% html_text() %>% as.vector()
    playerInformationAndRecord = c(playerName, playerInformation, lastYearRecord) %>% as.matrix()
  }
  if (!is.null(playerInformationAndRecord)){
    playerInformationAndRecordAll = cbind(playerInformationAndRecordAll, playerInformationAndRecord)
    Sys.sleep(2)
  }
}
PplayerInformationAndRecordAll = t( playerInformationAndRecordAll)

# データを整形する 
# データのヘッダー部分を取得する
HtableHead1 = read_html(urlListAllH[1]) %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@class='player-info']//th") %>% html_text() %>% as.vector()
HtableHead2 = read_html(urlListAllH[1])%>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']//th") %>% html_text() %>% as.vector()

Sys.sleep(2)
PtableHead1 = read_html(urlListAllP[1]) %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@class='player-info']//th") %>% html_text() %>% as.vector()
PtableHead2 = read_html(urlListAllP[1])%>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']//th") %>% html_text() %>% as.vector()

colnames(PplayerInformationAndRecordAll) = c(PtableHead1,PtableHead2)
colnames(HplayerInformationAndRecordAll) = c(HtableHead1,HtableHead2)

# データを保存したい場合コメントを外す
#write.csv(PplayerInformationAndRecordAll, "PplayerInformationAndRecordAll.csv")
#write.csv(HplayerInformationAndRecordAll, "HplayerInformationAndRecordAll.csv")

# うえで保存したデータを読み込みたい場合はコメントを外す
#HplayerInformationAndRecordAll = fread("HplayerInformationAndRecordAll.csv", encoding="UTF-8")
#PplayerInformationAndRecordAll = fread("PplayerInformationAndRecordAll.csv", encoding="UTF-8")
#HplayerInformationAndRecordAll = HplayerInformationAndRecordAll[,-1]
#PplayerInformationAndRecordAll = PplayerInformationAndRecordAll[,-1]
# もし重複がとれてしまった場合はコメントを外して重複削除を行う
#PplayerInformationAndRecordAll= PplayerInformationAndRecordAll[!duplicated(PplayerInformationAndRecordAll$名前), ]
#HplayerInformationAndRecordAll = HplayerInformationAndRecordAll [!duplicated(HplayerInformationAndRecordAll$名前), ]

# 必要なデータのみ使う
# 年棒と関係なさそうなデータは省いている
dataForLinearRegressionH = HplayerInformationAndRecordAll[,c("球団","ポジション","年齢","年俸","試合","打席数","打数","得点","安打","二塁打","三塁打","本塁打","塁打","打点","盗塁","盗塁刺","犠打","犠飛","四球","死球","三振","併殺打","打率","長打率","出塁率","OPS")]
dataForLinearRegressionP = PplayerInformationAndRecordAll[,c("球団","年齢","年俸","試合","勝利","敗北","セlブ","完投","完封勝","無四球","打者","投球回","被安打","被本塁打","与四球","与死球","奪三振","暴投","ボlク","失点","自責点","防御率","WHIP")]
dataForLinearRegressionH = as.matrix(dataForLinearRegressionH)
dataForLinearRegressionP = as.matrix(dataForLinearRegressionP)

# 不要な部分を削除する(「歳」とか「万円」とか)
## コピペ良くない…
dataForLinearRegressionH[,"年齢"] = gsub("歳","",dataForLinearRegressionH[,"年齢"])
dataForLinearRegressionH[,"年俸"] = gsub("万円（推定）","",dataForLinearRegressionH[,"年俸"])
dataForLinearRegressionH[,"年俸"] = gsub(",","",dataForLinearRegressionH[,"年俸"])
dataForLinearRegressionP[,"年齢"] = gsub("歳","",dataForLinearRegressionP[,"年齢"])
dataForLinearRegressionP[,"年俸"] = gsub("万円（推定）","",dataForLinearRegressionP[,"年俸"])
dataForLinearRegressionP[,"年俸"] = gsub(",","",dataForLinearRegressionP[,"年俸"])

# 線形回帰用のデータにする
## これをしないと数値として処理してくれず，文字列と認識されてしまったので
## もっと良い方法あったら教えてほしい
dataH = c()
for (i in 3:ncol(dataForLinearRegressionH)){
  dataH = cbind(dataH, as.numeric(dataForLinearRegressionH[,i]))
}
colnames(dataH) = c("年齢","年俸","試合","打席数","打数","得点","安打","二塁打","三塁打","本塁打","塁打","打点","盗塁","盗塁刺","犠打","犠飛","四球","死球","三振","併殺打","打率","長打率","出塁率","OPS")
Yh = dataH[,2]
Xh= dataH[,-2]
# パリーグセリーグに分けるなら…
#dataHCe= dataH[1:117,]
#dataHPa= dataH[118:nrow(dataH),]

# やっと線形回帰
resultH = lm(Yh ~ Xh+as.factor(dataForLinearRegressionH[,1])+as.factor(dataForLinearRegressionH[,2]))
# 対数正規分布を仮定して一般化線形回帰（GLM）
resultHglm = glm(Yh ~ Xh+as.factor(dataForLinearRegressionH[,1])+as.factor(dataForLinearRegressionH[,2]),family = gaussian(link = "log"))

## コピペ良くない…
dataP = c()
for (i in 2:ncol(dataForLinearRegressionP)){
  dataP = cbind(dataP, as.numeric(dataForLinearRegressionP[,i]))
}
colnames(dataP) = c("年齢","年俸","試合","勝利","敗北","セlブ","完投","完封勝","無四球","打者","投球回","被安打","被本塁打","与四球","与死球","奪三振","暴投","ボlク","失点","自責点","防御率","WHIP")
Yp = dataP[,2]
Xp = dataP[,-2]

# 線形回帰
resultP = lm(Yp ~ Xp+as.factor(dataForLinearRegressionP[,1]))
# 対数正規分布を仮定して一般化線形回帰（GLM）
resultPglm = glm(Yp ~ Xp+as.factor(dataForLinearRegressionP[,1]),family = gaussian(link = "log"))

# 残差（推定値との差）を取得して、選手名を付け加える
# その後昇順に並べる
# 推定値との差を取った時に，小さい順からならべたもの
# 前半は，推定値（本来このぐらいもらっているだろう値）よりも低い人が並ぶ，つまり「もっと貰って良い人」
# 後半は，推定値（本来このぐらいもらっているだろう値）よりも高い人が並ぶ，つまり「貰いすぎじゃない？な人」
residualsP = residuals(resultP)
residualsPWithName = cbind(PplayerInformationAndRecordAll[,1], residualsP)
orderedResidualsPWithName = residualsPWithName[order(residualsPWithName[,2]),]

residualsH = residuals(resultH)
residualsHWithName = cbind(HplayerInformationAndRecordAll[,1], residualsH)
orderedResidualsHWithName = residualsHWithName[order(residualsHWithName[,2]),]

# 一般化線形回帰（GLM）をした場合の残差を取得
residualsHglm = residuals(resultHglm)
residualsPglm = residuals(resultPglm)
residualsglmPWithName = cbind(PplayerInformationAndRecordAll[,1], residualsPglm)
residualsglmHWithName = cbind(HplayerInformationAndRecordAll[,1], residualsHglm)
orderedResidualsglmPWithName = residualsglmPWithName[order(residualsglmPWithName[,2]),]
orderedResidualsglmHWithName = residualsglmHWithName[order(residualsglmHWithName[,2]),]
# 残差を保存したい場合は以下のコメントを外す
#write.csv(orderedResidualsPWithName,"orderedResidualsPWithName.csv")
#write.csv(orderedResidualsHWithName ,"orderedResidualsHWithName.csv")
