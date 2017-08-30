--Difference Clip Polygons layer (Boroughs) by another layer (Parcels in this example)
--TESTING
Drop Table testing_diff2;
CREATE TABLE testing_diff2 AS
SELECT *
FROM (
SELECT  borough_clip.*,
 COALESCE(ST_Difference(borough_clip.geom_2263,ST_UNION(bldgs.geom_2263)),borough_clip.geom_2263) 
 FROM staging.borough_clip  LEFT JOIN staging.bldgs ON ST_Intersects(borough_clip.geom_2263, bldgs.geom_2263) 
 GROUP BY borough_clip.gid) as FOO;
 
 --REAL DATA
 CREATE TABLE testing_diff2 AS
SELECT  boroughs_nowater.*,
 COALESCE(ST_Difference(boroughs_nowater.geom_2263,ST_UNION(parcels15.geom_2263)),boroughs_nowater.geom_2263) 
 As newGeom FROM citywide_basedata.boroughs_nowater  LEFT JOIN citywide_basedata.parcels15 ON ST_Intersects(boroughs_nowater.geom_2263, parcels15.geom_2263) 
 WHERE boroughs_nowater.boroname like 'Staten Island'
 GROUP BY boroughs_nowater.gid



--This is neater! But might not get the data from both tables as appropriate
--TESTING
DROP TABLE testing_diff3;
CREATE TABLE testing_diff3 AS
SELECT gid, COALESCE(ST_Difference(geom_2263, (SELECT ST_UNION(b.geom_2263) 
                                         FROM staging.bldgs b
                                         WHERE ST_Intersects(a.geom_2263, b.geom_2263)
                                         )), a.geom_2263)
FROM staging.borough_clip a where boroname like 'Manhattan';

--REAL DATA
CREATE TABLE SI_Unclaimed AS
SELECT gid, COALESCE(ST_Difference(geom_2263, (SELECT ST_UNION(b.geom_2263) 
                                         FROM citywide_basedata.parcels15 b
                                         WHERE ST_Intersects(a.geom_2263, b.geom_2263)
                                         )), a.geom_2263)
FROM citywide_basedata.boroughs_nowater a where boroname like 'Staten Island';

----These linkss are helpful
--http://gis.stackexchange.com/questions/187406/how-to-use-st-difference-and-st-intersection-in-case-of-multipolygons-postgis/187575#187575
--http://www.ceus-now.com/postgis-difference-with-geometry-union/

----To add info about geometry columns
--http://gis.stackexchange.com/questions/115401/qgis-there-isnt-entry-in-geometry-columns
