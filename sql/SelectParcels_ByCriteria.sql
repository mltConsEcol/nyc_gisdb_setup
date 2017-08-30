--Select parcels based on criteria:
SELECT * FROM citywide_basedata.parcels15
WHERE (ownertype like 'C' or ownertype like 'O')
and borough like 'SI'


--Working to do difference clip of borough vs parcels
SELECT
	ST_INTERSECTS(boroughs_nowater.geom_2263, parcels15.geom_2263) as test_intersect,
	GeometryType(ST_Difference(boroughs_nowater.geom_2263, parcels15.geom_2263))
FROM citywide_basedata.boroughs_nowater, citywide_basedata.parcels15
WHERE boroughs_nowater.borough like 'SI'