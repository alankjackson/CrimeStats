#    Check each Clean Data file to see which geotable got blown away and
#    will need recreation
library(tidyverse)
library(dplyr)

geotable <- readRDS("~/Dropbox/CrimeStats/GeoTable.rds")

districts <- c("1a","2a","4f","5f","10h")

for (i in districts) {
  temp = readRDS(paste("~/Dropbox/CrimeStats/District",i,"CleanData.rds", sep=""))
  testset <- data.frame(paste(temp$Block_Range,temp$Street,", Houston, TX"), stringsAsFactors = FALSE)
  colnames(testset)[1] = "Address"

  testset <- unique(testset)
  #testset <- testset[complete.cases(testset),]
  testset <- left_join(testset, geotable, by="Address")
  testset <- select(testset, Address, Street, Longitude, Latitude)
  
  print(paste("District ",i,": matched = ", sum(is.na(testset$Longitude)), " unmatched = ",
        sum(!is.na(testset$Longitude))), sep="")

}
