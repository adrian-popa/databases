USE PharmaciesDatabase

-- 1)

GO
IF OBJECT_ID('MedicinesPharmacies', 'U') IS NOT NULL
	DROP TABLE MedicinesPharmacies
IF OBJECT_ID('Pharmacies', 'U') IS NOT NULL
	DROP TABLE Pharmacies
IF OBJECT_ID('Medicines', 'U') IS NOT NULL
	DROP TABLE Medicines
IF OBJECT_ID('Prescriptions', 'U') IS NOT NULL
	DROP TABLE Prescriptions
IF OBJECT_ID('MedicalOffices', 'U') IS NOT NULL
	DROP TABLE MedicalOffices
GO

CREATE TABLE MedicalOffices (
	MOID tinyint PRIMARY KEY IDENTITY(1,1),
	Name varchar(100) UNIQUE,
	Address varchar(500)
);

CREATE TABLE Prescriptions (
	PrID smallint PRIMARY KEY IDENTITY(1,1),
	MOID tinyint REFERENCES MedicalOffices(MOID)
);

CREATE TABLE Medicines (
	MID smallint PRIMARY KEY IDENTITY(1,1),
	MName varchar(100),
	MExpiryDate date,
	PrID smallint REFERENCES Prescriptions(PrID)
);

CREATE TABLE Pharmacies (
	PhID smallint PRIMARY KEY IDENTITY(1,1),
	PhName varchar(100),
	PhAddress varchar(500)
);

CREATE TABLE MedicinesPharmacies (
	MID smallint REFERENCES Medicines(MID),
	PhID smallint REFERENCES Pharmacies(PhID),
	LastPurchased date,
	PRIMARY KEY(MID, PhID)
);

GO

-- 2)

CREATE OR ALTER PROC removePrescriptionsOfMedicalOffice
	@MOName varchar(100)
AS
	DECLARE @MOID tinyint = (SELECT MOID
							 FROM MedicalOffices
							 WHERE Name = @MOName)
	
	IF @MOID IS NULL
	BEGIN
		RAISERROR('no such medical office', 16, 1)
		RETURN -1
	END

	DELETE FROM Prescriptions
	WHERE MOID = @MOID
GO

INSERT MedicalOffices
VALUES ('mo1', 'moAddress 1'), ('mo2', 'moAddress 2')

INSERT Prescriptions
VALUES (1), (1), (2), (1), (2)

INSERT Medicines
VALUES ('m1', '06-12-2020', 1), ('m2', '06-13-2020', 2), ('m3', '06-14-2020', 1)

INSERT Pharmacies
VALUES ('ph1', 'phAddress 1'), ('ph2', 'phAddress 2')

GO

SELECT * FROM MedicalOffices
SELECT * FROM Prescriptions
SELECT * FROM Medicines
SELECT * FROM Pharmacies

GO

EXEC removePrescriptionsOfMedicalOffice 'mo2'

SELECT * FROM Prescriptions

GO

-- 3)

INSERT MedicinesPharmacies
VALUES (1, 2, '01-10-2020'), (2, 1, '01-11-2020'), (2, 2, '01-12-2020'), (3, 2, '01-13-2020')

SELECT * FROM MedicinesPharmacies

GO

CREATE OR ALTER VIEW vMedicinesInAllPharmacies
AS 
	SELECT M.MName
	FROM Medicines M
	WHERE NOT EXISTS (
		SELECT P.PhID
		FROM Pharmacies P
		EXCEPT
		SELECT MP.PhID
		FROM MedicinesPharmacies MP
		WHERE MP.MID = M.MID
	)

GO

SELECT * FROM vMedicinesInAllPharmacies

GO

-- 4)

CREATE OR ALTER FUNCTION ufFilterMedicinesByPharmacies
	(@D date, @P int)
	
	RETURNS TABLE
	RETURN
		SELECT M.MName
		FROM Medicines M
		WHERE M.MExpiryDate > @D AND M.MID IN (
			SELECT MP.MID
			FROM MedicinesPharmacies MP
			GROUP BY MP.MID
			HAVING COUNT(*) >= @P
		)
GO

SELECT * FROM ufFilterMedicinesByPharmacies('06-12-2020', 2)
