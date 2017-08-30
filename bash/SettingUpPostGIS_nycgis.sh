#Workflow fog Creating DB and importing Data

# 1) In pg_hba.conf add the following (Allows external connections so this can be done from ubuntu vm):
host	 all	 all	 0.0.0.0/0	 md5

###Note: problem areas will be:
#* Similar spectral characteristics or NDVI
#	*Artificial Turf (Playgrounds, soccer fields)
#	* Glass top of building (see W 20th and 11th Ave)
#
#* What is a building? Look at S. End of Roosevelt Island - park is listed as a building
#

## Get into postgres (if on ubuntu vm use the windows box ip address)
## Can also run the commands from within postgres separately
psql -h mlt_host -U postgres -c 'CREATE DATABASE nycgis;'
psql -h mlt_host -U postgres -d nycgis -c 'CREATE EXTENSION postgis;'
psql -h mlt_host -U postgres -d nycgis -c 'SELECT postgis_full_version();'
psql -h mlt_host -U postgres -d nycgis -c 'CREATE SCHEMA staging;'
psql -h mlt_host -U postgres -d nycgis -c 'CREATE SCHEMA health_safety;'
psql -h mlt_host -U postgres -d nycgis -c 'CREATE SCHEMA planimetrics;'
psql -h mlt_host -U postgres -d nycgis -c 'CREATE SCHEMA SoBronx;'
psql -h mlt_host -U postgres -d nycgis -c 'CREATE SCHEMA Brownsville;'
psql -h mlt_host -U postgres -d nycgis -c 'CREATE SCHEMA ecological;'
psql -h mlt_host -U postgres -d nycgis -c 'CREATE SCHEMA environmental;'
psql -h mlt_host -U postgres -d nycgis -c 'CREATE SCHEMA admin;'
psql -h mlt_host -U postgres -d nycgis -c 'CREATE SCHEMA infrastructure;'




###############################
#####Backup of database #######
###############################
pg_dump -h mlt_host -U postgres -d nycgis -Fc -j 4 -v ON_ERROR_STOP=1 > ../../media/sf_L_DRIVE/pg_dump/nycgis_20170414.sql



###############################
#####Import Bldgs Citywide#####
###############################
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/INFRASTRUCTURE/Building_Footprints/building_0316.shp" staging.nycbldgs | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
psql -h mlt_host -U postgres -d nycgis -c 'select ST_ISVALID(geom_2263) from staging.nycbldgs;'
psql -h mlt_host -U postgres -d nycgis -c 'UPDATE staging.nycbldgs
SET geom_2263 = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom_2263), 3));'

#Aug 2017
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/INFRASTRUCTURE/Building_20170830/building.shp" infrastructure.nycbldgs_201708 | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
#psql -h mlt_host -U postgres -d nycgis -c 'select ST_ISVALID(geom_2263) from infrastructure.nycbldgs_201708;'
psql -h mlt_host -U postgres -d nycgis -c 'UPDATE infrastructure.nycbldgs_201708
SET geom_2263 = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom_2263), 3));'

	#Create Spatial Index
	psql -h mlt_host -U postgres -d nycgis -c 'CREATE INDEX nycbldgs_201708_geom_idx
	ON infrastructure.nycbldgs_201708
	USING GIST (geom_2263);'

###############################
#####Import Ditigal Tax Map #####
###############################
shp2pgsql -s 2263 -g geom_2263 -I -d "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PropertyBoundaries/DigitalTaxMap/Digital_Tax_Map_shapefile_03-16/DTM_0316_Tax_Lot_Polygon.shp" staging.dtm | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
psql -h mlt_host -U postgres -d nycgis -c 'select ST_ISVALID(geom_2263) from staging.dtm;'


################################
#####Import DTM Tables #####
###############################
# These don't work on linux unless gdal is built with mdb driver
#ogr2ogr -f "PostgreSQL" PG:"host=mlt_host user=pstgres dbname=nycgis password= port=5432" "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PropertyBoundaries/DigitalTaxMap/tc1_17.mdb"
#ogr2ogr -f "PostgreSQL" PG:"host=127.0.0.1 user=pstgres dbname=nycgis password= port=5432" "N:\Raw_Data\NYC_TNC_NYCprogram\ADMIN\PropertyBoundaries\DigitalTaxMap\tc1_17.mdb"

###To import DTM tax data, easiest to do it through R
# D:/Treglia_Data/MLT_GISData/GeneralCode/NYC_PostGIS/R_Code/AddTableFromCSV.R



###############################
#####Import borough boundaries excluding water #####
###############################
shp2pgsql -s 2263 -g geom_2263 -I -d "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/city_boundaries/nybb_16b/nybb.shp" staging.boroughs_nowater | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
psql -h mlt_host -U postgres -d nycgis -c 'select ST_ISVALID(geom_2263) from staging.boroughs_nowater;'


###############################
#####Import MapPLUTO data #####
###############################
#Import Bronx
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PLUTO/mappluto_16v1/Bronx/BXMapPLUTO.shp" staging.MapPLUTO_BX | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
#Import Brooklyn
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PLUTO/mappluto_16v1/Brooklyn/BKMapPLUTO.shp" staging.MapPLUTO_BK | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
#Import Manhattan
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PLUTO/mappluto_16v1/Manhattan/MNMapPLUTO.shp" staging.MapPLUTO_MN | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
#Import Queens
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PLUTO/mappluto_16v1/Queens/QNMapPLUTO.shp" staging.MapPLUTO_QN | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
#Import Staten Island
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PLUTO/mappluto_16v1/Staten_Island/SIMapPLUTO.shp" staging.MapPLUTO_SI | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1



#Combine all parcels into single table
	psql -h mlt_host -U postgres -d nycgis -c 'CREATE TABLE staging.MapPLUTO_citywide AS(
	SELECT * FROM staging.MapPLUTO_BX
	UNION
	SELECT * FROM staging.MapPLUTO_BK
	UNION
	SELECT * FROM staging.MapPLUTO_MN
	UNION
	SELECT * FROM staging.MapPLUTO_QN
	UNION
	SELECT * FROM staging.MapPLUTO_SI
	);'

	# Make geometry column appropriate for Citywide Parcels
	psql -h mlt_host -U postgres -d nycgis -c "SELECT Populate_Geometry_Columns('staging.MapPLUTO_citywide'::regclass);"

	# Add primary key for citywide parcels
	psql -h mlt_host -U postgres -d nycgis -c 'ALTER TABLE staging.MapPLUTO_citywide ADD COLUMN gid_citywide BIGSERIAL PRIMARY KEY;'

	#Deal with geometry issues
	psql -h mlt_host -U postgres -d nycgis -c 'select ST_ISVALID(geom_2263) from staging.MapPLUTO_citywide;'
	psql -h mlt_host -U postgres -d nycgis -c 'UPDATE staging.MapPLUTO_citywide
	SET geom_2263 = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom_2263), 3));'

	
	
	
##Importing Release 16v2
#Import Bronx
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PLUTO/mappluto_16v2/BXMapPLUTO.shp" admin.MapPLUTO_BX_16v2 | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
#Import Brooklyn
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PLUTO/mappluto_16v2/BKMapPLUTO.shp" admin.MapPLUTO_BK_16v2 | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
#Import Manhattan
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PLUTO/mappluto_16v2/MNMapPLUTO.shp" admin.MapPLUTO_MN_16v2 | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
#Import Queens
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PLUTO/mappluto_16v2/QNMapPLUTO.shp" admin.MapPLUTO_QN_16v2 | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
#Import Staten Island
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PLUTO/mappluto_16v2/SIMapPLUTO.shp" admin.MapPLUTO_SI_16v2 | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1

#Combine all parcels into single table
	psql -h mlt_host -U postgres -d nycgis -c 'CREATE TABLE admin.MapPLUTO_citywide_16v2 AS(
	SELECT * FROM admin.MapPLUTO_BX_16v2
	UNION
	SELECT * FROM admin.MapPLUTO_BK_16v2
	UNION
	SELECT * FROM admin.MapPLUTO_MN_16v2
	UNION
	SELECT * FROM admin.MapPLUTO_QN_16v2
	UNION
	SELECT * FROM admin.MapPLUTO_SI_16v2
	);'

	# Make geometry column appropriate for Citywide Parcels
	psql -h mlt_host -U postgres -d nycgis -c "SELECT Populate_Geometry_Columns('admin.MapPLUTO_citywide_16v2'::regclass);"

	# Add primary key for citywide parcels
	psql -h mlt_host -U postgres -d nycgis -c 'ALTER TABLE admin.MapPLUTO_citywide_16v2 ADD COLUMN gid_citywide BIGSERIAL PRIMARY KEY;'

	#Deal with geometry issues
	psql -h mlt_host -U postgres -d nycgis -c 'select ST_ISVALID(geom_2263) from admin.MapPLUTO_citywide_16v2;'
	psql -h mlt_host -U postgres -d nycgis -c 'UPDATE admin.MapPLUTO_citywide_16v2
	SET geom_2263 = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom_2263), 3));'

	#Create Spatial Index
	psql -h mlt_host -U postgres -d nycgis -c 'CREATE INDEX nyc_census_blocks_geom_idx
	ON admin.MapPLUTO_citywide_16v2
	USING GIST (geom_2263);'

	psql -h mlt_host -U postgres -d nycgis -c 'CREATE INDEX mappluto_citywide_16v2_geom_idx
	ON admin.MapPLUTO_citywide_16v2
	USING GIST (geom_2263);'
	
	
	#Drop single county imports if result is good
	psql -h mlt_host -U postgres -d nycgis -c 'DROP TABLE admin.MapPLUTO_BX_16v2;
	DROP TABLE admin.MapPLUTO_BK_16v2;
	DROP TABLE admin.MapPLUTO_MN_16v2;
	DROP TABLE admin.MapPLUTO_QN_16v2;
	DROP TABLE admin.MapPLUTO_SI_16v2;'


################################
#####Import DPR Properties Layer #####
###############################
shp2pgsql -s 2263 -g geom_2263 -I -d "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PropertyBoundaries/NYC_DPR/DPR_ParksProperties_001/DPR_ParksProperties_001.shp" staging.dpr_properties | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1

	psql -h mlt_host -U postgres -d nycgis -c 'select ST_ISVALID(geom_2263) from staging.dpr_properties;'
	psql -h mlt_host -U postgres -d nycgis -c 'UPDATE staging.dpr_properties
	SET geom_2263 = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom_2263), 3));'
	
	

################################
#####City Owned and Leased Layers #####
###############################
ogr2ogr -f "PostgreSQL" PG:"dbname=nycgis user=postgres host=mlt_host" "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/City_OwnedLeasedProperties/nycCOLPshp/nycCOLP_201601.gdb"

psql -h mlt_host -U postgres -d nycgis -c 'ALTER TABLE  public.colpculrec SET SCHEMA staging;
ALTER TABLE public.colpedu SET SCHEMA staging;
ALTER TABLE public.colphss SET SCHEMA staging;
ALTER TABLE public.colplpt SET SCHEMA staging;
ALTER TABLE public.colpmsi SET SCHEMA staging;
ALTER TABLE public.colpnouse SET SCHEMA staging;
ALTER TABLE public.colpoff SET SCHEMA staging;
ALTER TABLE public.colppscj SET SCHEMA staging;
ALTER TABLE public.colpresduse SET SCHEMA staging;'


DROP TABLE staging.colp_all;

psql -h mlt_host -U postgres -d nycgis -c 'CREATE TABLE staging.colp_all AS(
	SELECT * FROM staging.colpculrec
	UNION
	SELECT * FROM staging.colpedu
	UNION
	SELECT * FROM staging.colphss
	UNION
	SELECT * FROM staging.colplpt
	UNION
	SELECT * FROM staging.colpmsi
	UNION
	SELECT * FROM staging.colpnouse
	UNION
	SELECT * FROM staging.colpoff
	UNION
	SELECT * FROM staging.colppscj
	UNION
	SELECT * FROM staging.colpresduse
	);'

	# Make geometry column appropriate for Citywide Parcels
	psql -h mlt_host -U postgres -d nycgis -c "SELECT Populate_Geometry_Columns('staging.colp_all'::regclass);"

	# Add primary key for citywide parcels
	psql -h mlt_host -U postgres -d nycgis -c 'ALTER TABLE staging.colp_all ADD COLUMN gid_colp BIGSERIAL PRIMARY KEY;'
	
################################
#####State Properties #####
###############################
ogr2ogr -f "PostgreSQL" PG:"dbname=nycgis user=postgres host=mlt_host" "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PropertyBoundaries/NYS_Parcels/NYS_Tax_Parcels_State_Owned.gdb"
psql -h mlt_host -U postgres -d nycgis -c 'ALTER TABLE  public.nyc_bldgclass_codes SET SCHEMA staging;
ALTER TABLE  public.nyc_landuse_codes SET SCHEMA staging;
ALTER TABLE  public.nys_property_class_codes SET SCHEMA staging;
ALTER TABLE  public.nys_tax_parcels_state_owned SET SCHEMA staging;'


psql -h mlt_host -U postgres -d nycgis -c 'SELECT * INTO staging.nys_tax_parcels_state_2263
FROM (SELECT *, ST_TRANSFORM(nys_tax_parcels_state_owned.wkb_geometry, 2263) as geom_2263
FROM staging.nys_tax_parcels_state_owned) AS FOO;

ALTER TABLE staging.nys_tax_parcels_state_2263
DROP COLUMN wkb_geometry;

 ALTER TABLE staging.nys_tax_parcels_state_2263
 ALTER COLUMN geom_2263 TYPE geometry(Multipolygon,2263) USING ST_Multi(geom_2263);'

################################
#####Federal_NPS_Area Properties #####
###############################
shp2pgsql -s 4269 -g geom_4269 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/PropertyBoundaries/NPS/GATE_tracts_2016/GATE_tracts_2016.shp" staging.fed_nps_properties | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1

	psql -h mlt_host -U postgres -d nycgis -c 'select ST_ISVALID(geom_4269) from staging.fed_nps_properties;' #--All is well with Geometry

### Reproject into EPSG 2263
psql -h mlt_host -U postgres -d nycgis -c 'SELECT * INTO staging.fed_nps_properties_2263
FROM (SELECT *, ST_TRANSFORM(fed_nps_properties.geom_4269, 2263) as geom_2263
FROM staging.fed_nps_properties) AS FOO;

ALTER TABLE staging.fed_nps_properties_2263
DROP COLUMN geom_4269;

 ALTER TABLE staging.fed_nps_properties_2263
 ALTER COLUMN geom_2263 TYPE geometry(Multipolygon,2263) USING ST_Multi(geom_2263);'




###############################
#####Import NYC Land Cover (3 ft)#####
###############################
##Following exmaple here: https://duncanjg.wordpress.com/2012/11/20/the-basics-of-postgis-raster/
raster2pgsql -s 2263 -d -C -t 100x100 -M -I -l 4 "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/LAND USE/Land_20Cover_202010/landcover_2010_nyc_3ft.img" staging.landcover3ft_2010 | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1


###############################
#####Import GEE NDVI Classification#####
###############################
##Following exmaple here: https://duncanjg.wordpress.com/2012/11/20/the-basics-of-postgis-raster/
raster2pgsql -s 2263 -d -C -t 100x100 -M -I -l 4 -N 0 -d "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/EARTH ENGINE/2013_NAIP_NDVI_Classification_20160711.tif" staging.NAIP_NDVI_Classified_2013 | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1


#raster2pgsql -s 2263 -d -C -t 100x100 -M -I -l 4  "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/EARTH ENGINE/2013_NAIP_NDVI_Classification_20160711.tif" staging.NAIP_NDVI_Classified_2013b | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1




#Create new schemas
psql -h mlt_host -U postgres -d nycgis -c "CREATE SCHEMA resultlayers;"


################################
#####NYC COmmunity Districtss #####
###############################
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/NYC_Comm_Dist/nycd_16b/nycd.shp" staging.nyc_commdist | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1


psql -h mlt_host -U postgres -d nycgis -c 'update staging.nyc_commdist
set geom_2263 = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom_2263), 3));'


################################
#####Terrestrial State land, no DPR land #####
###############################
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_Treglia_Data/MLT_GISData/LargestLandownerAnalysis/State_NoDPR.shp" resultlayers.state_land_nodpr | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1


psql -h mlt_host -U postgres -d nycgis -c 'update resultlayers.state_land_nodpr
set geom_2263 = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom_2263), 3));'


################################
#####PLUTO - No Federal/State/DPR #####
###############################
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_Treglia_Data/MLT_GISData/LargestLandownerAnalysis/mappluto_noknowns.shp" resultlayers.mappluto_noknowns | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1


psql -h mlt_host -U postgres -d nycgis -c 'update staging.mappluto_noknowns
set geom_2263 = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom_2263), 3));'


################################
#####PLUTO - No Federal/State/DPR #####
###############################
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_Treglia_Data/MLT_GISData/LargestLandownerAnalysis/mappluto_noknowns.shp" resultlayers.mappluto_noknowns | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
psql -h mlt_host -U postgres -d nycgis -c 'update resultlayers.mappluto_noknowns
set geom_2263 = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom_2263), 3));'

shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_Treglia_Data/MLT_GISData/LargestLandownerAnalysis/mappluto_noknowns_land.shp" resultlayers.mappluto_noknowns_land | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
psql -h mlt_host -U postgres -d nycgis -c 'update resultlayers.mappluto_noknowns_land
set geom_2263 = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom_2263), 3));'

################################
#####Federal - no State no DPR#####
###############################
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_Treglia_Data/MLT_GISData/LargestLandownerAnalysis/Fed_NoDPR_NoState.shp" resultlayers.fed_nps_nodpr_nostate_land | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
psql -h mlt_host -U postgres -d nycgis -c 'update resultlayers.fed_nps_nodpr_nostate_land
set geom_2263 = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom_2263), 3));'



################################
#####IPIS DATA #####
###############################
#Used R_Code/AddTableFromCSV and updated appropriately to import ipis data from ADMIN/PropertyBoundaries/IPIS_Integrated_Property_Information_System_.csv


#NYCHA Campuses
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_L_DRIVE/UHI_Scratch/NYCHA_Developments/NYCHA_Developments.shp" staging.nycha_campus | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1


###



#################################
#####Planimetric Data #####
###############################
#From: https://data.cityofnewyork.us/Transportation/NYC-Planimetrics/wt4d-p43d 
#Download link: https://data.cityofnewyork.us/api/file_data/7d4c30c1-a61f-4ff9-a98a-2427f49e2a5e?filename=NYC_DoITT_Planimetric_OpenData.gdb.zip
psql -h mlt_host -U postgres -d nycgis -c 'CREATE SCHEMA doitt_planimetrics2016;'

ogr2ogr -f "PostgreSQL"  PG:"dbname=nycgis user=postgres active_schema=doitt_planimetrics2016 host=mlt_host port=5432"  ../../media/sf_L_DRIVE/NYC_DoITT_Planimetric_OpenData.gdb -overwrite



#################################
#####Neighborhood Tabulation Area #####
###############################
#From: https://www1.nyc.gov/site/planning/data-maps/open-data/dwn-nynta.page
#Download link: https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/nynta_17a.zip - note, changes w/ cycle 
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/nynta_17a/nynta.shp" staging.nyc_nta | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1



#################################
#####Street Trees #####
###############################
#https://data.cityofnewyork.us/Environment/2015-Street-Tree-Census-Tree-Data/pi5s-9p35
#Download Link:https://data.cityofnewyork.us/api/geospatial/pi5s-9p35?method=export&format=Original
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ECOLOGICAL/NYC_TreeCensus/2015_StreetTreeCensus/SHP/2015_StreetTreeCensus_TREES.shp" ecological.dpr_2015tree_census | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1

#temporarily used to do this locally
#shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_L_DRIVE/misc_mlt/SHP/2015StreetTreesCensus_TREES.shp" ecological.dpr_2015tree_census | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1

#################################
#####DEM - 1ft #####
###############################
#https://data.cityofnewyork.us/City-Government/1-foot-Digital-Elevation-Model-DEM-/dpc8-z3jc
#https://sa-static-customer-assets-us-east-1-fedramp-prod.s3.amazonaws.com/data.cityofnewyork.us/NYC_DEM_1ft.zip
#shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ECOLOGICAL/NYC_TreeCensus/2015_StreetTreeCensus/SHP/2015_StreetTreeCensus_TREES.shp" environmental.doitt_dem1ft | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
raster2pgsql -s 2263 -d -C -t 100x100 -M -I -l 4 -N 0 -d "../../media/sf_L_DRIVE/ENVIRONMENTAL/DEM_DoITT_2010/DEM_LiDAR_1ft_2010_Improved_NYC.img" environmental.doitt_dem1ft | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
ENVIRONMENTAL/DEM_DoITT_2010/DEM_LiDAR_1ft_2010_Improved_NYC.img


#################################
#####Census Block 2010 #####
###############################
#https://data.cityofnewyork.us/City-Government/2010-Census-Blocks/v2h8-6mxf
#https://data.cityofnewyork.us/api/geospatial/v2h8-6mxf?method=export&format=Original
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/DCP_CensusBlocks/nycb2010_17a/nycb2010.shp" admin.dcp_2010censusblock | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
psql -h mlt_host -U postgres -d nycgis -c 'UPDATE admin.dcp_2010censusblock SET geom_2263 = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom_2263), 3));'


#################################
#####Census Tract 2010 #####
###############################
#https://data.cityofnewyork.us/City-Government/2010-Census-Tracts/fxpq-c8ku
#https://data.cityofnewyork.us/api/geospatial/fxpq-c8ku?method=export&format=Original
shp2pgsql -s 2263 -g geom_2263 -I "../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/ADMIN/DCP_CensusTracts/nyct2010_17a/nyct2010.shp" admin.dcp_2010censustract | psql -h mlt_host -U postgres -d nycgis -v ON_ERROR_STOP=1
psql -h mlt_host -U postgres -d nycgis -c 'UPDATE admin.dcp_2010censustract SET geom_2263 = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom_2263), 3));'
