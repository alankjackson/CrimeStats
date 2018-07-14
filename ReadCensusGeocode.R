#   Read in census geoding output files and generate a file of good
#   coordinates, and a file of re-do's

library(tidyverse)
library(stringr)

# empty dataframe for results
df <- data.frame(ID=integer(), 
                 InputAddress=character(), 
                 Matching=character(), 
                 Quality=character(), 
                 MatchAddress=character(), 
                 LatLong=character(), 
                 TIGERID=integer(), 
                 SideOfStreet=character(), 
                     stringsAsFactors=FALSE) 

filelist <- list.files("/home/ajackson/Downloads",pattern="GeocodeResults2*")

for (f in filelist) {
  dftemp <- read.csv(file=paste("/home/ajackson/Downloads/",f,sep=""), header=FALSE, stringsAsFactors = FALSE)
  names(dftemp) <- c("ID", "InputAddress", "Matching", "Quality", "MatchAddress", "LatLong", "TIGERID", "SideOfStreet")
  df <- bind_rows(df, dftemp)
}

#   select out only what I care about
df <- df %>%
  select(ID,InputAddress, Matching, Quality, MatchAddress, LatLong)

#   Freeway naming convention fix - SOUTH LOOP -> S LOOP FWY WEST-> W, etc.
#   change the original

df$InputAddress <- str_replace(df$InputAddress, "SOUTH LOOP", "S LOOP FWY")
df$InputAddress <- str_replace(df$InputAddress, "NORTH LOOP", "N LOOP FWY")
df$InputAddress <- str_replace(df$InputAddress, "EAST LOOP", "E LOOP FWY")
df$InputAddress <- str_replace(df$InputAddress, "WEST LOOP", "W LOOP FWY")
df$InputAddress <- str_replace(df$InputAddress, "FWY FWY", "FWY")
df$InputAddress <- str_replace(df$InputAddress, "LOOP CENTRAL", "LP CENTRAL")


#   Turn some "Exact" into "Non_Exact" (if input and output addresses are not identical)

df <- df %>% mutate(ad1=toupper(str_replace_all(InputAddress," ","")), ad2=str_replace_all(MatchAddress," ",""), MatchQuality="")

for (i in 1:nrow(df)) {
  if (grepl(df$ad1[i],df$ad2[i])) {
    df$MatchQuality[i] <- "Exact"
  } else {df$MatchQuality[i] <- "Not_Exact"}
}

#   If match is exact except for missing suffix, it is okay (ST, RD, AVE, LN)
#   Remove (ST, LN, RD, DR, FWY) from MatchAddress and test again

for (i in 1:nrow(df)) {
  temp <- str_replace(df$ad2[i], "ST,|LN,|RD,|FWY,|DR,", ",")
  if (grepl(df$ad1[i],temp)) {
    df$MatchQuality[i] <- "Exact"
  } 
}

#   Export matches to Master_Geocode.rds

dfexport <- df %>%
  filter(MatchQuality=="Exact") %>%
  select(ID,InputAddress, MatchAddress, LatLong)
#   Save
saveRDS(dfexport, "~/Dropbox/CrimeStats/Master_Geocode.rds")

#   Export non-matches to partialgeocode.rds for later input to google

dfexport <- df %>%
  filter(MatchQuality=="Not_Exact") %>%
  select(ID,InputAddress)
#   Save
saveRDS(dfexport, "~/Dropbox/CrimeStats/partialgeocode.rds")


###  stopped
#   split latlong field (why is this necessary??)
Census <- Census %>%
  separate(LatLong, c("Lon", "Lat"), ",") %>%
  mutate_at(vars(Lon:Lat), as.numeric, na.rm=TRUE)

CensusNA <- Census[complete.cases(Census),]
#   convert to WGS84 from NAD83

# set input to NAD83
CensusLL <- CensusNA[,c("Lon","Lat")]

sfpoints <- st_as_sf(x = CensusLL, 
                     coords = c("Lon", "Lat"),
                     crs = "+proj=longlat +datum=NAD83")
#  convert to WGS84
pointswgs <- st_transform(sfpoints, crs=googlecrs)

#   append to original data frame

CensusNA <- cbind(as.data.frame(CensusNA), st_coordinates(pointswgs))

Census <- left_join(Census, CensusNA, by="ID")
Census <- Census %>%
  select(ID,InputAddress.x, Matching.x, Quality.x, MatchAddress.x, Lon.x, Lat.x, Lon.y, Lat.y)
names(Census) <- c("ID",	 "InputAddress", "Matching", "Quality", "MatchAddress", "Lon", "Lat", "X", "Y")

Census <- Census %>%
  mutate(dist=5280*sqrt((60.273*(Lon-X)**2 + (68.972*(Lat-Y))**2)))

Census <- Census %>%
  arrange(ID)
