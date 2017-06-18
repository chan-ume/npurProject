#install.packages("rvest", dependencies=T)
#install.packages("dplyr", dependencies=T)
#install.packages("jsonlite", dependencies=T)
#install.packages("stringr", dependencies=T)

library(rvest)
library(dplyr)
library(jsonlite)
library(stringr)
library(magrittr)

basicUrlForP = read_html("http://baseball-data.com/ranking-salary/ce/h.html")
urlTableForP = basicUrlForP %>% html_table()
urlListForP = basicUrlForP %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")
	
basicUrlForS = read_html("http://baseball-data.com/ranking-salary/pa/h.html")
urlTableForS = basicUrlForS %>% html_table()
urlListForS = basicUrlForS %>% html_nodes(xpath = "/html/body/div[@id='container']/div[@id='main']/table[@id='tbl']/tbody//a") %>% html_attr("href")

numberOfPPlayers = urlListForP %>% length
numberOfSPlayers = urlListForS %>% length

