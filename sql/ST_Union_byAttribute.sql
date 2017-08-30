--Union features dataset by attribute
DROP TABLE test_union_owner;
CREATE TABLE test_union_owner AS
SELECT ownertype,
ST_UNION(parcels15.geom_2263)
FROM citywide_basedata.parcels15
WHERE borough like 'SI'
GRoup By ownertype