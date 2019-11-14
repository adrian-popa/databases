-- a. modify the type of a column;

-- Version no. 1.

GO
CREATE OR ALTER PROCEDURE PROC1 AS
BEGIN 
	ALTER TABLE Mission
	ALTER COLUMN Duration bigint NOT NULL;
END;

EXEC PROC1;

GO
CREATE OR ALTER PROCEDURE REVERT_PROC1 AS
BEGIN
	ALTER TABLE Mission
	ALTER COLUMN Duration float NOT NULL;
END;

EXEC REVERT_PROC1;

-- b. add / remove a column;

-- Version no. 2.

GO
CREATE OR ALTER PROCEDURE PROC2 AS
BEGIN 
	ALTER TABLE Engine
	ADD Series varchar(16);
END;

EXEC PROC2;

GO
CREATE OR ALTER PROCEDURE REVERT_PROC2 AS
BEGIN
	ALTER TABLE Engine
	DROP COLUMN Series;
END;

EXEC REVERT_PROC2;

-- c. add / remove a DEFAULT constraint;

-- Version no. 3.

GO
CREATE OR ALTER PROCEDURE PROC3 AS
BEGIN
	ALTER TABLE Star
	ADD CONSTRAINT DEFAULT_Star_Name DEFAULT 'HD' FOR Name;
END;

EXEC PROC3;

GO
CREATE OR ALTER PROCEDURE REVERT_PROC3 AS
BEGIN 
	ALTER TABLE Star
	DROP CONSTRAINT DEFAULT_Star_Name;
END;

EXEC REVERT_PROC3;

-- d. add / remove a primary key;

-- Version no. 4.

GO 
CREATE OR ALTER PROCEDURE PROC4 AS
BEGIN 
	ALTER TABLE Propulsion
	DROP CONSTRAINT PK_Propulsion;
END;

EXEC PROC4;

GO
CREATE OR ALTER PROCEDURE REVERT_PROC4 AS
BEGIN 
	ALTER TABLE Propulsion
	ADD CONSTRAINT PK_Propulsion PRIMARY KEY (PropulsionID);
END;

EXEC REVERT_PROC4;

-- e. add / remove a candidate key;

-- Version no. 5.

GO
CREATE OR ALTER PROCEDURE PROC5 AS 
BEGIN 
	ALTER TABLE Engine
	ADD CONSTRAINT UNIQUE_Engine_ID_Type UNIQUE (EngineID, Type);
END;

EXEC PROC5;

GO
CREATE OR ALTER PROCEDURE REVERT_PROC5 AS
BEGIN 
	ALTER TABLE Engine
	DROP CONSTRAINT UNIQUE_Engine_ID_Type;
END;

EXEC REVERT_PROC5;

-- f. add / remove a foreign key;

-- Version no. 6.

GO
CREATE OR ALTER PROCEDURE PROC6 AS
BEGIN
	ALTER TABLE Planet
	ADD CONSTRAINT FK_StarPlanet FOREIGN KEY (StarID) REFERENCES Star(StarID);
END;

EXEC PROC6;

GO
CREATE OR ALTER PROCEDURE REVERT_PROC6 AS
BEGIN 
	ALTER TABLE Planet
	DROP CONSTRAINT FK_StarPlanet;
END;

EXEC REVERT_PROC6;

-- g. create / remove a table.

-- Version no. 7.

GO
CREATE OR ALTER PROCEDURE PROC7 AS
BEGIN
	CREATE TABLE Asteroid (
		AsteroidID int NOT NULL PRIMARY KEY,
		Name varchar(64) NOT NULL,
		Mass float,
		PlanetarySystemID int REFERENCES PlanetarySystem(PlanetarySystemID)
	);
END;

EXEC PROC7;

GO
CREATE OR ALTER PROCEDURE REVERT_PROC7 AS
BEGIN 
	DROP TABLE IF EXISTS Asteroid;
END;

EXEC REVERT_PROC7;

-- Create DatabaseVersion table.

CREATE TABLE DatabaseVersion (
	CurrentVersion int
);

INSERT INTO DatabaseVersion VALUES (0);

-- Procedure for changing the version of the database.

GO
CREATE OR ALTER PROCEDURE CHANGE_DB_VERSION
	@version int AS
BEGIN
	DECLARE @currentVersion int
	DECLARE @procedureName nvarchar(32)
	
	SET @currentVersion = (
		SELECT DV.CurrentVersion
		FROM DatabaseVersion DV
	)

	IF @version >= 0 AND @version <= 7
	BEGIN
		IF @version > @currentVersion
		BEGIN
			WHILE @currentVersion < @version
			BEGIN
				SET @currentVersion = @currentVersion + 1
				SET @procedureName = 'PROC' + CAST(@currentVersion AS varchar(2))
				EXEC @procedureName
			END
		END
		ELSE
		BEGIN
			WHILE @currentVersion > @version AND @currentVersion != 0
			BEGIN
				SET @procedureName = 'REVERT_PROC' + CAST(@currentVersion AS varchar(2))
				EXEC @procedureName
				SET @currentVersion = @currentVersion - 1
			END
		END
		UPDATE DatabaseVersion SET CurrentVersion = @version
		RETURN
	END	
	ELSE
	BEGIN
		PRINT 'Invalid version number (should be between 0 and 7).'
		RETURN
	END
END;

EXEC CHANGE_DB_VERSION 0;

SELECT * FROM DatabaseVersion;