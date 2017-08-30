library(sf)
library(RPostgreSQL)


#Work with NTA Data

#Create db connection
conn = dbConnect(PostgreSQL(), dbname='nycgis', user='postgres', host='mlt_host')#, password='treglia2016') [PW not needed b/c that's stored in local config files]

#Import nta layer
nta_bounds = st_read_db(conn, c("staging", "nyc_nta"))#, query = "select * from staging.nyc_nta;") Query part isn't working... might need to try updating 

#Query desired ntas
nta_bounds <- nta_bounds[which(nta_bounds$ntacode=='BK17' | nta_bounds$ntacode=='BK44' | nta_bounds$ntacode=='BK45' | nta_bounds$ntacode=='QN57' | x$ntacode=='SI25'),]

#Create column for project name and add names
nta_bounds$AssocPrjct <- as.character(NA)
nta_bounds$AssocPrjct[which(nta_bounds$ntacode=='BK17' | nta_bounds$ntacode=='BK44' | nta_bounds$ntacode=='BK45')] <- "Marine Park"
nta_bounds$AssocPrjct[which(nta_bounds$ntacode=='SI25')] <- "Oakwood Beach"
nta_bounds$AssocPrjct[which(nta_bounds$ntacode=='QN57')] <- "Howard Beach"

#Create column for project notes and add notes
nta_bounds$Notes <- as.character(NA)
nta_bounds$Notes[which(nta_bounds$ntacode=='BK17' | nta_bounds$ntacode=='BK44' | nta_bounds$ntacode=='BK45')] <- "Project involves restoring natural habitats and trails in Marine Park. Recreational Benefits may apply to NTAs BK17, BK44, & BK45; simply maintaining these areas as open space/park might also provide some flood benefit, particularly to NTA BK17."
nta_bounds$Notes[which(nta_bounds$ntacode=='SI25')] <- "Project involves buyouts of properties within this area, thus Coastal Floodplains are being protected through floodplain reclaimation on targeted parcels in this area."
nta_bounds$Notes[which(nta_bounds$ntacode=='QN57')] <- "TNC led work on green vs. grey infrastructure described at (https://www.nature.org/ourinitiatives/regions/northamerica/unitedstates/newyork/climate-energy/natural-infrastructure-study-at-howard-beach.xml); led to govt agencies securing $40M investment."

#Export data
st_write(nta_bounds, dsn='../../media/sf_Treglia_Data/NYC_Relevant_NTA_Bounds.shp', layer="NYC_Relevant_NTA_Bounds")#, overwrite=TRUE)



#Work with Jamaica Bay and Marine Park Areas

#import data
jbay <- st_read("../../media/sf_L_DRIVE/PROJECTS/JBWR/NSGardens_RestorationDesign/Project_Boundary_FINAL.shp", crs=2263)

mp <- st_read("../../media/sf_L_DRIVE/PROJECTS/Marine Park/MarinePark_Project_Boundary.geojson", crs=2263)

#Create dataframe w/ new gid, geoms
jbay.mp <- data.frame(gid =c(1, 2), geom = (rbind(st_as_text(mp$geometry), st_as_text(st_multipolygon(jbay$geometry)))))

head(test)

jbay.mp.sf <- st_as_sf(jbay.mp, wkt = 2, crs=2263)

plot(jbay.mp.sf[2,])


jbay.mp.sf$AssocPrjct <- as.character(NA)
jbay.mp.sf$AssocPrjct <- c("Marine Park", "Jamaica Bay")
jbay.mp.sf$Notes <- as.character(NA)
jbay.mp.sf$Notes <- c("Project involves restoring natural habitats and trails in Marine Park. Recreational Benefits may apply to NTAs BK17, BK44, & BK45; simply maintaining these areas as open space/park might also provide some flood benefit, particularly to NTA BK17.", "Project involves restoring coastal forest habitats, involving removal of invasives& planting of ~28,000 Trees; no real flood benefit to people; As a US Nat. Park, recreation benefits may extend to entire city, particularly Queens, Brooklyn, & Manhattan")

st_write(jbay.mp.sf, dsn='../../media/sf_Treglia_Data/ProjectBounds_MarinePark_JamaicaBay.shp', layer="ProjectBounds_MarinePark_JamaicaBay.shp")
