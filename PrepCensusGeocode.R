#   Create a file of all unique addresses suitable for the census geocoder

library(tidyverse)

# List of files to read in
filelist <- list.files("/home/ajackson/Dropbox/CrimeStats",pattern="District.*Clean*")

# empty dataframe for addresses
census <- data.frame(Address=character(), 
                 stringsAsFactors=FALSE) 
#   Loop through input files
for (f in filelist) {
  df <- readRDS(paste("/home/ajackson/Dropbox/CrimeStats/",f,sep=""))
  #   Add suffix to street names where suffix exists
  types <- sort(unique(df$Type))

  types <- types[types!="-"]
  types <- types[types!=""]
  for (t in types) {
    maskstreet <- grepl(paste(" ",t,"$",sep=""), df$Street) 
    masktype <- grepl(t,df$Type)
    df$Street[!maskstreet&masktype] <- paste(df$Street[!maskstreet&masktype], df$Type[!maskstreet&masktype])
  }
  #   add to dataframe with addresses in it
  dfaddress <- data.frame(Address=paste(df$Block_Range,df$Street,", Houston, TX"), stringsAsFactors = FALSE)
  dfaddress$Block_Range <- df$Block_Range
  #colnames(workcensus)[1] = "Address"
  census <- bind_rows(census, dfaddress)
}

census <- unique(census) # filter down to unique addresses
#   kill off NA's
census <- as.data.frame(census[!grepl("9 NA ,|UNK NA", census$Address),])
census <- as.data.frame(census[!grepl("UNK ", census$Address),])
census <- as.data.frame(census[!grepl("NA ", census$Address),])

# split out beginning and ending block addresses and street name
census[,3] = str_extract(census$Address,"^\\d+")
census[,4] = str_extract(census$Address,"\\d+ ")
census[,5] = str_extract(census$Address," .+$")
colnames(census)[3] = "Add1"
colnames(census)[4] = "Add2"
colnames(census)[5] = "Street"

# delete records that are incomplete
census <- census[complete.cases(census),]

#   Add a key field so I can find the records again (just a sequential number)
census <- tibble::rowid_to_column(census, "ID")

#   output file suitable for census geocoding
#  https://geocoding.geo.census.gov/geocoder/locations/addressbatch?form


Addresses1 <- paste(census$ID, ",", census$Add1, census$Street, ",")
Addresses2 <- paste(census$ID, ",", census$Add2, census$Street, ",")
#   Limit of 10,000 addresses per query
for (i in 1:(as.integer(length(Addresses1)/10000+1))){
  imax <- min(i*10000, length(Addresses1))
  imin <- (i-1)*10000 + 1
  write.table(Addresses1[imin:imax], file=paste("/home/ajackson/censusinput1_",i,".txt", sep=""), quote=FALSE, row.names=FALSE, col.names=FALSE, sep=",")
  write.table(Addresses2[imin:imax], file=paste("/home/ajackson/censusinput2_",i,".txt", sep=""), quote=FALSE, row.names=FALSE, col.names=FALSE, sep=",")
}

