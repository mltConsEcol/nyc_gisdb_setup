-- Select Entity, Agency, Category, and Waterfront from all desired layers and compile them into single layer
-- in this verion, pluto clipped to land
CREATE TABLE resultlayers.lands_compiled AS (
SELECT 
fed_nps_nodpr_nostate_land.geom_2263 as geom_2263, 
fed_nps_nodpr_nostate_land.status::text as entity,
fed_nps_nodpr_nostate_land.status::text as agency,
'NA'::text as Category,
'NA'::text as Waterfront
from resultlayers.fed_nps_nodpr_nostate_land WHERE fed_nps_nodpr_nostate_land.geom_2263 NOTNULL

UNION

SELECT 
dpr_land.clipped_geom as geom_2263, 
'CITY'::text as entity,
'DPR'::text as agency,
dpr_land.Typecatego::text as Category,
dpr_land.Waterfront::text as Waterfront
from resultlayers.dpr_land WHERE dpr_land.clipped_geom NOTNULL

UNION

SELECT 
state_land_nodpr.geom_2263 as geom_2263, 
'STATE'::text as entity,
state_land_nodpr.owner1::text as agency,
'NA'::text as Category,
'NA'::text as Waterfront
from resultlayers.state_land_nodpr WHERE state_land_nodpr.geom_2263 NOTNULL

UNION

SELECT 
mappluto_noknowns_land.geom_2263 as geom_2263, 
'UNK'::text as entity,
'UNK'::text as agency,
'NA'::text as Category,
'NA'::text as Waterfront
from resultlayers.mappluto_noknowns_land WHERE mappluto_noknowns_land.geom_2263 NOTNULL

);

SELECT Populate_Geometry_Columns('resultlayers.lands_compiled'::regclass);

CREATE INDEX lands_compiled_gix ON resultlayers.lands_compiled USING GIST(geom_2263);

ALTER TABLE resultlayers.lands_compiled ADD COLUMN gid_lands_compiled BIGSERIAL PRIMARY KEY;



-- Select Entity, Agency, Category, and Waterfront from all desired layers and compile them into single layer
--VERSION B - pluto not clipped to land
CREATE TABLE resultlayers.lands_compiled_B AS (
SELECT 
fed_nps_nodpr_nostate_land.geom_2263 as geom_2263, 
fed_nps_nodpr_nostate_land.status::text as entity,
fed_nps_nodpr_nostate_land.status::text as agency,
'NA'::text as Category,
'NA'::text as Waterfront
from resultlayers.fed_nps_nodpr_nostate_land WHERE fed_nps_nodpr_nostate_land.geom_2263 NOTNULL

UNION

SELECT 
dpr_land.clipped_geom as geom_2263, 
'CITY'::text as entity,
'DPR'::text as agency,
dpr_land.Typecatego::text as Category,
dpr_land.Waterfront::text as Waterfront
from resultlayers.dpr_land WHERE dpr_land.clipped_geom NOTNULL

UNION

SELECT 
state_land_nodpr.geom_2263 as geom_2263, 
'STATE'::text as entity,
state_land_nodpr.owner1::text as agency,
'NA'::text as Category,
'NA'::text as Waterfront
from resultlayers.state_land_nodpr WHERE state_land_nodpr.geom_2263 NOTNULL

UNION

SELECT 
mappluto_noknowns.geom_2263 as geom_2263, 
'UNK'::text as entity,
'UNK'::text as agency,
'NA'::text as Category,
'NA'::text as Waterfront
from resultlayers.mappluto_noknowns WHERE mappluto_noknowns.geom_2263 NOTNULL

);

SELECT Populate_Geometry_Columns('resultlayers.lands_compiled_B'::regclass);

CREATE INDEX lands_compiled_B_gix ON resultlayers.lands_compiled_B USING GIST(geom_2263);

ALTER TABLE resultlayers.lands_compiled_B ADD COLUMN gid_lands_compiled BIGSERIAL PRIMARY KEY;