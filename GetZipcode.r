#   Send names to google to try to get zipcode

library(ggmap)
library(stringr)
library(tidyr)
library(dplyr)
library(purrr)


dfgoogle = readRDS("~/Dropbox/CrimeStats/partialgeocode.rds")

#   Empty dataframe for accepting lat long values
latlongs <- data.frame(types=character(),
                       Latitude=numeric(), 
                       Longitude=numeric(), 
                       type=character(),
                       StreetName=character(),
                       LocType=character(),
                       stringsAsFactors=FALSE) 

#   Function for pulling fields out of nested lists returned by geocode
getfields <- function(x){
  if(! is.na(x) && length(x$results)>0)  {data.frame(
    Latitude=as.numeric(x$results[[1]]$geometry$location$lat),
    Longitude=as.numeric(x$results[[1]]$geometry$location$lng),
    types=x$results[[1]]$types[1],
    StreetName=x$results[[1]]$formatted_address,
    LocType=x$results[[1]]$geometry$location_type,
    stringsAsFactors = FALSE)
  } else if ("status" %in% names(x) && x$status=="ZERO_RESULTS"){
    data.frame(types=x$status,Latitude=NA,Longitude=NA, StreetName=NA,LocType=NA,stringsAsFactors = FALSE)
  } else{
    data.frame(types=NA,Latitude=NA,Longitude=NA, StreetName=NA,LocType=NA,stringsAsFactors = FALSE)
  }
}

testgeocode <- function(x){
  if(length(x$results)==0){
    print(paste("--->", x$status))
  }
}
#   initialize dfgoogle first time through with new columns
dfgoogle$lon1 <- NA
dfgoogle$lat1 <- NA
dfgoogle$lon2 <- NA
dfgoogle$lat2 <- NA
dfgoogle$type <- NA
dfgoogle$StreetName <- NA
dfgoogle$LocType <- NA
dfgoogle$type2 <- NA
dfgoogle$StreetName2 <- NA
dfgoogle$LocType2 <- NA

#--------------  repeat from here

geocodeQueryCheck()
mask1 <- (is.na(dfgoogle$lon1) | is.na(dfgoogle$lat1))& ((dfgoogle$type != "ZERO_RESULTS") | is.na(dfgoogle$type))

sum(mask1)
limit <- min(geocodeQueryCheck(), sum(mask1))
# run geocode for each record up to the daily limit, and then average the lat/long
# values from each end of the block to get a true block center value.
#Addresses <- paste(dfgoogle$Add1[mask1][1:limit], dfgoogle$Street[mask1][1:limit])

zero = 0
query = 0
numb = 0
for (i in 1:limit) {
  AllLatLong <- geocode(dfgoogle$InputAddress[mask1][i], output="all") # geocode addresses
  numb <- numb + 1
  print(paste("----> ",numb," ",limit-numb))
  #latlongs <- map_df(AllLatLong, getfields) # extract desired fields
  latlongs <- getfields(AllLatLong)
  
  dfgoogle$lon1[mask1][i] = latlongs$Longitude
  dfgoogle$lat1[mask1][i] = latlongs$Latitude
  dfgoogle$type[mask1][i] = latlongs$types
  dfgoogle$StreetName[mask1][i] = latlongs$StreetName
  dfgoogle$LocType[mask1][i] = latlongs$LocType
  
  #testgeocode(AllLatLong)
  if(length(AllLatLong$results)==0){
    print(paste("--->", AllLatLong$status))
    if (AllLatLong$status == "OVER_QUERY_LIMIT") {
      query <- query + 1
    }
    if (AllLatLong$status == "ZERO_RESULTS") {
      zero <- zero + 1
    }
  }
  
  Sys.sleep(2)
}

print(paste("limit =",limit,", Over Query =",query,", Zero =",zero, " Pct fail =",query/limit))
save.image()

#   Save temporary results



