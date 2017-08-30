select concat(lpad(colp_all.block::text, 5, '0'), lpad(colp_all.lot::text, 5, '0')) from staging.colp_all

--Identify borocode per borough and order by borocode
SELECT DISTINCT(borough) , borocode
from staging.mappluto_citywide
 group by borough,  borocode
 ORDER BY borocode


--Thought this would work, but did not at all
/* ALTER TABLE staging.colp_all
ADD column bbl numeric;
INSERT INTO staging.colp_all (bbl)
SELECT 
	CONCAT(
			(CASE WHEN colp_all.boro LIKE 'MANHATTAN' THEN '1' 
				WHEN colp_all.boro like 'BRONX' THEN '2'
				WHEN colp_all.boro like 'BROOKLYN' THEN '3'
				WHEN colp_all.boro like 'QUEENS' THEN '4'
				WHEN colp_all.boro like 'STATEN ISLAND' THEN '5' END),--::text, 
		lpad(colp_all.block::text, 5, '0'), 
		lpad(colp_all.lot::text, 4, '0')) :: numeric
	FROM  staging.colp_all --as colp_all.bbl */
	
--CREATE NEW DATASET WITH COLUMN FOR BBL
SELECT * INTO staging.colp_all_bbl FROM(
SELECT *,
	CONCAT(
			(CASE WHEN colp_all.boro LIKE 'MANHATTAN' THEN '1' 
				WHEN colp_all.boro like 'BRONX' THEN '2'
				WHEN colp_all.boro like 'BROOKLYN' THEN '3'
				WHEN colp_all.boro like 'QUEENS' THEN '4'
				WHEN colp_all.boro like 'STATEN ISLAND' THEN '5' END),--::text, 
		lpad(colp_all.block::text, 5, '0'), 
		lpad(colp_all.lot::text, 4, '0'))::numeric as bbl
	FROM  staging.colp_all) as foo




