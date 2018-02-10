#devtools::install_github("bmschmidt/wordVectors")
library(rvest)
library(tsne)
library(magrittr)
library(stringr)
library(wordVectors)
library(dplyr)
library(RMeCab)

basic_url = "https://www.uta-net.com"

nogizaka_url = "https://www.uta-net.com/artist/12550/"
nogizaka_url_page = read_html(nogizaka_url)

url_list = nogizaka_url_page %>% 
  html_nodes(xpath = "//div[@id='artist']//table/tbody//td[@class='side td1']/a") %>%
  html_attr("href")
song_url_list = url_list[url_list %>% grep("/song/",.)]

lyrics = ""

for (i in 1:(song_url_list %>% length())){
  song_url = song_url_list[i]
  tmp_url = paste(basic_url, song_url_list[i], sep = "")
  
  tmp_lyrics = read_html(tmp_url) %>% 
    html_nodes(xpath = "//div[@id='kashi_area']") %>%
    html_text()
  
  lyrics = paste(lyrics, tmp_lyrics, sep = " ")
  Sys.sleep(5)
}

write.table(lyrics,"lyrics_nogizaka.txt",col.names = F,row.names = F)
########################################################################
########################################################################
########################################################################
rmecab_text_nogizaka = RMeCabText("lyrics_nogizaka.txt")

rmecab_text_nogizaka_list = ""
for (i in 1:(rmecab_text_nogizaka %>% length)){
  tmp_rmecab_text_nogizaka = rmecab_text_nogizaka[[i]]
  if ((tmp_rmecab_text_nogizaka[2] %in% c("名詞", "動詞","形容詞")) &&
    (tmp_rmecab_text_nogizaka[3] != "非自立")){
      rmecab_text_nogizaka_list = paste(rmecab_text_nogizaka_list, as.character(tmp_rmecab_text_nogizaka[1]), sep = " ")
  }
}

write(rmecab_text_nogizaka_list, file = "rmecab_text_nogizaka_list.bin", append = TRUE)
model = train_word2vec("rmecab_text_nogizaka_list.bin", vectors = 50, window = 4, threads = 1)

model %>% closest_to(model[["人生"]])
model %>% plot()
