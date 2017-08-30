--Calculate number of pixels from land cover with each class, per parcel
CREATE TABLE resultstbls.lc_parcel AS
  SELECT
    gid_citywide, (value_count).value, SUM((value_count).count) AS count
  FROM
    (
    SELECT
      gid_citywide,
      rid,
      ST_ValueCount(
        ST_Union(ST_Clip(rast, geom_2263, TRUE)), 1, FALSE, ARRAY[1, 2, 3, 4, 5, 6, 7]
              ) value_count
    FROM
      (SELECT gid_citywide, geom_2263 FROM citywide_basedata.parcels15) v,
      (SELECT rid, rast FROM staging.landcover3ft_2010) r
    WHERE ST_Intersects(rast, geom_2263)
    GROUP BY gid_citywide, rid, geom_2263
    ) i
  GROUP BY gid_citywide, value
  ORDER BY gid_citywide, value ;