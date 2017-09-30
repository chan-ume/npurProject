library(rtweet)
library(tm)
library(RMeCab)
library(dplyr)
library(purrr)
library(magrittr)
library(randomForest)
library(rpart)
library(kernlab)
library(stringr)
library(rvest)
library("rpart.plot")
library("wordcloud")

CONSUMERKEY = "XXXXXXXX"
CONSUMERSECRET = "XXXXXXXX"
APPNAME = "XXXXXXXX"

twitter_token = create_token(
  app = APPNAME,
  consumer_key = CONSUMERKEY,
  consumer_secret = CONSUMERSECRET
)

mehara_home_timeline = get_timeline("maehara2016", n = 100, home = TRUE, token = twitter_token)
mehara_home_timeline_texts = mehara_home_timeline$text

mehara_home_timeline_texts_onlyJa = str_replace_all(mehara_home_timeline_texts, "\\p{ASCII}", "")
mehara_home_timeline_texts_onlyJa_shiftJis = mehara_home_timeline_texts_onlyJa %>% iconv(from = "UTF-8", to = "CP932") %>% na.omit()

mehara_home_tweets_all = ""
for (i in 1:length((mehara_home_timeline_texts_onlyJa_shiftJis))){
  mehara_home_tweets_all = paste(mehara_home_tweets_all, mehara_home_timeline_texts_onlyJa_shiftJis[i], seq = "")
}
write.table(mehara_home_tweets_all, "mehara_home_tweets_all.txt")

docDF_mehara = docDF("mehara_home_tweets_all.txt", type = 1)
docDF_mehara2 = docDF_mehara %>% filter(POS1 %in% c("名詞"), POS2 != "非自立") 

wordcloud(docDF_mehara2$TERM,docDF_mehara2$mehara_home_tweets_all.txt, min.freq= 3, scale=c(6,1), family ="JP1"
          , colors = brewer.pal(8,"Dark2"))
