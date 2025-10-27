CREATE EXTENSION IF NOT EXISTS postgis;

--SELECT * FROM warstwa_budynki2019 LIMIT 5; --tutaj sprawdzam czy mi sie cos w ogóle załadowało

--sprawdzam dane z roku 2019 ktore nie pokrywaja sie z 2018, takie geometrie są wtedy nowe/wyremontowane
--zad 1 czyli nowe_budynki to tabela zawierająca 
CREATE TABLE IF NOT EXISTS public.nowe_budynki AS
SELECT b2019.*
FROM public.warstwa_budynki2019 AS b2019
JOIN public.warstwa_budynki2018 AS b2018
  ON b2019.gid = b2018.gid
WHERE NOT ST_Equals(b2019.geom, b2018.geom);

CREATE TABLE IF NOT EXISTS public.nowe_poi AS
SELECT p2019.*
FROM public.warstwa_poi2019 AS p2019
LEFT JOIN public.warstwa_poi2018 AS p2018
  ON ST_Equals(p2019.geom, p2018.geom)
WHERE p2018.geom IS NULL;
--jest tez ST_DWithin(kolumna1,kolumna2,tolerancja dla róznicy w metrach)

CREATE TABLE IF NOT EXISTS public.nowe_poi_przy_budynkach AS
SELECT punkty.*
FROM public.nowe_poi AS punkty
JOIN public.nowe_budynki AS budynki
  ON ST_DWithin(punkty.geom, budynki.geom, 500);

--zad 2 kategoria czyli kolumna type
SELECT punkty.type, COUNT(*) AS liczba_poi
FROM public.nowe_poi_przy_budynkach AS punkty
GROUP BY punkty.type
ORDER BY liczba_poi DESC;

--zad 3 i sprawdzamy czy na pewno jest układ DHDN
CREATE TABLE IF NOT EXISTS public.streets_reprojected AS
SELECT gid, st_name, ST_Transform(geom,3068) as geom
FROM public.warstwa_ulice2019;

SELECT ST_SRID(geom) FROM public.streets_reprojected LIMIT 5;

--zad 4
CREATE TABLE IF NOT EXISTS public.nowe_punkty (
    id SERIAL PRIMARY KEY,
    geom geometry(Point, 4326)
);

INSERT INTO public.nowe_punkty (geom)
VALUES
    (ST_SetSRID(ST_MakePoint(8.36093, 49.03174), 4326)),
    (ST_SetSRID(ST_MakePoint(8.39876, 49.00644), 4326));

SELECT id, ST_AsText(geom) FROM public.nowe_punkty;

-- zad 5
ALTER TABLE public.nowe_punkty ADD COLUMN IF NOT EXISTS geom_3068 geometry(Point, 3068);

UPDATE public.nowe_punkty
SET geom_3068 = ST_Transform(geom, 3068);

SELECT id, ST_AsText(geom_3068) AS geom_dhdn
FROM public.nowe_punkty;

-- zad 6 tworzymy linię z punktów po tamtej reprojekcji
CREATE TABLE IF NOT EXISTS public.input_line AS
SELECT ST_MakeLine(geom_3068 ORDER BY id) AS geom
FROM public.nowe_punkty;

-- skrzyżowania w dobrym układzie
CREATE TABLE IF NOT EXISTS public.street_node2019_reprojected AS
SELECT gid, ST_Transform(geom, 3068) AS geom
FROM public.warstwa_street_node2019;

-- skrzyżowania 200m od linii
CREATE TABLE IF NOT EXISTS public.nodes_near_line AS
SELECT n.*
FROM public.street_node2019_reprojected AS n,
     public.input_line AS l
WHERE ST_DWithin(n.geom, l.geom, 200);

select * from warstwa_land_use_a2019;

-- zad7
CREATE TABLE IF NOT EXISTS public.sklepy_sport_blisko_parku AS
SELECT s.*
FROM public.warstwa_poi2019 AS s
JOIN public.warstwa_land_use_a2019 AS p
  ON ST_DWithin(ST_Transform(s.geom, 3068), ST_Transform(p.geom, 3068), 300)
WHERE s.type = 'Sporting Goods Store';

SELECT COUNT(*) AS liczba_sklepow
FROM public.sklepy_sport_blisko_parku;

