#this seems to bowk, but can also try postgres package (https://github.com/rstats-db/RPostgres)
#https://www.nceas.ucsb.edu/system/files/rpostgresql.txt

library(RPostgreSQL)


# Case 2: local database requiring username/password
con <- dbConnect(dbDriver("PostgreSQL"), user='postgres', dbname='nycgis', host='mlt_host', password=pw)

setwd("../../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PropertyBoundaries/DigitalTaxMap")

system.time(tc1 <- read.csv("tc1.csv"))


#Write to 
system.time(dbWriteTable(con, c("staging", "dtm_tc1"), value=tc1, row.names=FALSE))


system.time(tc234 <- read.csv("tc234.csv"))

system.time(dbWriteTable(con, c("staging", "dtm_tc234"), value=tc234, row.names=FALSE))
