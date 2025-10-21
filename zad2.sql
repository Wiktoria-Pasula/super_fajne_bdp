CREATE DATABASE spatialdb;
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE buildings (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  geom geometry(Polygon)
);

CREATE TABLE roads (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  geom geometry(LineString)
);

CREATE TABLE points (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  geom geometry(Points)
);


INSERT INTO buildings (name, geom) VALUES
('BuildingA', ST_GeomFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))')),
('BuildingB', ST_GeomFromText('POLYGON((6 7, 6 5, 4 5, 4 7, 6 7))')),
('BuildingC', ST_GeomFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))')),
('BuildingD', ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))')),
('BuildingF', ST_GeomFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))'));

INSERT INTO roads (name, geom) VALUES
('RoadX', ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)')),
('RoadY', ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)'));

INSERT INTO points (name, geom) VALUES
('G', ST_GeomFromText('POINT(1 3.5)')),
('H', ST_GeomFromText('POINT(5.5 1.5)')),
('I', ST_GeomFromText('POINT(9.5 6)')),
('J', ST_GeomFromText('POINT(6.5 6)')),
('K', ST_GeomFromText('POINT(6 9.5)'));

-- A suma dróg w mieście
SELECT SUM(ST_Length(geom)) AS total_road_length
FROM roads;

-- B pole powierzchni
SELECT
  ST_AsText(geom) AS wkt,
  ST_Area(geom) AS area,
  ST_Perimeter(geom) AS perimeter
FROM buildings
WHERE name = 'BuildingA';

-- C nazwy i pola powierzchni
SELECT name, ST_Area(geom) AS area, ST_Perimeter(geom) AS perimeter
FROM buildings
ORDER BY area DESC
LIMIT 2;

-- D nazwy i obwody
SELECT ST_Distance(b.geom, p.geom) AS distance
FROM buildings b
JOIN points p ON p.name = 'G'
WHERE b.name = 'BuildingC';

-- E najkrótsza odległość
SELECT b.*
FROM buildings b
CROSS JOIN roads r
WHERE r.name = 'RoadX'
  AND ST_Y(ST_Centroid(b.geom)) > ST_Y(ST_Centroid(r.geom));

-- F pole powierzchni BuildingC
SELECT ST_Area(
  ST_SymDifference(
    bc.geom,
    ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')
  )
) AS area_symdiff
FROM buildings bc
WHERE bc.name = 'BuildingC';
