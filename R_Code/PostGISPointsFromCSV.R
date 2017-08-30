library(sf)
library(RPostgreSQL)
library(sp)

#system.time(crime_historic <- read.csv("D:/Treglia_Data/Downloads/NYPD_Complaint_Map__Historic_.csv"))

system.time(crime_historic <- read.csv("../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/HEALTH_SAFETY/NYPD_Complaint_Map__Historic_.csv", stringsAsFactors = FALSE))
crime_historic$CMPLNT_FR_TIME <- as.character(as.POSIXct(paste(crime_historic$CMPLNT_FR_DT, crime_historic$CMPLNT_FR_TM), format="%m/%d/%Y\ %H:%M", tz=""))
crime_historic$CMPLNT_TO_TIME <- as.character(as.POSIXct(paste(crime_historic$CMPLNT_TO_DT, crime_historic$CMPLNT_TO_TM), format="%m/%d/%Y\ %H:%M", tz=""))
crime_historic$RPT_DT <- as.character(as.POSIXct(crime_historic$RPT_DT, format="%m/%d/%Y", tz=""))


system.time(crime_current <- read.csv("../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/HEALTH_SAFETY/NYPD_Complaint_Data_Current_YTD.csv", stringsAsFactors = FALSE))
crime_current$CMPLNT_FR_TIME <- as.character(as.POSIXct(paste(crime_current$CMPLNT_FR_DT, crime_current$CMPLNT_FR_TM), format="%m/%d/%Y\ %H:%M", tz=""))
crime_current$CMPLNT_TO_TIME <- as.character(as.POSIXct(paste(crime_current$CMPLNT_TO_DT, crime_current$CMPLNT_TO_TM), format="%m/%d/%Y\ %H:%M", tz=""))
crime_current$RPT_DT <- as.character(as.POSIXct(crime_current$RPT_DT, format="%m/%d/%Y", tz=""))


system.time(vehicle_collisions <- read.csv("../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/HEALTH_SAFETY/NYPD_Motor_Vehicle_Collisions.csv", stringsAsFactors = FALSE))
vehicle_collisions$DATETIME <- as.character(as.POSIXct(paste(vehicle_collisions$DATE, vehicle_collisions$TIME), format="%m/%d/%Y\ %H:%M", tz=""))




#'../../media/sf_N_DRIVE/Raw_Data/'
#crime_historic.test <- crime_historic[1:50,]

#conn = dbConnect(PostgreSQL(), dbname='nycgis', user='postgres', host='mlt_host')#, password=pw) [PW not needed b/c that's stored in local config files]

#crime.test.spdf<-data.frame(crime_historic.test[!is.na(crime_historic.test['Longitude']),])
#coordinates(crime.test.spdf)<-c("Longitude","Latitude")

#nypd_crime_current.sf = st_as_sf(crime_current[1:50,], coords = c("Longitude", "Latitude"), crs = 4326)
#st_write(nypd_crime_current.sf, "PG:dbname=nycgis user=postgres host=mlt_host", 'test.crime_current')


nypd_crime_historic.sf <- st_as_sf(crime_historic, coords = c("Longitude", "Latitude"), crs = 4326)
nypd_crime_historic.sf <- st_transform(nypd_crime_historic.sf, crs=2263)

system.time(nypd_crime_current.sf <- st_as_sf(crime_current, coords = c("Longitude", "Latitude"), crs = 4326))
system.time(nypd_crime_current.sf <- st_transform(nypd_crime_current.sf, crs=2263))

nypd_vehicle_collisions.sf <- st_as_sf(vehicle_collisions, coords = c("LONGITUDE", "LATITUDE"), crs = 4326)
nypd_vehicle_collisions.sf <- st_transform(nypd_vehicle_collisions.sf, crs=2263)

##set up db connection, needed to manually define epsg/SRID code. - might not need given fix from Edzer to sf (on dev/github)
#conn = dbConnect(PostgreSQL(), dbname='nycgis', user='postgres', host='mlt_host')#, password=pw) [PW not needed b/c that's stored in local config files]


st_write(nypd_crime_historic.sf, "PG:dbname=nycgis user=postgres host=mlt_host", 'health_safety.nypd_crime_historic', update=TRUE)
#dbGetQuery(conn, "SELECT UpdateGeometrySRID('health_safety','nypd_crime_historic','wkb_geometry',2263);")

st_write(nypd_crime_current.sf, "PG:dbname=nycgis user=postgres host=mlt_host", 'health_safety.nypd_crime_current', update=TRUE)
#Need to manually re-define the SRID
#dbGetQuery(conn, "SELECT UpdateGeometrySRID('health_safety','nypd_crime_current','wkb_geometry',2263);")


st_write(nypd_vehicle_collisions.sf, "PG:dbname=nycgis user=postgres host=mlt_host", 'health_safety.nypd_vehicle_collisions', update=TRUE)
#dbGetQuery(conn, "SELECT UpdateGeometrySRID('health_safety','nypd_vehicle_collisions','wkb_geometry',2263);")


