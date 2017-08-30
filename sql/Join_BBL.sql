--Inner Join mappluto to colp_all_bbl based on bbl
--returns only rows that are in both datasets
SELECT DISTINCT ON (colp_all_bbl.bbl) *
FROM resultlayers.mappluto_noknowns INNER JOIN staging.colp_all_bbl ON (mappluto_noknowns.bbl = colp_all_bbl.bbl) ORDER BY colp_all_bbl.bbl ASC --LIMIT 20

--Left Join mappluto to colp_all_bbl - adds columns from colp to mappluto where they have the same bbl code
SELECT  DISTINCT ON (mappluto_noknowns.bbl) *
FROM resultlayers.mappluto_noknowns LEFT JOIN staging.colp_all_bbl ON (mappluto_noknowns.bbl = colp_all_bbl.bbl) ORDER BY colp_all_bbl.bbl ASC --LIMIT 20




----The Real Work...
--Spatially Join selected pluto fields to compiled lands based on spatial intersects/no touch
/* 
EXPLAIN ANALYZE
CREATE TABLE resultlayers.compiled_lands_pluto AS
SELECT DISTINCT on (lands_compiled.gid_lands_compiled) lands_compiled.*, mappluto_citywide.bbl, mappluto_citywide.zonedist1, mappluto_citywide.landuse, mappluto_citywide.ownertype, mappluto_citywide.ownername
FROM resultlayers.lands_compiled left join staging.mappluto_citywide on ST_Intersects(lands_compiled.geom_2263, mappluto_citywide.geom_2263)
AND NOT ST_TOUCHES(lands_compiled.geom_2263, mappluto_citywide.geom_2263);

CREATE INDEX compiled_lands_pluto_gix ON resultlayers.compiled_lands_pluto USING GIST(geom_2263); */




--Spatially Join selected pluto fields to compiled lands based on spatial intersects/no touch - Uses the compiled lands from which PLUTO wasn't clipped to land (lands_compiled_B); see Union_geoms_CommonFields.sql
-- EXPLAIN ANALYZE
-- CREATE TABLE resultlayers.compiled_lands_pluto_b AS
-- SELECT DISTINCT on (lands_compiled_B.gid_lands_compiled) lands_compiled_B.*, mappluto_citywide.bbl, mappluto_citywide.zonedist1, mappluto_citywide.landuse, mappluto_citywide.ownertype, mappluto_citywide.ownername
-- FROM resultlayers.lands_compiled_B left join staging.mappluto_citywide on ST_Intersects(lands_compiled_B.geom_2263, mappluto_citywide.geom_2263)
-- AND NOT ST_TOUCHES(lands_compiled_B.geom_2263, mappluto_citywide.geom_2263);
-- --ORDER BY bbl ASC LIMIT 10

-- CREATE INDEX compiled_lands_pluto_gix ON resultlayers.compiled_lands_pluto USING GIST(geom_2263);


--Join fields from COLP and IPIS based on bbl; note, quotes needed because some field names have periods, due ot import through R 
-- DROP TABLE resultlayers.compiled_lands_pluto_ipis_colp_final;

-- CREATE TABLE resultlayers.compiled_lands_pluto_ipis_colp_final AS
-- SELECT  DISTINCT ON (compiled_lands_pluto_b.gid_lands_compiled) 
-- compiled_lands_pluto_b.*, 
-- colp_all_bbl.agency as colp_agency,
-- colp_all_bbl.usedesc as colp_use,
-- ipis."JURIS",
-- ipis."Jurisdiction.Description" as juris_desc,
-- ipis."RPAD_DESCRIPTION",
-- ipis."WATERFRONT" as ipis_waterfront,
-- ipis."Agency" as ipis_agency,
-- ipis."Owned.Leased" as owned_leased,
-- ipis."Primary.Use.Text" as ipis_use
-- FROM resultlayers.compiled_lands_pluto_b 
	-- LEFT JOIN staging.colp_all_bbl ON (compiled_lands_pluto_b.bbl = colp_all_bbl.bbl) 
	-- LEFT JOIN staging.ipis on (compiled_lands_pluto_b.bbl = ipis."BBL"::numeric) ;
-- --ORDER BY compiled_lands_pluto_b.bbl

-- CREATE INDEX compiled_lands_pluto_ipis_colp_final_gix ON resultlayers.compiled_lands_pluto_ipis_colp_final USING GIST(geom_2263);


--Using the centroids of the pluto data, within the polygons, is super quick!
--Function for centroids w/in polygons from http://postgis.17.x6.nabble.com/Centroid-Within-td3518773.html
CREATE OR REPLACE FUNCTION point_inside_geometry(param_geom geometry)
  RETURNS geometry AS
$$
  DECLARE 
     var_cent geometry := ST_Centroid(param_geom); 
     var_result geometry := var_cent;
  BEGIN
  -- If the centroid is outside the geometry then 
  -- calculate a box around centroid that is guaranteed to intersect the geometry
  -- take the intersection of that and find point on surface of intersection
 IF NOT ST_Intersects(param_geom, var_cent) THEN
  var_result := ST_PointOnSurface(ST_Intersection(param_geom, ST_Expand(var_cent, ST_Distance(var_cent,param_geom)*2) ));
 END IF;
 RETURN var_result;
  END;
  $$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;

--DROP TABLE test.pluto_centr;

EXPLAIN ANALYZE
CREATE TABLE resultlayers.pluto_centroids AS
SELECT point_inside_geometry(mappluto_citywide.geom_2263) as geom_2263,
mappluto_citywide.bbl, mappluto_citywide.zonedist1, mappluto_citywide.landuse, mappluto_citywide.ownertype, mappluto_citywide.ownername
from staging.mappluto_citywide;

SELECT Populate_Geometry_Columns('resultlayers.pluto_centroids'::regclass);

CREATE INDEX pluto_centroids_gix ON resultlayers.pluto_centroids USING GIST(geom_2263);


EXPLAIN ANALYZE
CREATE TABLE resultlayers.compiled_lands_pluto_centroids AS
SELECT DISTINCT on (lands_compiled_B.gid_lands_compiled) lands_compiled_B.*, mappluto_citywide.bbl, mappluto_citywide.zonedist1, mappluto_citywide.landuse, mappluto_citywide.ownertype, mappluto_citywide.ownername
FROM resultlayers.lands_compiled_B left join resultlayers.pluto_centroids as mappluto_citywide on ST_Intersects(lands_compiled_B.geom_2263, mappluto_citywide.geom_2263);



DROP TABLE resultlayers.compiled_lands_pluto_ipis_colp_final_centr;

CREATE TABLE resultlayers.compiled_lands_pluto_ipis_colp_final_centr AS
SELECT  DISTINCT ON (compiled_lands_pluto_centroids.gid_lands_compiled) 
compiled_lands_pluto_centroids.*, 
colp_all_bbl.agency as colp_agency,
colp_all_bbl.usedesc as colp_use,
ipis."JURIS",
ipis."Jurisdiction.Description" as juris_desc,
ipis."RPAD_DESCRIPTION",
ipis."WATERFRONT" as ipis_waterfront,
ipis."Agency" as ipis_agency,
ipis."Owned.Leased" as owned_leased,
ipis."Primary.Use.Text" as ipis_use
FROM resultlayers.compiled_lands_pluto_centroids 
	LEFT JOIN staging.colp_all_bbl ON (compiled_lands_pluto_centroids.bbl = colp_all_bbl.bbl) 
	LEFT JOIN staging.ipis on (compiled_lands_pluto_centroids.bbl = ipis."BBL"::numeric) ;
--ORDER BY compiled_lands_pluto_b.bbl

CREATE INDEX compiled_lands_pluto_ipis_colp_final_centr_gix ON resultlayers.compiled_lands_pluto_ipis_colp_final_centr USING GIST(geom_2263);



