CREATE DATABASE firma;

\c firma;

CREATE SCHEMA ksiegowosc;
SET search_path TO ksiegowosc;

CREATE TABLE pracownicy (
    id_pracownika SERIAL PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    adres VARCHAR(100),
    telefon VARCHAR(20)
);
COMMENT ON TABLE pracownicy IS 'Dane pracowników małej firmy';

CREATE TABLE godziny (
    id_godziny SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    liczba_godzin INT CHECK (liczba_godzin >= 0),
    id_pracownika INT REFERENCES pracownicy(id_pracownika) ON DELETE CASCADE
);
COMMENT ON TABLE godziny IS 'Godziny pracy dla pracowników';

CREATE TABLE pensja (
    id_pensji SERIAL PRIMARY KEY,
    stanowisko VARCHAR(50),
    kwota NUMERIC(10,2) CHECK (kwota > 0)
);
COMMENT ON TABLE pensja IS 'Tabela z pensjami według stanowisk';


CREATE TABLE premia (
    id_premii SERIAL PRIMARY KEY,
    rodzaj VARCHAR(50),
    kwota NUMERIC(10,2) DEFAULT 0 CHECK (kwota >= 0)
);
COMMENT ON TABLE premia IS 'Rodzaje i wartości premii';

CREATE TABLE wynagrodzenie (
    id_wynagrodzenia SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    id_pracownika INT REFERENCES pracownicy(id_pracownika) ON DELETE CASCADE,
    id_godziny INT REFERENCES godziny(id_godziny) ON DELETE CASCADE,
    id_pensji INT REFERENCES pensja(id_pensji),
    id_premii INT REFERENCES premia(id_premii)
);
COMMENT ON TABLE wynagrodzenie IS 'Powiązanie między pensją, premią i pracownikiem';

--tutaj mam wygenerowane dane z chatgpt, żeby ręcznie nie wpisywać pokolei
INSERT INTO pracownicy (imie, nazwisko, adres, telefon) VALUES
('Jan', 'Nowak', 'Kraków', '123456789'),
('Anna', 'Kowalska', 'Warszawa', '234567890'),
('Piotr', 'Wiśniewski', 'Gdańsk', '345678901'),
('Julia', 'Nowicka', 'Poznań', '456789012'),
('Jakub', 'Lewandowski', 'Łódź', '567890123'),
('Ewa', 'Kamińska', 'Wrocław', '678901234'),
('Kamil', 'Zieliński', 'Lublin', '789012345'),
('Joanna', 'Kaczmarek', 'Kielce', '890123456'),
('Tomasz', 'Wójcik', 'Katowice', '901234567'),
('Natalia', 'Piotrowska', 'Rzeszów', '012345678');

INSERT INTO pensja (stanowisko, kwota) VALUES
('Kierownik', 4000),
('Specjalista', 3000),
('Asystent', 2000),
('Księgowy', 2500),
('Magazynier', 1800),
('Sprzedawca', 2200),
('Administrator', 3500),
('Analityk', 2700),
('Sekretarka', 1900),
('Stażysta', 1200);

INSERT INTO premia (rodzaj, kwota) VALUES
('Brak', 0),
('Uzysk', 300),
('Motywacyjna', 500),
('Specjalna', 800),
('Brak', 0),
('Brak', 0),
('Motywacyjna', 400),
('Uzysk', 200),
('Specjalna', 600),
('Brak', 0);

INSERT INTO godziny (data, liczba_godzin, id_pracownika) VALUES
('2025-01-31', 160, 1),
('2025-01-31', 165, 2),
('2025-01-31', 150, 3),
('2025-01-31', 172, 4),
('2025-01-31', 180, 5),
('2025-01-31', 158, 6),
('2025-01-31', 190, 7),
('2025-01-31', 162, 8),
('2025-01-31', 140, 9),
('2025-01-31', 175, 10);

INSERT INTO wynagrodzenie (data, id_pracownika, id_godziny, id_pensji, id_premii) VALUES
('2025-01-31', 1, 1, 1, 1),
('2025-01-31', 2, 2, 2, 2),
('2025-01-31', 3, 3, 3, 3),
('2025-01-31', 4, 4, 4, 4),
('2025-01-31', 5, 5, 5, 5),
('2025-01-31', 6, 6, 6, 6),
('2025-01-31', 7, 7, 7, 7),
('2025-01-31', 8, 8, 8, 8),
('2025-01-31', 9, 9, 9, 9),
('2025-01-31', 10, 10, 10, 10);
--A
SELECT id_pracownika, nazwisko FROM pracownicy;

--B
SELECT p.id_pracownika, pn.kwota
FROM pracownicy p
JOIN wynagrodzenie w USING (id_pracownika)
JOIN pensja pn USING (id_pensji)
WHERE pn.kwota > 1000;

--C
SELECT p.id_pracownika, pn.kwota, pr.kwota AS premia
FROM pracownicy p
JOIN wynagrodzenie w USING (id_pracownika)
JOIN pensja pn USING (id_pensji)
JOIN premia pr USING (id_premii)
WHERE pr.kwota = 0 AND pn.kwota > 2000;

--D
SELECT * FROM pracownicy WHERE imie ILIKE 'J%';

-- E
SELECT * FROM pracownicy
WHERE nazwisko ILIKE '%n%' AND imie ILIKE '%a';

--F
SELECT p.imie, p.nazwisko, (g.liczba_godzin - 160) AS nadgodziny
FROM pracownicy p
JOIN godziny g USING (id_pracownika)
WHERE g.liczba_godzin > 160;

-- G
SELECT p.imie, p.nazwisko, pn.kwota
FROM pracownicy p
JOIN wynagrodzenie w USING (id_pracownika)
JOIN pensja pn USING (id_pensji)
WHERE pn.kwota BETWEEN 1500 AND 3000;

-- H
SELECT p.imie, p.nazwisko
FROM pracownicy p
JOIN wynagrodzenie w USING (id_pracownika)
JOIN godziny g USING (id_pracownika)
JOIN premia pr USING (id_premii)
WHERE g.liczba_godzin > 160 AND pr.kwota = 0;

-- I
SELECT p.imie, p.nazwisko, pn.kwota
FROM pracownicy p
JOIN wynagrodzenie w USING (id_pracownika)
JOIN pensja pn USING (id_pensji)
ORDER BY pn.kwota;

-- J
SELECT p.imie, p.nazwisko, pn.kwota, pr.kwota AS premia
FROM pracownicy p
JOIN wynagrodzenie w USING (id_pracownika)
JOIN pensja pn USING (id_pensji)
JOIN premia pr USING (id_premii)
ORDER BY pn.kwota DESC, pr.kwota DESC;

-- K
SELECT pn.stanowisko, COUNT(*) AS liczba_pracownikow
FROM wynagrodzenie w
JOIN pensja pn USING (id_pensji)
GROUP BY pn.stanowisko;

-- L
SELECT 
    AVG(kwota) AS srednia,
    MIN(kwota) AS minimalna,
    MAX(kwota) AS maksymalna
FROM pensja
WHERE stanowisko = 'Kierownik';

--M
SELECT SUM(pn.kwota + pr.kwota) AS suma_wynagrodzen
FROM wynagrodzenie w
JOIN pensja pn USING (id_pensji)
JOIN premia pr USING (id_premii);

-- N
SELECT pn.stanowisko, SUM(pn.kwota + pr.kwota) AS suma
FROM wynagrodzenie w
JOIN pensja pn USING (id_pensji)
JOIN premia pr USING (id_premii)
GROUP BY pn.stanowisko;

-- O
SELECT pn.stanowisko, COUNT(pr.id_premii) AS liczba_premii
FROM wynagrodzenie w
JOIN pensja pn USING (id_pensji)
JOIN premia pr USING (id_premii)
GROUP BY pn.stanowisko;

-- P
DELETE FROM pracownicy
WHERE id_pracownika IN (
    SELECT id_pracownika
    FROM wynagrodzenie w
    JOIN pensja pn USING (id_pensji)
    WHERE pn.kwota < 1200
);

