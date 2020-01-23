USE Testing

CREATE TABLE Planet (
	PlanetID int NOT NULL,
	CONSTRAINT PK_Planet PRIMARY KEY(PlanetID)
);

CREATE TABLE Rocket (
	RocketID int NOT NULL,
	CONSTRAINT PK_Rocket PRIMARY KEY(RocketID),
	PlanetID INT REFERENCES Planet(PlanetID)
);

CREATE TABLE Mission (
	ShipID int NOT NULL,
	LocationID int NOT NULL,
	CONSTRAINT PK_Mission PRIMARY KEY(ShipID, LocationID)
);

GO 
CREATE VIEW ViewPlanet
AS 
	SELECT * FROM Planet

GO
CREATE OR ALTER VIEW ViewRocket
AS 
	SELECT Rocket.RocketID
	FROM Rocket INNER JOIN Mission ON Rocket.RocketID = Mission.ShipID

GO
CREATE OR ALTER VIEW ViewMission
AS 
	SELECT Mission.LocationID
	FROM Mission INNER JOIN Planet ON Planet.PlanetID = Mission.LocationID
	GROUP BY LocationID
GO

-- Tables (Name)
DELETE FROM Tables;

INSERT INTO Tables
VALUES ('Planet'), ('Rocket'), ('Mission');

-- Views (Name)
DELETE FROM Views;

INSERT INTO Views
VALUES ('ViewPlanet'), ('ViewRocket'), ('ViewMission');

-- Tests (Name)
DELETE FROM Tests;

INSERT INTO Tests
VALUES ('insertPlanet'), ('deletePlanet'), ('insertRocket'), ('deleteRocket'), ('insertMission'), ('deleteMission'), ('evaluateViews');

SELECT * FROM Tables;
SELECT * FROM Views;
SELECT * FROM Tests;

-- TestTables (TestID, TableID, NoOfRows, Position) 
DELETE FROM TestTables;

INSERT INTO TestTables
VALUES (1, 1, 1000, 1),
	   (3, 2, 1000, 2),
	   (5, 3, 1000, 3);

SELECT * FROM TestTables;

-- TestViews (TestID, ViewID) 
DELETE FROM TestViews;

INSERT INTO TestViews
VALUES (7, 1),
	   (7, 2),
	   (7, 3);

SELECT * FROM TestViews;

-- Define test procedures
GO
CREATE OR ALTER PROC insertPlanet
AS 
	DECLARE @currentRow INT = 1
	DECLARE @noOfRows INT
	SELECT @noOfRows = NoOfRows FROM TestTables WHERE TestId = 1
	WHILE @currentRow <= @noOfRows 
	BEGIN 
		INSERT INTO Planet VALUES (@currentRow * 2)
		SET @currentRow = @currentRow + 1 
	END 

GO 
CREATE OR ALTER PROC deletePlanet
AS 
	DELETE FROM Planet WHERE PlanetID > 2;

GO 
CREATE OR ALTER PROC insertRocket
AS 
	DECLARE @currentRow INT = 1
	DECLARE @noOfRows INT
	SELECT @noOfRows = NoOfRows FROM TestTables WHERE TestId = 3
	WHILE @currentRow <= @noOfRows 
	BEGIN 
		INSERT INTO Rocket VALUES (@currentRow, 2)
		SET @currentRow = @currentRow + 1 
	END 

GO 
CREATE OR ALTER PROC deleteRocket 
AS 
	DELETE FROM Rocket;

GO
CREATE OR ALTER PROC insertMission
AS 
	DECLARE @currentRow INT = 1
	DECLARE @noOfRows INT
	SELECT @noOfRows = NoOfRows FROM TestTables WHERE TestId = 5
	WHILE @currentRow <= @noOfRows 
	BEGIN 
		INSERT INTO Mission VALUES (@currentRow, @currentRow)
		SET @currentRow = @currentRow + 1 
	END 

GO 
CREATE OR ALTER PROC deleteMission
AS 
	DELETE FROM Mission;
GO

-- executeTestRunTables
GO
CREATE OR ALTER PROC executeTestRunTables
AS 
	DECLARE @start1 DATETIME;
	DECLARE @end1 DATETIME;
	DECLARE @start2 DATETIME;
	DECLARE @end2 DATETIME;
	DECLARE @start3 DATETIME;
	DECLARE @end3 DATETIME;
	DECLARE @start4 DATETIME;
	DECLARE @end4 DATETIME;
	DECLARE @start5 DATETIME;
	DECLARE @end5 DATETIME;
	DECLARE @start6 DATETIME;
	DECLARE @end6 DATETIME;

	SET @start1 = GETDATE();
	PRINT('inserting data into Planet')
	EXEC insertPlanet;
	SET @end1 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_insert_planet', @start1, @end1);
	INSERT INTO TestRunTables VALUES (@@IDENTITY, 1, @start1, @end1);

	SET @start2 = GETDATE();
	PRINT('deleting data from Planet')
	EXEC deletePlanet;
	SET @end2 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_delete_planet', @start2, @end2);
	INSERT INTO TestRunTables VALUES (@@IDENTITY, 1, @start2, @end2);

	SET @start3 = GETDATE();
	PRINT('inserting data into Rocket')
	EXEC insertRocket;
	SET @end3 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_insert_rocket', @start3, @end3);
	INSERT INTO TestRunTables VALUES (@@IDENTITY, 2, @start3, @end3);

	SET @start4 = GETDATE();
	PRINT('deleting data from Rocket')
	EXEC deleteRocket;
	SET @end4 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_delete_rocket', @start4, @end4);
	INSERT INTO TestRunTables VALUES (@@IDENTITY, 2, @start4, @end4);

	SET @start5 = GETDATE();
	PRINT('inserting data into Mission')
	EXEC insertMission;
	SET @end5 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_insert_mission', @start5, @end5);
	INSERT INTO TestRunTables VALUES (@@IDENTITY, 3, @start5, @end5);

	SET @start6 = GETDATE();
	PRINT('deleting data from Mission')
	EXEC deleteMission;
	SET @end6 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_delete_mission', @start6, @end6);
	INSERT INTO TestRunTables VALUES (@@IDENTITY, 3, @start6, @end6);

-- executeTestRunViews
GO
CREATE OR ALTER PROC executeTestRunViews
AS 
	DECLARE @start1 DATETIME;
	DECLARE @end1 DATETIME;
	DECLARE @start2 DATETIME;
	DECLARE @end2 DATETIME;
	DECLARE @start3 DATETIME;
	DECLARE @end3 DATETIME;
	
	SET @start1 = GETDATE();
	PRINT ('executing SELECT * FROM Planet..')
	EXEC ('SELECT * FROM ViewPlanet');
	SET @end1 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_viewPlanet', @start1, @end1)
    INSERT INTO TestRunViews VALUES (@@IDENTITY, 1, @start1, @end1);

	SET @start2 = GETDATE();
	PRINT ('executing SELECT * FROM Rocket..')
	EXEC ('SELECT * FROM ViewRocket');
	SET @end2 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_viewRocket', @start2, @end2)
    INSERT INTO TestRunViews VALUES (@@IDENTITY, 2, @start2, @end2);

	SET @start3 = GETDATE();
	PRINT ('executing SELECT * FROM Mission..')
	EXEC ('SELECT * FROM ViewMission');
	SET @end3 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_viewMission', @start3, @end3)
    INSERT INTO TestRunViews VALUES (@@IDENTITY, 3, @start3, @end3);
GO

EXEC executeTestRunTables;
EXEC executeTestRunViews;

SELECT * FROM TestRuns;
SELECT * FROM TestRunTables;
SELECT * FROM TestRunViews;

DELETE FROM Planet;
DELETE FROM Rocket;
DELETE FROM Mission;

DELETE FROM TestRunViews;
DELETE FROM TestRunTables;
DELETE FROM TestRuns;
