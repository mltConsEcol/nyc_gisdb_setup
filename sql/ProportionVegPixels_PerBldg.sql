--Pct Green (grass + trees) per building
DROP TABLE resultlayers.greenroofs_pctgrn;
SELECT *,
 count_undevel/(count_total)::float as PropVeg --Calculates proportion of pixels within each building that are class 1 or 2 based on count_undevel and count_total
INTO resultlayers.greenroofs_pctgrn
FROM(
	SELECT 
	p.*,
--Count number of pixels per building with values 1 or 2
	ST_CountAgg(
		ST_Reclass(
			ST_Clip(rast, p.geom_2263),
			1,'[1-2]:1, [3-5]:0', '8BUI',0), 1,TRUE) --reclassifies classes 1 and 2 as 1, reclassifies values 3-5 as 0, and designates 0 as nodata
		as count_undevel,
--Count total number of pixels
	ST_CountAgg(
		ST_Clip(
		ST_Reclass(rast,1,'[0-5]:1','8BUI'), --reclassify all pixels to non-nodata; when this is clipped, all pixels within polygons are kept as 1, while pixels outside of buildings are set to nodata
		1, p.geom_2263,0,TRUE),
		1,TRUE) --exclude nodata from countAgg
		as count_total
	FROM staging.naip_ndvi_classified_2013 r, staging.nycbldgs p
	WHERE ST_INTERSECTS(r.rast, p.geom_2263) --and rid = 2
	group by p.geom_2263, p.gid
) AS FOO;

--Pct Green (grass + trees) per building
DROP TABLE resultlayers.greenroofs_pctgrass;
SELECT *,
 count_undevel/(count_total)::float as PropVeg --Calculates proportion of pixels within each building that are class 1 or 2 based on count_undevel and count_total
INTO resultlayers.greenroofs_pctgrass_test
FROM(
	SELECT 
	p.*,
--Count number of pixels per building with values 1 or 2
	ST_CountAgg(
		ST_Reclass(
			ST_Clip(rast, p.geom_2263),
			1,'[1]:1, [2-5]:0', '8BUI',0), 1,TRUE) --reclassifies classes 1 and 2 as 1, reclassifies values 3-5 as 0, and designates 0 as nodata
		as count_undevel,
--Count total number of pixels
	ST_CountAgg(
		ST_Clip(
		ST_Reclass(rast,1,'[0-5]:1','8BUI'), --reclassify all pixels to non-nodata; when this is clipped, all pixels within polygons are kept as 1, while pixels outside of buildings are set to nodata
		1, p.geom_2263,0,TRUE),
		1,TRUE) --exclude nodata from countAgg
		as count_total
	FROM staging.naip_ndvi_classified_2013 r, staging.nycbldgs p
	WHERE ST_INTERSECTS(r.rast, p.geom_2263) --and rid = 2
	group by p.geom_2263, p.gid
) AS FOO;

----Create layer with columns for individual veg classes
--DROP TABLE resultlayers.greenroofs_pctgrn;
SELECT *
 --count_undevel/(count_total)::float as PropVeg --Calculates proportion of pixels within each building that are class 1 or 2 based on count_undevel and count_total
INTO resultlayers.greenroofs_veg_grass_ttl
FROM(
	SELECT 
	p.*,
--Count number of pixels per building with values 1 or 2
	ST_CountAgg(
		ST_Reclass(
			ST_Clip(rast, p.geom_2263),
			1,'[1-2]:1, [3-5]:0', '8BUI',0), 1,TRUE) --reclassifies classes 1 and 2 as 1, reclassifies values 3-5 as 0, and designates 0 as nodata
		as count_veg,
	ST_CountAgg(
		ST_Reclass(
			ST_Clip(rast, p.geom_2263),
			1,'[1]:1, [2-5]:0', '8BUI',0), 1,TRUE) --reclassifies classes 1 and 2 as 1, reclassifies values 3-5 as 0, and designates 0 as nodata
		as count_grass,
	ST_CountAgg(
		ST_Reclass(
			ST_Clip(rast, p.geom_2263),
			1,'[2]:1, 1:0, [2-5]:0', '8BUI',0), 1,TRUE) --reclassifies classes 1 and 2 as 1, reclassifies values 3-5 as 0, and designates 0 as nodata
		as count_tree,
--Count total number of pixels
	ST_CountAgg(
		ST_Clip(
		ST_Reclass(rast,1,'[0-5]:1','8BUI'), --reclassify all pixels to non-nodata; when this is clipped, all pixels within polygons are kept as 1, while pixels outside of buildings are set to nodata
		1, p.geom_2263,0,TRUE),
		1,TRUE) --exclude nodata from countAgg
		as count_total
	FROM staging.naip_ndvi_classified_2013 r, staging.nycbldgs p
	WHERE ST_INTERSECTS(r.rast, p.geom_2263) --and rid = 2
	group by p.geom_2263, p.gid
) AS FOO;
