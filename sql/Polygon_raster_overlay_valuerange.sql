--STILL WORKING THIS OUT!!!
--COunt Pixels within specified value range per polygon (specified in reclass statement)
--http://postgis.net/2016/03/13/tip_pixels_of_range_value/
--DROP TABLE qlayer3;
SELECT *,
 count_undevel/(count_undevel + count_devel)::float as Prop_Undevel --Calculates proportion of pixels in borough that are undeveloped
 INTO qlayer3
FROM(
	SELECT 
	p.*,
--p.gid,
	(ST_SummaryStats(
		ST_Union(
			ST_Reclass(
				ST_Clip(rast, p.geom_2263),
				1,'[1-3]:1, [5-7]:0', '8BUI',0)
				),
			TRUE)
		).count as count_undevel,
--	(ST_SummaryStats(ST_Union((ST_Clip(ST_Reclass(rast,1,'[1-7]:0-0', '8BUI',0), p.geom_2263))),TRUE)).count as countbrn2, --THIS WORKS TOO IN SMALLER SAMPLE AREA, BUT SUPER SLOW
	(ST_SummaryStats(
		ST_Union(
			ST_Clip(rast, p.geom_2263)
				),
			TRUE)
		).count as count_devel
	--p.geom_2263
	FROM staging.landcover3ft_2010 r, staging.parcels_clip p --specify which layers
	WHERE ST_INTERSECTS(r.rast, p.geom_2263) --and rid = 2
	group by p.geom_2263, p.gid
) AS FOO;




--STILL NEED TO EXCLUDE BUILDING FOOTPRINTS; MAYBE WATER BODIES?
SELECT *,
 count_undevel/(count_undevel + count_devel)::float as Prop_Undevel --Calculates proportion of pixels in borough that are undeveloped
 INTO qlayer3
FROM(
	SELECT 
	p.*,
--p.gid,
	(ST_SummaryStats(
		ST_Union(
			ST_Reclass(
				ST_Clip(rast, 
				(COALESCE(ST_Difference(parcels_clip.geom_2263,ST_UNION(bldgs.geom_2263)),boroughs_nowater.geom_2263) 
				As newGeom FROM staging.parcels_clip  LEFT JOIN staging.bldgs ON ST_Intersects(parcels_clip.geom_2263, bldgs.geom_2263)),
				1,'[1-3]:1, [5-7]:0', '8BUI',0)
				),
			TRUE)
		).count as count_undevel,
--	(ST_SummaryStats(ST_Union((ST_Clip(ST_Reclass(rast,1,'[1-7]:0-0', '8BUI',0), p.geom_2263))),TRUE)).count as countbrn2, --this line does the same as above, but is a bit slower
	(ST_SummaryStats(
		ST_Union(
			ST_Clip(rast, p.geom_2263)
				),
			TRUE)
		).count as count_devel
	--p.geom_2263
	FROM staging.landcover3ft_2010 r, staging.parcels_clip p --specify which layers
	WHERE ST_INTERSECTS(r.rast, p.geom_2263) --and rid = 2
	group by p.geom_2263, p.gid
) AS FOO;
