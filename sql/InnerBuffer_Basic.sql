--Keeps all original data from table
CREATE TABLE testbuf2 AS (
	select test2.*,
	st_buffer(test2.geom_2263, -4) 
	from public.test2
	)
	
--Only contains the new geom
select st_buffer(test2.geom_2263, -4) into testbuf1
from public.test2;