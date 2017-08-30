--CLip out water from DPR Properties
--DROP TABLE resultlayers.dpr_land;
SELECT gid, gispropnum, typecatego, waterfront, clipped_geom into resultlayers.dpr_land
FROM (SELECT p.gid,p.gispropnum, p.typecatego,p.waterfront, ST_Intersection(boroughs_nowater.geom_2263, p.geom_2263) As clipped_geom
FROM staging.boroughs_nowater, staging.dpr_properties p
WHERE ST_Intersects(boroughs_nowater.geom_2263, p.geom_2263))as foo; 


CREATE INDEX dpr_land_gix ON resultlayers.dpr_land USING GIST(clipped_geom);

SELECT Populate_Geometry_Columns('resultlayers.dpr_land'::regclass);

ALTER TABLE resultlayers.dpr_land
    ALTER COLUMN clipped_geom TYPE geometry(Multipolygon, 2263) USING ST_Multi(clipped_geom);

	
--CLip out water from Federal Properties	
--DROP TABLE resultlayers.fed_nps_land;
SELECT gid, status, ownership, clipped_geom into resultlayers.fed_nps_land
FROM (SELECT fed_nps_properties_2263.gid,fed_nps_properties_2263.status, fed_nps_properties_2263.ownership, ST_Intersection(boroughs_nowater.geom_2263, fed_nps_properties_2263.geom_2263) As clipped_geom
FROM staging.boroughs_nowater, staging.fed_nps_properties_2263
WHERE ST_Intersects(boroughs_nowater.geom_2263, fed_nps_properties_2263.geom_2263) AND (fed_nps_properties_2263.status like 'FED' OR fed_nps_properties_2263.status like 'OTFED'))as foo; 

CREATE INDEX fed_nps_land_gix ON resultlayers.fed_nps_land USING GIST(clipped_geom);

SELECT Populate_Geometry_Columns('resultlayers.fed_nps_land'::regclass);

ALTER TABLE resultlayers.fed_nps_land
    ALTER COLUMN clipped_geom TYPE geometry(Multipolygon,2263) USING ST_Multi(clipped_geom);
	

--Clip out water from State Properties	
--DROP TABLE resultlayers.state_land;
SELECT ogc_fid, owner1, owner2, clipped_geom into resultlayers.state_land
FROM (SELECT p.ogc_fid, p.owner1, p.owner2, ST_Intersection(boroughs_nowater.geom_2263, p.geom_2263) As clipped_geom
FROM staging.boroughs_nowater, staging.nys_tax_parcels_state_2263 p
WHERE ST_Intersects(boroughs_nowater.geom_2263, p.geom_2263)) as foo; 


CREATE INDEX state_land_gix ON resultlayers.state_land USING GIST(clipped_geom);

SELECT Populate_Geometry_Columns('resultlayers.state_land'::regclass);

ALTER TABLE resultlayers.state_land
    ALTER COLUMN clipped_geom TYPE geometry(Multipolygon,2263) USING ST_Multi(clipped_geom);
	
	
--Remove all knowns from PLUTO
----Combine All Knowns
SELECT test_geom into test.testgeom
FROM(
	SELECT dpr_land.clipped_geom as test_geom FROM resultlayers.dpr_land
	UNION ALL
	SELECT fed_nps_land.clipped_geom as test_geom FROM resultlayers.fed_nps_land
	UNION ALL
	SELECT state_land.clipped_geom as test_geom FROM resultlayers.state_land) as FOO
--union all shapes
SELECT st_union(testgeom.geomtest) into test.testgeomunion from test.testgeom 

--failing attempts
-- After running these, to view, need to run 
--------ALTER TABLE test.postlunch_diff9 ALTER COLUMN diffgeom SET DATA TYPE geometry;

SELECT * INTO test.mapplutodiff FROM(
	SELECT ST_Difference(testgeom.geomtest, testgeomunion.st_union)) as foo
	--FROM resultlayers.dpr_land, resultlayers.fed_nps_land, resultlayers.state_land) as FOO

--------anither failed attempt
SELECT * INTO test.postlunch_diff FROM(
SELECT b.gid,  COALESCE(ST_Difference(a.st_union,ST_Union(b.geom_2263)),a.st_union)
 As newgeom  FROM test.testgeomunion a  LEFT JOIN staging.mappluto_citywide b ON ST_Intersects(a.st_union, b.geom_2263) GROUP BY b.gid, a.st_union) as foo; 


 --From this page:  http://gis.stackexchange.com/questions/11592/difference-between-two-layers-in-postgis
--An attempt at difference clip that does something, but not what is desired
explain analyze
SELECT * INTO test.postlunch_diff3 FROM(
SELECT b.gid,  COALESCE(ST_Difference(a.geomtest,ST_Union(b.geom_2263)),a.geomtest)
 As newgeom  FROM test.testgeom a  LEFT JOIN staging.mappluto_citywide b ON ST_Intersects(a.geomtest, b.geom_2263) where b.borough like 'SI' GROUP BY b.gid, a.geomtest) as foo; 
 
 
 --
 explain analyze
SELECT * INTO test.postlunch_diff6  FROM(
SELECT COALESCE(ST_Difference(a.geomtest, b.geom_2263), b.geom_2263) As diffgeom 
FROM test.testgeom a LEFT JOIN staging.mappluto_citywide b  ON ST_Intersects(a.geomtest, b.geom_2263) where b.borough like 'SI') as foo;

explain analyze
SELECT * INTO test.postlunch_diff10  FROM(
SELECT ST_Difference(b.geom_2263, a.geomtest) As diffgeom 
FROM test.testgeom a LEFT JOIN staging.mappluto_citywide b  ON ST_Intersects(a.geomtest, b.geom_2263) where b.borough like 'SI') as foo;


explain analyze
SELECT * INTO test.postlunch_diff12 FROM(
SELECT ST_Difference(a.geomtest, b.geom_2263) 
FROM test.testgeom a JOIN staging.mappluto_citywide b ON ST_Intersects(a.geomtest, b.geom_2263) 
UNION 
SELECT a.geomtest 
FROM test.testgeom a JOIN staging.mappluto_citywide b ON NOT ST_Intersects(a.geomtest, b.geom_2263) ) as foo



http://gis.stackexchange.com/questions/50399/how-best-to-fix-a-non-noded-intersection-problem-in-postgis