USE TrainsDatabase

-- 1)

GO
IF OBJECT_ID('RoutesStations', 'U') IS NOT NULL
	DROP TABLE RoutesStations
IF OBJECT_ID('Stations', 'U') IS NOT NULL
	DROP TABLE Stations
IF OBJECT_ID('Routes', 'U') IS NOT NULL
	DROP TABLE Routes
IF OBJECT_ID('Trains', 'U') IS NOT NULL
	DROP TABLE Trains
IF OBJECT_ID('TrainTypes', 'U') IS NOT NULL
	DROP TABLE TrainTypes
GO

CREATE TABLE TrainTypes (
	TTID tinyint PRIMARY KEY IDENTITY(1,1),
	Description varchar(500)
);

CREATE TABLE Trains (
	TID smallint PRIMARY KEY IDENTITY(1,1),
	TName varchar(100),
	TTID tinyint REFERENCES TrainTypes(TTID)
);

CREATE TABLE Routes (
	RID smallint PRIMARY KEY IDENTITY(1,1),
	RName varchar(100) UNIQUE,
	TID smallint REFERENCES Trains(TID)
);

CREATE TABLE Stations (
	SID smallint PRIMARY KEY IDENTITY(1,1),
	SName varchar(100) UNIQUE
);

CREATE TABLE RoutesStations (
	RID smallint REFERENCES Routes(RID),
	SID smallint REFERENCES Stations(SID),
	Arrival time,
	Departure time,
	PRIMARY KEY(RID, SID)
);

GO

-- 2)

CREATE OR ALTER PROC uspStationOnRoute
	@RName varchar(100), @SName varchar(100),
	@Arrival time, @Dep time
AS
	DECLARE @RID smallint = (SELECT RID
							 FROM Routes
							 WHERE RName = @RName),
	@SID smallint = (SELECT SID
					 FROM Stations
					 WHERE SName = @SName)
	
	IF @RID IS NULL OR @SID IS NULL
	BEGIN
		RAISERROR('no such station / route', 16, 1)
		RETURN -1
	END

	IF EXISTS(SELECT * FROM RoutesStations
			  WHERE RID = @RID AND SID = @SID)
		UPDATE RoutesStations
		SET Arrival = @Arrival, Departure = @Dep
		WHERE RID = @RID AND SID = @SID
	ELSE
		INSERT RoutesStations (RID, SID, Arrival, Departure)
		VALUES (@RID, @SID, @Arrival, @Dep)
GO

INSERT TrainTypes
VALUES ('regio'), ('interregio')

INSERT Trains
VALUES ('t1', 1), ('t2', 1), ('t3', 1)

INSERT Stations
VALUES ('s1'), ('s2'), ('s3')

INSERT Routes
VALUES ('r1', 1), ('r2', 2), ('r3', 3)

SELECT * FROM TrainTypes
SELECT * FROM Trains
SELECT * FROM Stations
SELECT * FROM Routes

GO

EXEC uspStationOnRoute 'r1', 's1', '6:00', '6:10'
EXEC uspStationOnRoute 'r1', 's2', '6:15', '6:20'
EXEC uspStationOnRoute 'r1', 's3', '6:35', '6:40'
EXEC uspStationOnRoute 'r2', 's3', '6:35', '6:40'

SELECT * FROM RoutesStations

GO

-- 3)

CREATE OR ALTER VIEW vRoutesWithAllStations
AS 
	SELECT R.RName
	FROM Routes R
	WHERE NOT EXISTS (
		SELECT S.SID
		FROM Stations S
		EXCEPT
		SELECT RS.SID
		FROM RoutesStations RS
		WHERE RS.RID = R.RID
	)

GO

SELECT * FROM vRoutesWithAllStations

GO

-- 4)

CREATE OR ALTER FUNCTION ufFilterStations
	(@R int)
	
	RETURNS TABLE
	RETURN
		SELECT S.SName
		FROM Stations S
		WHERE S.SID IN (
			SELECT RS.SID
			FROM RoutesStations RS
			GROUP BY RS.SID
			HAVING COUNT(*) >= @R
		)
GO

SELECT * FROM ufFilterStations(2)
