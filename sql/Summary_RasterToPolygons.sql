--Calculate summar stats of continuous raster for elements of a polygon/multipolygon
SELECT staging.nycbldgs.bin,
(ST_SummaryStats(ST_Union(ST_Clip(rast,geom_2263)))).* 
FROM staging.gee_ndvi_2013, staging.nycbldgs 
GROUP BY bin;