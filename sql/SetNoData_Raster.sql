--Set No Data Value
SELECT ST_SetBandNoDataValue(gee_ndvi_2013.rast,0)
FROM staging.gee_ndvi_2013;