CREATE DATABASE Lab1;

CREATE TABLE MorphologyType (
	MorphologyID int NOT NULL PRIMARY KEY,
	Type varchar(10) NOT NULL
)

CREATE TABLE Galaxy (
	GalaxyID int NOT NULL PRIMARY KEY,
	Name varchar(64) NOT NULL,
	Mass float,
	Morphology int REFERENCES MorphologyType(MorphologyID)
);

CREATE TABLE PlanetarySystem (
	PlanetarySystemID int NOT NULL PRIMARY KEY,
	Name varchar(64) NOT NULL,
	Age float,
	Location varchar(200),
	GalaxyID int REFERENCES Galaxy(GalaxyID)
);

CREATE TABLE Star (
	StarID int NOT NULL PRIMARY KEY,
	Name varchar(64) NOT NULL,
	Type varchar(64),
	Mass float,
	ChemicalComposition varchar(64),
	GalaxyID int REFERENCES Galaxy(GalaxyID),
	PlanetarySystemID int REFERENCES PlanetarySystem(PlanetarySystemID)
);

CREATE TABLE PlanetType (
	PlanetTypeID int NOT NULL PRIMARY KEY,
	Type varchar(64) NOT NULL
);

CREATE TABLE Planet (
	PlanetID int NOT NULL PRIMARY KEY,
	Name varchar(64) NOT NULL,
	Type int REFERENCES PlanetType(PlanetTypeID),
	EquatorialDiameter float,
	Mass float,
	Atmosphere varchar(64),
	PlanetarySystemID int REFERENCES PlanetarySystem(PlanetarySystemID)
);

CREATE TABLE NaturalSatellite (
	NaturalSatelliteID int NOT NULL PRIMARY KEY,
	Size float,
	PlanetID int REFERENCES Planet(PlanetID)
);

CREATE TABLE Rocket (
	RocketID int NOT NULL PRIMARY KEY,
	Type varchar(64),
	PropellantType varchar(64)
);

CREATE TABLE Astronaut (
	AstronautID int NOT NULL PRIMARY KEY,
	FirstName varchar(32),
	LastName varchar(32),
	DateOfBirth date,
	Gender char(1),
	RocketID int REFERENCES Rocket(RocketID)
);

CREATE TABLE Mission (
	MissionID int NOT NULL PRIMARY KEY,
	RocketID int REFERENCES Rocket(RocketID),
	PlanetID int REFERENCES Planet(PlanetID),
	Duration float NOT NULL
);

CREATE TABLE Engine (
	EngineID int NOT NULL PRIMARY KEY,
	Type varchar(64)
);

CREATE TABLE Propulsion (
	PropulsionID int NOT NULL PRIMARY KEY,
	RocketID int REFERENCES Rocket(RocketID),
	EngineID int REFERENCES Engine(EngineID)
)

-- Only for emergencies (DESTROY DB)
DROP TABLE Propulsion;
DROP TABLE Engine;
DROP TABLE Mission;
DROP TABLE Astronaut;
DROP TABLE Rocket;
DROP TABLE NaturalSatellite;
DROP TABLE Planet;
DROP TABLE PlanetType;
DROP TABLE Star;
DROP TABLE PlanetarySystem;
DROP TABLE Galaxy;
DROP TABLE MorphologyType;