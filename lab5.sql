USE IndexingDatabase

GO

IF OBJECT_ID('Tc', 'U') IS NOT NULL
	DROP TABLE Tc
IF OBJECT_ID('Tb', 'U') IS NOT NULL
	DROP TABLE Tb
IF OBJECT_ID('Ta', 'U') IS NOT NULL
	DROP TABLE Ta
GO

CREATE TABLE Ta (
	aid int PRIMARY KEY IDENTITY(1,1),
	a2 int UNIQUE
)

CREATE TABLE Tb (
	bid int PRIMARY KEY IDENTITY(1,1),
	b2 int 
)

CREATE TABLE Tc (
	cid int PRIMARY KEY IDENTITY(1,1),
	aid int REFERENCES Ta(aid), 
	bid int REFERENCES Tb(bid)
)

INSERT INTO Ta
VALUES (5), (7), (-13), (35), (1), (0)

INSERT INTO Tb
VALUES (12), (7), (3), (3), (-25)

INSERT INTO Tc
VALUES (1, 1), (1, 2), (1, 3), (2, 2), (3, 3), (4, 4), (4, 5), (5, 5)

SELECT * FROM Ta
SELECT * FROM Tb
SELECT * FROM Tc

-- a)

-- clustered index scan

SELECT *
FROM  Ta 
WHERE a2 < 3
ORDER BY aid ASC

-- clustered index seek

SELECT * 
FROM Ta 
WHERE aid > 2

-- nonclustered index scan

SELECT *
FROM Ta 
ORDER BY a2

-- nonclustered index seek

SELECT aid 
FROM Ta 
WHERE a2 = 1

-- b)

GO

IF INDEXPROPERTY(OBJECT_ID('Tb'), 'Idx_NC_b2', 'IndexId') IS NOT NULL
	DROP INDEX Idx_NC_b2 ON Tb

SELECT *
FROM Tb 
WHERE b2 = 3

CREATE NONCLUSTERED INDEX Idx_NC_b2 ON Tb(b2)

SELECT *
FROM Tb 
WHERE b2 = 3

-- c)

GO

CREATE OR ALTER VIEW idxView
AS 
	SELECT *
	FROM Ta a
	INNER JOIN Tb b ON a.a2 = b.b2
GO

SELECT * FROM idxView
