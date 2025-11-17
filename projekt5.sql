CREATE TABLE IF NOT EXISTS obiekty (
    id serial PRIMARY KEY,
    nazwa text,
    geom geometry
);

-- zad A
INSERT INTO obiekty (nazwa, geom)
VALUES (
    'obiekt1',
    ST_GeomFromEWKT(
        'SRID=0;
         COMPOUNDCURVE(
             (0 1, 1 1),
             CIRCULARSTRING(1 1, 2 0, 3 1),
             CIRCULARSTRING(3 1, 4 2, 5 1),
             (5 1, 6 1)
         )'
    )
);

-- zad B
INSERT INTO obiekty (nazwa, geom)
VALUES (
    'obiekt2',
    ST_GeomFromEWKT(
        'SRID=0;
         CURVEPOLYGON(
             COMPOUNDCURVE(
                 (10 6, 14 6),
                 CIRCULARSTRING(14 6, 16 4, 14 2),
                 CIRCULARSTRING(14 2, 12 0, 10 2),
                 (10 2, 10 6)
             ),
             COMPOUNDCURVE(
                 CIRCULARSTRING(11 2, 12 1, 13 2),
                 CIRCULARSTRING(13 2, 12 3, 11 2)
             )
         )'
    )
);

-- zad C
INSERT INTO obiekty (nazwa, geom)
VALUES (
    'obiekt3',
    ST_GeomFromEWKT(
        'SRID=0;
         POLYGON((
             7 15,
             10 17,
             12 13,
             7 15
         ))'
    )
);

-- zad D (POPRAWIONE)
INSERT INTO obiekty (nazwa, geom)
VALUES (
    'obiekt4',
    ST_GeomFromEWKT(
        'SRID=0;
         LINESTRING(
             20 20,
             25 25,
             27 24,
             25 22,
             26 21,
             22 19,
             20.5 19.5
         )'
    )
);

-- zad E
INSERT INTO obiekty (nazwa, geom)
VALUES (
    'obiekt5',
    ST_GeomFromEWKT(
        'SRID=0;
         MULTIPOINT Z(
             (30 30 59),
             (38 32 234)
         )'
    )
);

-- zad F
INSERT INTO obiekty (nazwa, geom)
VALUES (
    'obiekt6',
    ST_SetSRID(
        ST_GeomFromText(
            'GEOMETRYCOLLECTION(
                LINESTRING(1 1, 3 2),
                POINT(4 2)
            )'
        ),
        0
    )
);

-- zad 2 tutaj super
SELECT 
    ST_Area(
        ST_Buffer(
            ST_ShortestLine(o3.geom, o4.geom),
            5
        )
    ) AS pole_bufora
FROM obiekty o3, obiekty o4
WHERE o3.nazwa = 'obiekt3'
  AND o4.nazwa = 'obiekt4';

-- zad 3 dziala
UPDATE obiekty
SET geom = ST_MakePolygon(
                ST_AddPoint(
                    geom,
                    ST_StartPoint(geom)
                )
            )
WHERE nazwa = 'obiekt4';
--musi byc zamknieta geometria i miec przynajmniej 4 punkty 
-- zad 4 tutaj tez dziala
INSERT INTO obiekty (nazwa, geom)
SELECT 
    'obiekt7',
    ST_Collect(o3.geom, o4.geom)
FROM obiekty o3, obiekty o4
WHERE o3.nazwa = 'obiekt3'
  AND o4.nazwa = 'obiekt4';


--zad 5 a tutaj opinie są rozbieżne
SELECT 
    SUM(
        ST_Area(ST_Buffer(geom, 5))
    ) AS suma_powierzchni_buforow
FROM obiekty
WHERE GeometryType(geom) NOT IN (
    'CIRCULARSTRING',
    'COMPOUNDCURVE',
    'CURVEPOLYGON'
);
