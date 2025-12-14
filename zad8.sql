--zmieniono ograniczenia w powershellu bo inaczej było przeciążenie
--wgrano wszystkie rastry (extension postgis i postgis_raster już były w bazie)
CREATE TABLE uk_lake_district AS --przyciecie rastra uk_250k do Lake District
    SELECT
        ST_Clip(r.rast,p.geom,true) AS rast
FROM
    uk_250k_2 AS r ,
    national_parks_clipped AS p
WHERE
    p.id = 1
    AND ST_Intersects(r.rast,p.geom);

CREATE TABLE sentinel_g_clipped AS --przyciecie pasma zielonego sentinela do Lake District
SELECT
    ST_Clip(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)), true) AS rast --wziecie pod uwage ze to sa dwa rózne układy
FROM 
    sentinel_g r,
    national_parks p
WHERE
    p.id = 1
    AND ST_Intersects(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)));

SELECT AddRasterConstraints('sentinel_g_clipped', 'rast'); --dodanie metadanych
CREATE INDEX sentinel_g_clipped_2 ON sentinel_g_clipped USING GIST (ST_ConvexHull(rast));

CREATE TABLE sentinel_nir_clipped AS --przyciecie pasam near infrared, tak jak wczesniej zielone
SELECT
    ST_Clip(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)), true) AS rast
FROM
    sentinel_nir r, -- Twoja tabela z zielenią
    national_parks p
WHERE
    p.id = 1
    AND ST_Intersects(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)));


SELECT AddRasterConstraints('sentinel_nir_clipped', 'rast');
CREATE INDEX sentinel_nir_clipped_2 ON sentinel_nir_clipped USING GIST (ST_ConvexHull(rast));
CREATE TABLE lake_district_ndwi AS --liczenie normalizej difference water index według wzoru
SELECT
    ST_SetSRID(
        ST_MapAlgebra(
            a.rast,
            b.rast,
            '([rast1] - [rast2]) / NULLIF([rast1] + [rast2], 0)::float'
        ),
        ST_SRID(a.rast) 
    ) AS rast
FROM
    sentinel_g_clipped a,
    sentinel_nir_clipped  b
WHERE
    ST_Intersects(a.rast, b.rast);

SELECT AddRasterConstraints('lake_district_ndwi', 'rast');
--sprawdzenie
select count(*) from lake_district_ndwi;
