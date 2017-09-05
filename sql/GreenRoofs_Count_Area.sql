select count(distinct(nycbldgs_201708.bin)) from infrastructure.nycbldgs_201708, test.greenroof_footprints
where st_intersects(nycbldgs_201708.geom_2263, greenroof_footprints.geom_2263)

select count(distinct(foo.bin)) as bldgs, boroughs_nowater.boroname from
(select nycbldgs_201708.bin, nycbldgs_201708.geom_2263 from infrastructure.nycbldgs_201708, test.greenroof_footprints
where st_intersects(nycbldgs_201708.geom_2263, greenroof_footprints.geom_2263)) as foo, staging.boroughs_nowater 
where st_intersects(foo.geom_2263, boroughs_nowater.geom_2263)
GROUP BY boroname


select distinct(nycbldgs_201708.bin), sum(st_area(greenroof_footprints.geom_2263)/43605) as area from infrastructure.nycbldgs_201708, test.greenroof_footprints
where st_intersects(nycbldgs_201708.geom_2263, greenroof_footprints.geom_2263)
group by bin order by area desc

select distinct(boroughs_nowater.boroname), sum(st_area(greenroof_footprints.geom_2263)/43605) as gr_area, st_area(boroughs_nowater.geom_2263)/43605 as boro_area from staging.boroughs_nowater, test.greenroof_footprints
where st_intersects(boroughs_nowater.geom_2263, greenroof_footprints.geom_2263)
group by boroname, boro_area order by gr_area desc