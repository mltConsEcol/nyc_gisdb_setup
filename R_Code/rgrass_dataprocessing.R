library(rgrass7)
library(rgdal)
library(raster)
library(RPostgreSQL)
library(sf)

rasterOptions(tmpdir="../../media/sf_Treglia_Data/r_raster_tmp/")

#initialize grass
rgrass7::initGRASS("/usr/lib/grass72", home = "../../media/sf_Treglia_Data/temp_grass_ubuntu", mapset = 'PERMANENT', override = TRUE)

#set projection appropriate
execGRASS('g.proj', flags=c('t', 'c'), epsg=2263)


###################
#South Bronx
###################


#Import landcover data
sb.lcdata ="PG:dbname='nycgis' host=mlt_host port=5432 user='postgres' schema='sobronx' table='sobronx_landcover3ft_100m' mode=2"
sb.lcdata <- readGDAL(sb.lcdata)
sb.lcdata.ras <- raster(sb.lcdata)


#writeRAST(sb.lcdata, "sb.lcdata")
#rgrass7::execGRASS("g.region", raster = "sb.lcdata")
#res <- execGRASS("r.stats", input = "sb.lcdata", flags = 'a',    legacyExec=TRUE)
#test <- readRAST('sb.lcdata')


#Import DEM
sb.dem ="PG:dbname='nycgis' host=mlt_host port=5432 user='postgres' schema='sobronx' table='sobronx_dem1ft_100m' mode=2"
sb.dem <- readGDAL(sb.dem)
sb.dem.ras <- raster(sb.dem)
sb.dem.ras.coarse <- resample(sb.dem.ras, sb.lcdata.ras)
sb.slope.ras <- terrain(sb.dem.ras.coarse, out='slope', unit='degrees')

#Import Trees
conn = dbConnect(PostgreSQL(), dbname='nycgis', user='postgres', host='mlt_host') #[PW not needed b/c that's stored in local config files]
sb.tree =st_read_db(conn, c('sobronx','sobronx_treebuff_nobldg'))
sb.tree <- as(sb.tree, 'Spatial')

sb.tree.ras <- rasterize(sb.tree, sb.lcdata.ras, field='tree_height')
sb.tree.ras[is.na(sb.tree.ras)] <- 0
plot(sb.tree.ras)

#import buildings
sb.bldgs =st_read_db(conn, c('sobronx','sobronx_nycbldgs_100m_v2'))
sb.bldgs <- as(sb.bldgs, 'Spatial')

sb.bldgs.ras <- rasterize(sb.bldgs, sb.lcdata.ras, field='heightroof')

sb.bldgs.ras[is.na(sb.bldgs.ras)] <- 0
plot(sb.bldgs.ras)

#create raster for shade
sb.dem_bldgs_trees <- sb.dem.ras.coarse + sb.tree.ras + sb.bldgs.ras

plot(sb.dem.ras.coarse)

sb.dem_bldgs_trees <- calc(c(sb.dem.ras.coarse, sb.tree.ras, sb.bldgs.ras), fun=sum)

s <- stack(sb.dem.ras.coarse, sb.tree.ras, sb.bldgs.ras)

sumrast <-calc(s, fun=sum)
plot(sumrast)

plot(sb.dem)
plot(sb.dem_bldgs_trees)


writeRAST(as(sb.dem_bldgs_trees, "SpatialGridDataFrame"), "sb.dem_bldgs_trees")
rgrass7::execGRASS("g.region", raster = "sb.dem_bldgs_trees")
#res <- execGRASS("r.stats", input = "sb.dem_bldgs_trees", flags = 'a',    legacyExec=TRUE)
pars <- list(elevation="sb.dem_bldgs_trees", beam_rad="sb.shade_220_1600", day=220, time=16)
system.time(resERR <- execGRASS("r.sun", parameters = pars, legacyExec = TRUE))

sb.shade <- readRAST('sb.shade_220_1600')

plot(sb.shade)

writeRaster(raster(sb.shade), '../../media/sf_Treglia_Data/sb_shade.tif', overwrite=TRUE)



###################
#Brownsville
###################

#Import landcover data
bv.lcdata ="PG:dbname='nycgis' host=mlt_host port=5432 user='postgres' schema='brownsville' table='brownsville_landcover3ft_100m' mode=2"
bv.lcdata <- readGDAL(bv.lcdata)
bv.lcdata.ras <- raster(bv.lcdata)


#writeRAST(bv.lcdata, "bv.lcdata")
#rgrass7::execGRASS("g.region", raster = "bv.lcdata")
#res <- execGRASS("r.stats", input = "bv.lcdata", flags = 'a',    legacyExec=TRUE)
#test <- readRAST('bv.lcdata')


#Import DEM
bv.dem ="PG:dbname='nycgis' host=mlt_host port=5432 user='postgres' schema='brownsville' table='brownsville_dem1ft_100m' mode=2"
bv.dem <- readGDAL(bv.dem)
bv.dem.ras <- raster(bv.dem)
bv.dem.ras.coarse <- resample(bv.dem.ras, bv.lcdata.ras)
bv.slope.ras <- terrain(bv.dem.ras.coarse, out='slope', unit='degrees')

#Import Trees
conn = dbConnect(PostgreSQL(), dbname='nycgis', user='postgres', host='mlt_host') #[PW not needed b/c that's stored in local config files]
bv.tree =st_read_db(conn, c('brownsville','brownsville_treebuff_nobldg'))
bv.tree <- as(bv.tree, 'Spatial')

bv.tree.ras <- rasterize(bv.tree, bv.lcdata.ras, field='tree_height')
bv.tree.ras[is.na(bv.tree.ras)] <- 0
plot(bv.tree.ras)

#import buildings
bv.bldgs =st_read_db(conn, c('brownsville','brownsville_nycbldgs_100m_v2'))
bv.bldgs <- as(bv.bldgs, 'Spatial')

bv.bldgs.ras <- rasterize(bv.bldgs, bv.lcdata.ras, field='heightroof')

bv.bldgs.ras[is.na(bv.bldgs.ras)] <- 0
plot(bv.bldgs.ras)

#create raster for shade
bv.dem_bldgs_trees <- bv.dem.ras.coarse + bv.tree.ras + bv.bldgs.ras

#plot(bv.dem_bldgs_trees)

#writeRaster(bv.dem_bldgs_trees, '../../media/sf_Treglia_Data/testrast2.tif', overwrite=TRUE)



writeRAST(as(bv.dem_bldgs_trees, "SpatialGridDataFrame"), "bv.dem_bldgs_trees")
rgrass7::execGRASS("g.region", raster = "bv.dem_bldgs_trees")
#res <- execGRASS("r.stats", input = "bv.dem_bldgs_trees", flags = 'a',    legacyExec=TRUE)
pars <- list(elevation="bv.dem_bldgs_trees", beam_rad="bv.shade_220_1600", day=220, time=16)
system.time(resERR <- execGRASS("r.sun", parameters = pars, legacyExec = TRUE))

bv.shade <- readRAST('bv.shade_220_1600')

plot(bv.shade)

writeRaster(raster(bv.shade), '../../media/sf_Treglia_Data/bv__shade.tif', overwrite=TRUE)





##############################
##############################
##############################
##Create Cost Rasters
##############################
##############################
##############################

###South Bronx

conn = dbConnect(PostgreSQL(), dbname='nycgis', user='postgres', host='mlt_host') #[PW not needed b/c that's stored in local config files]
sb.sw_crimescore =st_read_db(conn, c('sobronx','sobronx_sidewalk_crimescore'))
sb.sw_crimescore <- as(sb.sw_crimescore, 'Spatial')
sb.sw_crimescore.ras <- rasterize(sb.sw_crimescore, sb.lcdata.ras, field='sidewalkcrime')
sb.sw_crimescore.ras[is.na(sb.sw_crimescore.ras)] <- 0

sb.rb_crimescore =st_read_db(conn, c('sobronx','sobronx_roadbed_crimescore'))
sb.rb_crimescore <- as(sb.rb_crimescore, 'Spatial')
sb.rb_crimescore.ras <- rasterize(sb.rb_crimescore, sb.lcdata.ras, field='roadcrime')
sb.rb_crimescore.ras[is.na(sb.rb_crimescore.ras)] <- 0

sb.rb_vehcol =st_read_db(conn, c('sobronx','sobronx_roadbed_vehcollis'))
sb.rb_vehcol <- as(sb.rb_vehcol, 'Spatial')
sb.rb_vehcol.ras <- rasterize(sb.rb_vehcol, sb.lcdata.ras, field='vehcollis')
sb.rb_vehcol.ras[is.na(sb.rb_vehcol.ras)] <- 0

sb.shade.ras <- raster(sb.shade)

range01 <- function(x){round(10*((log(x+0.01)-log(min(x)+0.01))/(log(max(x)+0.01)-log(min(x)+0.01))), 0)}

sb.sw_crimescore.rescale <- calc(sb.sw_crimescore.ras, fun=range01)
sb.sw_crimescore.rescale[is.na(sb.sw_crimescore.rescale)] <- 0

sb.rb_crimescore.rescale <- calc(sb.rb_crimescore.ras, fun=range01)
sb.rb_crimescore.rescale[is.na(sb.rb_crimescore.rescale)] <- 0

sb.rb_vehcol.rescale <- calc(sb.rb_vehcol.ras, fun=range01)
sb.rb_vehcol.rescale[is.na(sb.rb_vehcol.rescale)] <- 0

sb.slope.rescale <- calc(sb.slope.ras, fun=range01)
sb.slope.rescale[is.na(sb.slope.rescale)] <- 0

sb.shade.rescale <- sb.shade.ras
sb.shade.rescale[sb.shade.rescale > 0] <- 10
sb.shade.rescale[is.na(sb.shade.rescale)] <- 0

sb.tree.rescale <- sb.tree.ras
sb.tree.rescale[sb.tree.rescale==0] <- 5
sb.tree.rescale[sb.tree.rescale>10] <- 0
sb.tree.rescale[is.na(sb.tree.rescale)] <- 0


sb.resistance <- sb.sw_crimescore.rescale + sb.rb_crimescore.rescale + sb.rb_vehcol.rescale + sb.slope.rescale + sb.shade.rescale + sb.tree.rescale
sb.resistance
plot(sb.resistance)



sb.parcels =st_read_db(conn, c('sobronx','sobronx_mappluto_citywide_100m_v2'))
sb.parcels <- as(sb.parcels, 'Spatial')
sb.parcels.ras <- rasterize(sb.parcels, sb.lcdata.ras)
sb.parcels.ras[is.na(sb.parcels.ras)] <- 0
sb.parcels.ras[sb.parcels.ras>0] <- NA

sb.resistance2 <- sb.parcels.ras + sb.resistance
plot(sb.resistance2)

sb.mask =st_read_db(conn, c('sobronx','sobronx_100mbuff'))
sb.mask <- as(sb.mask, 'Spatial')


sb.resistance2 <- mask(sb.resistance2, sb.mask)

writeRaster(sb.resistance2, '../../media/sf_Treglia_Data/uhi_analytics/sb_resistance.asc', dataType='INT2S', NAflag=-9999)
writeRaster(sb.resistance2, '../../media/sf_Treglia_Data/uhi_analytics/sb_resistance.tif', dataType='INT2S', NAflag=-9999)





###brownsville

conn = dbConnect(PostgreSQL(), dbname='nycgis', user='postgres', host='mlt_host') #[PW not needed b/c that's stored in local config files]
bv.sw_crimescore =st_read_db(conn, c('brownsville','brownsville_sidewalk_crimescore'))
bv.sw_crimescore <- as(bv.sw_crimescore, 'Spatial')
bv.sw_crimescore.ras <- rasterize(bv.sw_crimescore, bv.lcdata.ras, field='sidewalkcrime')
bv.sw_crimescore.ras[is.na(bv.sw_crimescore.ras)] <- 0

bv.rb_crimescore =st_read_db(conn, c('brownsville','brownsville_roadbed_crimescore'))
bv.rb_crimescore <- as(bv.rb_crimescore, 'Spatial')
bv.rb_crimescore.ras <- rasterize(bv.rb_crimescore, bv.lcdata.ras, field='roadcrime')
bv.rb_crimescore.ras[is.na(bv.rb_crimescore.ras)] <- 0

bv.rb_vehcol =st_read_db(conn, c('brownsville','brownsville_roadbed_vehcollis'))
bv.rb_vehcol <- as(bv.rb_vehcol, 'Spatial')
bv.rb_vehcol.ras <- rasterize(bv.rb_vehcol, bv.lcdata.ras, field='vehcollis')
bv.rb_vehcol.ras[is.na(bv.rb_vehcol.ras)] <- 0

bv.shade.ras <- raster(bv.shade)

range01 <- function(x){round(10*((log(x+0.01)-log(min(x)+0.01))/(log(max(x)+0.01)-log(min(x)+0.01))), 0)}

bv.sw_crimescore.rescale <- calc(bv.sw_crimescore.ras, fun=range01)
bv.sw_crimescore.rescale[is.na(bv.sw_crimescore.rescale)] <- 0

bv.rb_crimescore.rescale <- calc(bv.rb_crimescore.ras, fun=range01)
bv.rb_crimescore.rescale[is.na(bv.rb_crimescore.rescale)] <- 0

bv.rb_vehcol.rescale <- calc(bv.rb_vehcol.ras, fun=range01)
bv.rb_vehcol.rescale[is.na(bv.rb_vehcol.rescale)] <- 0

bv.slope.rescale <- calc(bv.slope.ras, fun=range01)
bv.slope.rescale[is.na(bv.slope.rescale)] <- 0

bv.shade.rescale <- bv.shade.ras
bv.shade.rescale[bv.shade.rescale > 0] <- 10
bv.shade.rescale[is.na(bv.shade.rescale)] <- 0

bv.tree.rescale <- bv.tree.ras
bv.tree.rescale[bv.tree.rescale==0] <- 5
bv.tree.rescale[bv.tree.rescale>10] <- 0
bv.tree.rescale[is.na(bv.tree.rescale)] <- 0


bv.resistance <- bv.sw_crimescore.rescale + bv.rb_crimescore.rescale + bv.rb_vehcol.rescale + bv.slope.rescale + bv.shade.rescale + bv.tree.rescale
bv.resistance
plot(bv.resistance)



bv.parcels =st_read_db(conn, c('brownsville','brownsville_mappluto_citywide_100m_v2'))
bv.parcels <- as(bv.parcels, 'Spatial')
bv.parcels.ras <- rasterize(bv.parcels, bv.lcdata.ras)
bv.parcels.ras[is.na(bv.parcels.ras)] <- 0
bv.parcels.ras[bv.parcels.ras>0] <- NA

bv.resistance2 <- bv.parcels.ras + bv.resistance
plot(bv.resistance2)

bv.mask =st_read_db(conn, c('brownsville','brownsville_100mbuff'))
bv.mask <- as(bv.mask, 'Spatial')


bv.resistance2 <- mask(bv.resistance2, bv.mask)

writeRaster(bv.resistance2, '../../media/sf_Treglia_Data/uhi_analytics/bv_resistance.asc', dataType='INT2S', NAflag=-9999)
writeRaster(bv.resistance2, '../../media/sf_Treglia_Data/uhi_analytics/bv_resistance.tif', dataType='INT2S', NAflag=-9999)

