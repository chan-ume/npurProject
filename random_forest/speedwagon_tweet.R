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

## twitter token
CONSUMERKEY = "XXXXXXXXXXXXXXXXXXX"
CONSUMERSECRET = "XXXXXXXXXXXXXXXXXXX"
APPNAME = "XXXXXXXXXXXXXXXXXXX"

twitter_token = create_token(
  app = APPNAME,
  consumer_key = CONSUMERKEY,
  consumer_secret = CONSUMERSECRET
)
## get twitter
Itoda_account = "junjunitojun"
Ozawa_account = "ozwspw"

Itoda_tweets = get_timeline(Itoda_account, n = 10000, token = twitter_token, include_rts = FALSE)
Ozawa_tweets = get_timeline(Ozawa_account, n = 10000, token = twitter_token, include_rts = FALSE)

Itoda_tweets_texts = Itoda_tweets$text
Ozawa_tweets_texts = Ozawa_tweets$text

Itoda_tweets_texts_onlyJa = str_replace_all(Itoda_tweets_texts, "\\p{ASCII}", "") %>% iconv(from = "UTF-8", to = "CP932") %>% na.omit()
Ozawa_tweets_texts_onlyJa = str_replace_all(Ozawa_tweets_texts, "\\p{ASCII}", "") %>% iconv(from = "UTF-8", to = "CP932") %>% na.omit()

text_all = c(Itoda_tweets_texts_onlyJa, Ozawa_tweets_texts_onlyJa)
text_all = as.data.frame(text_all)

## morphological analysis
doc_matrix = docDF(text_all, col = 1, type = 1, pos = c("名詞", "形容詞"), minFreq = 3, weight = "tf*idf*norm")
doc_matrix = doc_matrix %>% filter(POS2 %in% c("一般", "固有名詞","自立"))

doc_matrix_tfidf = doc_matrix[,4:ncol(doc_matrix)]
doc_matrix_t = doc_matrix_tfidf %>% t()

rownames(doc_matrix_t) = c(1:nrow(doc_matrix_t))
colnames(doc_matrix_t) = doc_matrix[,1]

type1 = c(rep(1, times = length(Itoda_tweets_texts_onlyJa))
          , rep(0, times = length(Ozawa_tweets_texts_onlyJa)))

doc_matrix_t_1 = cbind(doc_matrix_t, type1)
doc_matrix_t_1_naomit = doc_matrix_t_1 %>% na.omit()

doc_matrix_t_1_naomit[is.nan(doc_matrix_t_1_naomit)] = NA
doc_matrix_t_1_naomit = doc_matrix_t_1_naomit %>% na.omit()
tmp_data_frame = as.data.frame(doc_matrix_t_1_naomit)
tmp_data_frame = tmp_data_frame[,8:ncol(tmp_data_frame)]

#########################################
############# decision tree ############# 
#########################################
train_sample = sample(nrow(tmp_data_frame), nrow(tmp_data_frame)*0.5)
train_tmp_data_frame = tmp_data_frame[train_sample, ]
test_tmp_data_frame = tmp_data_frame[-train_sample, ]

train_tmp_data_frame$type1 = as.factor(train_tmp_data_frame$type1)
dt_model = rpart(type1 ~ ., method="class", data = train_tmp_data_frame)

dt_model_predict = predict(dt_model, test_tmp_data_frame, type="class")
dt_model_type = table(test_tmp_data_frame$type1, dt_model_predict)
sum(diag(dt_model_type)) / sum(dt_model_type) 
rpart.plot(dt_model_2, type = 4, extra=1)

#########################################
############# random forest ############# 
#########################################
tmp_data_frame$type1 = as.factor(tmp_data_frame$type1)
#rf_tune = tuneRF(tmp_data_frame[,1:(ncol(tmp_data_frame)-1)],tmp_data_frame[,ncol(tmp_data_frame)],doBest=T)
rf_model = randomForest(type1 ~ . , data = tmp_data_frame, ntree = 100, proximity = TRUE, mtry = 13 )
