--Counts Pixels with data and total (including nodata) for innter buffer of polygons, and calculates ratio of them - This IDs Green Roofs
--Only looks at buildings > 2000 sq ft
SELECT gid,
bin,
geom,
countgrn,
countttl,
(countgrn::float / countttl::float)*100 as propgrn
into resultsvectorlayers.greenroof_go1_may3_2ksqftmin 
FROM (
	SELECT gid,
	bin,
	(ST_SummaryStats(ST_Union(ST_Clip(rast,st_buffer(nycbldgs.geom_2263, -9.84252))),true)).count as countgrn,
	(ST_SummaryStats(ST_Union(ST_Clip(rast,st_buffer(nycbldgs.geom_2263, -9.84252))),false)).count as countttl,
	(ST_BUFFER(nycbldgs.geom_2263, -9.84252)) as geom
	FROM staging.gee_ndvi_2013_merged, staging.nycbldgs 
	WHERE ST_INTERSECTS(gee_ndvi_2013_merged.rast, nycbldgs.geom_2263)
	AND shape_area > 2000 #
	GROUP BY gid, geom_2263) AS FOO;
