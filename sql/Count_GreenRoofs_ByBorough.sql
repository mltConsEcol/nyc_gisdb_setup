--Count the number of greenroofs in borough based on borough code; next step would be to create table of number of greenroofs by borough; also need to figure out 
-- if only want to display, just run the inner query
SELECT COUNT (*) 
FROM  (
SELECT greenroof_go1_may3_2ksqftmin.*
FROM resultsvectorlayers.greenroof_go1_may3_2ksqftmin, citywide_basedata.boroughs_nowater
WHERE greenroof_go1_may3_2ksqftmin.propgrn > 10 --specify where propgrn is greater than 10%
AND ST_INTERSECTS(greenroof_go1_may3_2ksqftmin.geom, boroughs_nowater.geom_2263) --where the geometries intersect
AND boroughs_nowater.borocode = 1 --where borough code corresponds to manhattan
) AS FOO

--same as above but can use borough name
SELECT COUNT (*) FROM  (SELECT greenroof_go1_may3_2ksqftmin.*
FROM resultsvectorlayers.greenroof_go1_may3_2ksqftmin, citywide_basedata.boroughs_nowater
WHERE greenroof_go1_may3_2ksqftmin.propgrn > 10  
AND ST_INTERSECTS(greenroof_go1_may3_2ksqftmin.geom, boroughs_nowater.geom_2263)
AND boroughs_nowater.boroname::text LIKE 'Manhattan') AS FOO