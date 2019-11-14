-- insert data – for at least 4 tables; at least one statement should violate referential integrity constraints;

INSERT INTO MorphologyType
VALUES (1, 'elliptical'),
	   (2, 'spiral'),
	   (3, 'lenticular');

INSERT INTO Galaxy
VALUES (1, 'Milky Way', 1.15e+12, 2),
	   (2, 'Andromeda', 1.5e+12, 2),
	   (3, 'Centaurus A', 1e+9, 1),
	   (4, 'Spindle Galaxy', 3.85e+9, 3);

INSERT INTO PlanetarySystem
VALUES (1, 'Sun', 4.572, '-', 1),
	   (2, 'YZ Ceti', 4, 'Cetus', 1),
	   (3, 'Upsilon Andromedae', 3.781, 'Andromeda', 2),
	   (4, 'HD 113538', 1.278, 'Centaurus', 3),
	   (5, '83 Leonis', 4.486, 'Leo', 4),
	   (6, 'HD 213453', 1.734, 'Centaurus', 3);

INSERT INTO Star
VALUES (1, 'Sirius', 'A1V', 2.02, 'oxygen–nitrogen mixture', 1, 1),
	   (2, 'Algol', 'A2G', 3.14, 'nitrogen-oxygen mixture', 2, 3),
	   (3, 'Arcturus', 'T3T', 2.57, 'carbon–nitrogen mixture', 2, 2),
	   (4, 'Altair', 'A2B', 1.75, 'sulphur-oxygen mixture', 3, 4);
	   -- (5, 'Pollux', 'G3H', 3.73, 'sulphur-nitrogen mixture', 7);
	   -- The Star entry with ID 5 violates referential integrity constraints
	   -- There is no entry in the table PlanetarySystem with ID 7

INSERT INTO PlanetType
VALUES (1, 'rocky habitable planet'),
	   (2, 'dry red planet');

INSERT INTO Planet
VALUES (1, 'Earth', 1, 12742, 5.972e+24, 'nitrogen-oxygen mixture', 1, 1),
	   (2, 'Mars', 2, 6779, 6.39e+23, 'carbon-dioxide-nitrogen mixture', 1, 2);

INSERT INTO Rocket
VALUES (1, 'Falcon 9', 'LOX / RP-1'),
	   (2, 'Falcon Heavy', 'Subcooled LOX / Chilled RP-1');

INSERT INTO Astronaut
VALUES (1, 'Neil', 'Armstrong', '1930-08-05', 'M', 2);

INSERT INTO Mission
VALUES (1, 2, 2, 80);

INSERT INTO Engine
Values (1, '9 Merlin 1D');

INSERT INTO Propulsion
Values (1, 1, 1),
	   (2, 2, 1);

-- update data – for at least 3 tables;

UPDATE Galaxy 
SET Mass = 1.3e+12
WHERE GalaxyID = 3;

UPDATE Galaxy 
SET Mass = 1.45e+12
WHERE (GalaxyID = 3 AND Morphology = 1);

UPDATE Galaxy
SET Mass = 1.55e+12
WHERE (GalaxyID = 3 OR Name = 'Andromeda');

UPDATE Galaxy 
SET Name = 'Milky Way'
WHERE NOT Mass = 1.45e+12;

UPDATE PlanetarySystem 
SET Name = 'HD 113538'
WHERE PlanetarySystemID <> 4;

UPDATE PlanetarySystem 
SET Name = '83 Leonis' 
WHERE PlanetarySystemID > 3;

UPDATE PlanetarySystem 
SET Name = 'Sun'
WHERE PlanetarySystemID <= 1;

UPDATE PlanetarySystem
SET Location = 'Andromeda'
WHERE Age >= 3;

UPDATE PlanetarySystem 
SET Location = 'Centaurus'
WHERE Age < 2;

UPDATE Star 
SET Type = 'K3G'
WHERE ChemicalComposition IS NOT NULL;

-- delete data – for at least 2 tables.

DELETE FROM Star
WHERE StarID BETWEEN 4 and 7;

DELETE FROM PlanetarySystem
WHERE Name IN ('83 Leonis', '88 Taurus', 'Cento 3B');

DELETE FROM PlanetarySystem
WHERE Name LIKE '%HD%';

-- SELECT queries:

-- a. 2 queries with the union operation; use UNION [ALL] and OR;

-- Get the IDs of all Rockets that had or didn't have a misson.
SELECT RocketID
FROM Rocket
UNION
SELECT RocketID
FROM Mission;

-- Get the IDs of the Galaxies named 'Andromeda' or 'Centaurus A';
SELECT GalaxyID
FROM Galaxy
WHERE (Name = 'Andromeda' OR Name = 'Centaurus A');

-- b. 2 queries with the intersection operation; use INTERSECT and IN;

-- Get the IDs of the Rockets that had at least a mission.
SELECT RocketID 
FROM Rocket
INTERSECT
SELECT RocketID
FROM Mission;

-- Get only the IDs of Galaxies which belong to the Morphology Types with IDs 1 and 2.
SELECT GalaxyID 
FROM Galaxy
WHERE Morphology IN (1, 2);

-- c. 2 queries with the difference operation; use EXCEPT and NOT IN;

-- Get the IDs of the Rockets that didn't have any mission.
SELECT RocketID
FROM Rocket
EXCEPT
SELECT RocketID
FROM Mission;

-- Get the IDs of the Galaxies that don't belong in either of the Morphology Types with IDs 1 and 2.
SELECT GalaxyID 
FROM Galaxy
WHERE Morphology NOT IN (1, 2);

-- d. 4 queries with INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL JOIN; one query will join at least 3 tables, while another one will join at least two many-to-many relationships;

-- Inner join on 3 tables.
SELECT Galaxy.Name, PlanetarySystem.Name, Star.Name
FROM Star
INNER JOIN Galaxy
ON Galaxy.GalaxyID = Star.GalaxyID
INNER JOIN PlanetarySystem
ON PlanetarySystem.PlanetarySystemID = Star.PlanetarySystemID;

-- Left join.
SELECT Mission.PlanetID, Propulsion.RocketID, Propulsion.EngineID
FROM Mission
LEFT JOIN Propulsion
ON Mission.RocketID = Propulsion.RocketID;

-- Right join.
SELECT Mission.PlanetID, Propulsion.RocketID, Propulsion.EngineID
FROM Mission
RIGHT JOIN Propulsion
ON Mission.RocketID = Propulsion.RocketID;

-- Top 3 full join.
SELECT TOP 3 Mission.PlanetID, Propulsion.RocketID, Propulsion.EngineID 
FROM Mission
FULL JOIN Propulsion ON Mission.RocketID = Propulsion.RocketID;

-- e. 2 queries using the IN operator to introduce a subquery in the WHERE clause; in at least one query, the subquery should include a subquery in its own WHERE clause;

-- Get the Type of the Rockets that were used in a Mission towards the Planet with ID 2.
SELECT R.Type
FROM Rocket R
WHERE R.RocketID IN (
	SELECT M.RocketID
	FROM Mission M
	WHERE M.PlanetID = 2
);

-- Get the Type of the Rockets having a PropellantType of 'Subcooled LOX / Chilled RP-1', that was also used in a Mission towards the Planet with ID 2.
SELECT R.Type
FROM Rocket R
WHERE R.RocketID IN (
	SELECT R.RocketID
	FROM Rocket R
	WHERE R.PropellantType = 'Subcooled LOX / Chilled RP-1' AND R.RocketID IN (
		SELECT M.RocketID
		FROM Mission M
		WHERE M.PlanetID = 2
	)
);

-- f. 2 queries using the EXISTS operator to introduce a subquery in the WHERE clause;

-- Get the Type of the Rockets used by the Astronaut with ID 1.
SELECT R.Type
FROM Rocket R
WHERE EXISTS (
	SELECT *
	FROM Astronaut A
	WHERE A.AstronautID = 1 AND A.RocketID = R.RocketID
);

-- Get the ID and Type of the Rockets that were used in a Mission towards the Planet with ID 2 or have a PropellantType of 'LOX / RP-1'.
SELECT R.RocketID, R.Type
FROM Rocket R
WHERE EXISTS (
	SELECT *
	FROM Mission M
	WHERE (M.RocketID = R.RocketID AND M.PlanetID = 2) OR R.PropellantType = 'LOX / RP-1'
);

-- g. 2 queries with a subquery in the FROM clause;

-- Get all the Rockets that were used in a Mission towards the Planet with ID 2.
SELECT R.*
FROM Rocket R
INNER JOIN (
	SELECT * 
	FROM Mission M
	WHERE M.PlanetID = 2
) as X
ON R.RocketID = X.RocketID;

-- Get all the Rockets that have as Propulsion the Engine with ID 1.
SELECT R.*
FROM Rocket R
INNER JOIN
	(SELECT *
	FROM Propulsion P
	WHERE P.EngineID = 1
) as X 
ON R.RocketID = X.RocketID;

-- h. 4 queries with the GROUP BY clause, 3 of which also contain the HAVING clause; 2 of the latter will also have a subquery in the HAVING clause; use the aggregation operators: COUNT, SUM, AVG, MIN, MAX;

-- Get the Age of the youngest PlanetarySystem in each Galaxy.
SELECT PS.GalaxyID, MIN(PS.Age) LowestAge
FROM PlanetarySystem PS
GROUP BY PS.GalaxyID;

-- Get the IDs of the Rockets with the most successful Missions.
SELECT M.RocketID, COUNT(*) NoOfMissions
FROM Mission M
GROUP BY M.RocketID
HAVING COUNT(*)= (
	SELECT MAX(NoOfMissions)
	FROM (
		SELECT COUNT(*) NoOfMissions
		FROM Mission M
		GROUP BY M.RocketID
	) T
);
	
-- Get all the IDs of the Galaxies which have at least two PlanetarySystems.
SELECT PS.GalaxyID, COUNT(PS.GalaxyID) NumOfPlanetarySystems
FROM PlanetarySystem PS
GROUP BY PS.GalaxyID
HAVING COUNT(PS.GalaxyID) >= 2
ORDER BY NumOfPlanetarySystems DESC

-- Get all the Stars which are heavier than the average.
SELECT S.Mass
FROM Star S
GROUP BY S.Mass
HAVING S.Mass > (
	SELECT AVG(S.Mass) AvgMass
	FROM Star S
);

-- i. 4 queries using ANY and ALL to introduce a subquery in the WHERE clause; 2 of them should be rewritten with aggregation operators, while the other 2 should also be expressed with [NOT] IN.

-- Get the Names of the PlanetarySystems whose Age is greater than any of the PlanetarySystems from the Galaxy with ID 2, sorted in alphabetical order.
SELECT TOP 2 PS.Name
FROM PlanetarySystem PS
WHERE PS.Age > ANY (
	SELECT PS2.Age
	FROM PlanetarySystem PS2
	WHERE PS2.GalaxyID = 2
)
ORDER BY PS.Name;

-- Rewritten with aggregation operators - MIN, sorted in reversed order by Age.
SELECT PS.Name, PS.Age
FROM PlanetarySystem PS
WHERE PS.Age > (
	SELECT MIN(PS2.Age)
	FROM PlanetarySystem PS2
	WHERE PS2.GalaxyID = 2
)
ORDER BY PS.Age DESC;

-- Get the Names of the Stars whose Mass is smaller than any of the Stars from the PlanetarySystem with ID 3.
SELECT S.Name
FROM Star S
WHERE S.Mass < ANY (
	SELECT S2.Mass
	FROM Star S2
	WHERE S2.PlanetarySystemID = 3
);

-- Rewritten with aggregation operators - MAX.
SELECT S.Name
FROM Star S
WHERE S.Mass < (
	SELECT MAX(S2.Mass)
	FROM Star S2
	WHERE S2.PlanetarySystemID = 3
);

-- Get the Names of the PlanetarySystems whose Location is equal to the one of the PlanetarySystem with the Name 'HD 113538',
SELECT DISTINCT PS.Name
FROM PlanetarySystem PS
WHERE PS.Location = ALL (
	SELECT PS2.Location 
	FROM PlanetarySystem PS2
	WHERE PS2.Name = 'HD 113538'
);

-- Rewritten with IN.
SELECT DISTINCT PS.Name
FROM PlanetarySystem PS
WHERE PS.Location IN (
	SELECT PS2.Location 
	FROM PlanetarySystem PS2
	WHERE PS2.Name = 'HD 113538'
);

-- Get the Names of the Stars whose Mass is different than the one of the Star with a ChemicalComposition of 'carbon–nitrogen mixture'.
SELECT DISTINCT S.Name
FROM Star S
WHERE S.Mass <> ANY (
	SELECT S2.Mass
	FROM Star S2
	WHERE S2.ChemicalComposition = 'carbon–nitrogen mixture'
);

-- Rewritten with NOT IN.
SELECT DISTINCT S.Name
FROM Star S
WHERE S.Mass NOT IN (
	SELECT S2.Mass
	FROM Star S2
	WHERE S2.ChemicalComposition = 'carbon–nitrogen mixture'
);

-- DANGER ZONE: erase all tables
DELETE FROM Propulsion;
DELETE FROM Engine;
DELETE FROM Mission;
DELETE FROM Rocket;
DELETE FROM Planet;
DELETE FROM PlanetType;
DELETE FROM Star;
DELETE FROM PlanetarySystem;
DELETE FROM Galaxy;
DELETE FROM MorphologyType;