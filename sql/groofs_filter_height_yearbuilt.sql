--Filter out buildings built after 2013 and roofs shorter than 35 
SELECT * 
INTO public.nycbldgs_buff_heightyr FROM public.nycbldgs_buff
WHERE cnstrct_yr < 2014 AND heightroof > 35;

	
--PART 2:
--count green and grass pixel percents using new buffered file
  SELECT gid, bin, geom_buff, count_green, count_grass, count_total, cnstrct_yr, heightroof,

(count_green::float/count_total::float)*100 as propgreen,

(count_grass::float/count_total::float)*100 as propgrass

INTO public.pctgrs_pctgrn_allroofs_buff_final2 --save to table of this name in public folder

FROM (

SELECT gid, bin, geom_buff, cnstrct_yr, heightroof,

--AddGeometryColumn(p, 'geom_buff',4326,'MULTIPOLYGON')
--SET ST_Buffer(p.geom_2263, -9.84252) as geom_buff,
--DropGeometryColumn(p, geom_2263),
 
--Count number of pixels per building with value 1 (grass/greenroofs)

   ST_CountAgg(

      ST_Reclass(

         ST_Clip(rast, p.geom_buff), --need to try different buffer lengths******

         1, '[1]:1, [2-5]:0', '8BUI', 0),

         1, TRUE)

         as count_grass,

--Count number of pixels per building with values 1 or 2 (grass/greenroofs & trees)

   ST_CountAgg(

      ST_Reclass(

         ST_Clip(rast, p.geom_buff),

         1, '[1-2]:1, [3-5]:0', '8BUI', 0),

         1, TRUE)

         as count_green,

--Count total number of pixels per building

   ST_CountAgg(

      ST_Clip(

        ST_Reclass(rast, 1, '[0-5]:1', '8BUI'), p.geom_buff),

         1, TRUE) -- exclude nodata from CountAgg 

         as count_total

 

   FROM staging.naip_ndvi_classified_2013 r, public.nycbldgs_buff_heightyr p

   WHERE ST_Intersects(r.rast, p.geom_buff)

   AND shape_area > 2000 --only buildings over 2000 sq ft, so will run faster

   group by gid, bin, geom_buff, cnstrct_yr, heightroof

) AS FOO;


--PART 3
SELECT * INTO public.groofs_threshold2_heightyr FROM public.pctgrs_pctgrn_allroofs_buff_final2
WHERE propgrass > 0.468 AND propgrass < 34.5;
