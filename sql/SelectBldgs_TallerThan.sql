--Select buildings > 20 stories into nycbldgsTall
SELECT staging.nycbldgs.* into staging.nycbldgsTall
FROM staging.nycbldgs
WHERE num_floors > 20;

--Select all buildings from Manhattan parcels that are taller than 20 floors
select nycbldgs.* into test2
from staging.nycbldgs, staging.manhattan_parcel15
where st_intersects (staging.nycbldgs.geom_2263, staging.manhattan_parcel15.geom_2263)
and nycbldgs.num_floors>20;