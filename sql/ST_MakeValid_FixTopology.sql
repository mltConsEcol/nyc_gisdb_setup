--Attempt to clean topology issues. Can check for topology issues with 'ST_IsValid' and similar
update citywide_basedata.parcels15
set geom_2263 = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom_2263), 3));
