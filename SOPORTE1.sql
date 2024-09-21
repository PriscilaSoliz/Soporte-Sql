-- Usar la base de datos temporal para operaciones preliminares
USE tempdb;
GO

-- Verificar si la base de datos existe y eliminarla si es necesario
IF EXISTS (SELECT name FROM master.sys.databases WHERE name = N'soporte_AERO')
BEGIN
    DROP DATABASE soporte_AERO;
END
GO

-- Crear la base de datos
CREATE DATABASE soporte_AERO;
GO

-- Usar la base de datos reci�n creada
USE soporte_AERO;
GO

------------------------------------------------------------------------
--------------------------TABLAS SIN FK---------------------------------

--------------------------------1---------------------------------------
-----------------LLenado de datos a traves de excel---------------------
--------------------select * from Customer------------------------------
-- Tabla Cliente
IF OBJECT_ID('Customer', 'U') IS NOT NULL 
DROP TABLE Customer;
GO

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    DateOfBirth DATE CHECK (DateOfBirth <= GETDATE() AND DateOfBirth >= DATEADD(YEAR, -100, GETDATE())),
    Name VARCHAR(200) NOT NULL
);
GO

-- Indice en la columna Name
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customer_Name')
BEGIN
	CREATE INDEX IX_Customer_Name ON Customer (Name);
END;

--------------------------------2---------------------------------------
--------------------select * from FineType------------------------------

-- Tabla TIPO DE MULTA
IF OBJECT_ID('FineType', 'U') IS NOT NULL 
DROP TABLE FineType;
GO

CREATE TABLE FineType (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(255) NOT NULL UNIQUE  --Exceso de equipaje, Cancelacion de vuelo, Cambio de vuelo
);
GO

--------------------------------3---------------------------------------
------------------select * from Status_Reserva--------------------------

IF OBJECT_ID('Status_Reserva', 'U') IS NOT NULL 
DROP TABLE Status_Reserva;
GO

CREATE TABLE Status_Reserva (
    StatusID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(255) NOT NULL UNIQUE,
    CONSTRAINT CHK_Status_Reserva_Name CHECK (Name IN ('Confirmada', 'Pendiente', 'Cancelada'))
);
GO

-- Crear un índice en la columna Name
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Status_Reserva_Name')
BEGIN
    CREATE INDEX IX_Status_Reserva_Name ON Status_Reserva (Name);
END;
GO

--------------------------------4---------------------------------------
------------------select * from CustomerCategory------------------------

-- Tabla CATEGORIA DEL CLIENTE
IF OBJECT_ID('CustomerCategory', 'U') IS NOT NULL 
    DROP TABLE CustomerCategory;
GO

CREATE TABLE CustomerCategory (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName VARCHAR(50) NOT NULL,
    CONSTRAINT CHK_CustomerCategory_Name CHECK (CategoryName IN ('Regular', 'Frecuente')) 
);
GO

-- Índice para la columna CategoryName
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_CustomerCategory_Name')
BEGIN
    CREATE INDEX IDX_CustomerCategory_Name ON CustomerCategory(CategoryName);
END;
GO

--------------------------------5---------------------------------------
-------------------select * from TicketCategory-------------------------

-- Tabla CATEGORIA DEL TICKET
IF OBJECT_ID('TicketCategory', 'U') IS NOT NULL 
    DROP TABLE TicketCategory;
GO

CREATE TABLE TicketCategory (
    CategoryID INT PRIMARY KEY IDENTITY(1,1), 
    CategoryName VARCHAR(50) NOT NULL, 
    CONSTRAINT CHK_TicketCategory_CategoryName CHECK (CategoryName IN ('Primera clase', 'Ejecutiva', 'Premium', 'Económica'))  
);
GO

-- Índice para la columna CategoryName
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_TicketCategory_CategoryName')
BEGIN
    CREATE INDEX IDX_TicketCategory_CategoryName ON TicketCategory(CategoryName);
END;
GO

--------------------------------6---------------------------------------
-------------------select * from CheckinLuggage-------------------------

-- Tabla FACTURAR EQUIPAJE
IF OBJECT_ID('CheckinLuggage', 'U') IS NOT NULL 
    DROP TABLE CheckinLuggage;
GO

CREATE TABLE CheckinLuggage (
    CheLuggaID INT PRIMARY KEY IDENTITY(1,1), 
    CategoryName VARCHAR(50) NOT NULL, 
    CONSTRAINT CHK_CheckinLuggage_CategoryName CHECK (CategoryName IN ('Maleta', 'Mochila', 'Bolsa', 'Otro')) 
);
GO

-- Índice para la columna CategoryName
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_CheckinLuggage_CategoryName')
BEGIN
    CREATE INDEX IDX_CheckinLuggage_CategoryName ON CheckinLuggage(CategoryName);
END;
GO

--------------------------------7---------------------------------------
---------------------select * from FlightStatus-------------------------

-- Tabla ESTADO DEL VUELO
IF OBJECT_ID('FlightStatus', 'U') IS NOT NULL 
    DROP TABLE FlightStatus;
GO

CREATE TABLE FlightStatus (
    ID INT PRIMARY KEY IDENTITY(1,1), 
    StatusName VARCHAR(50) NOT NULL,
    CONSTRAINT CHK_FlightStatus_StatusName CHECK (StatusName IN ('Programado', 'Retrasado', 'Cancelado', 'En Vuelo', 'Aterrizado')) 
);
GO

-- Índice para la columna StatusName
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_FlightStatus_StatusName')
BEGIN
    CREATE INDEX IDX_FlightStatus_StatusName ON FlightStatus(StatusName);
END;
GO

--------------------------------8---------------------------------------
------------------------select * from Role------------------------------

-- Tabla ROL
IF OBJECT_ID('Role', 'U') IS NOT NULL 
    DROP TABLE Role;
GO

CREATE TABLE Role (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName VARCHAR(50) NOT NULL,
    CONSTRAINT CHK_Role_RoleName CHECK (RoleName IN ('Piloto', 'Copiloto', 'Auxiliar de Vuelo', 'Mecánico', 'Administrador')) 
);
GO

-- Índice para la columna RoleName
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Role_RoleName')
BEGIN
    CREATE INDEX IDX_Role_RoleName ON Role(RoleName);
END;
GO

--------------------------------9---------------------------------------
----------------------select * from CrewMember--------------------------

-- Tabla MIEMBRO DE LA TRIPULACION
IF OBJECT_ID('CrewMember', 'U') IS NOT NULL 
    DROP TABLE CrewMember;
GO

CREATE TABLE CrewMember (
    CrewMemberID INT PRIMARY KEY IDENTITY(1,1), 
    Name VARCHAR(100) NOT NULL, 
    Nationality VARCHAR(50) NOT NULL, 
    ExperienceYears INT NOT NULL CHECK (ExperienceYears >= 0) 
);
GO

-- Índice para la columna Nationality
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_CrewMember_Nationality')
BEGIN
    CREATE INDEX IDX_CrewMember_Nationality ON CrewMember(Nationality);
END;
GO

-------------------------------10---------------------------------------
-------------------select * from FlightCategory-------------------------

-- Tabla CATEGORIA DE VUELO
IF OBJECT_ID('FlightCategory', 'U') IS NOT NULL 
    DROP TABLE FlightCategory;
GO

CREATE TABLE FlightCategory (
    CategoryID INT PRIMARY KEY IDENTITY(1,1), 
    CategoryName VARCHAR(50) NOT NULL, 
    CONSTRAINT CHK_FlightCategory_CategoryName CHECK (CategoryName IN ('Nacional', 'Internacional')) 
);
GO

-- Índice para la columna CategoryName
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_FlightCategory_CategoryName')
BEGIN
    CREATE INDEX IDX_FlightCategory_CategoryName ON FlightCategory(CategoryName);
END;
GO

-------------------------------11---------------------------------------
---------------------select * from PlaneModel---------------------------

-- Tabla MODELO DE AVION
IF OBJECT_ID('PlaneModel', 'U') IS NOT NULL 
DROP TABLE PlaneModel;
GO

CREATE TABLE PlaneModel (
    PlaneModelID INT PRIMARY KEY IDENTITY(1,1),
    Description VARCHAR(255) NOT NULL,
    Graphic VARBINARY(MAX)
);
GO

-- índice para el campo Description
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PlaneModel_Description')
BEGIN
    CREATE INDEX IX_PlaneModel_Description ON PlaneModel (Description);
END;

-- Crear índice para el campo PlaneModelID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PlaneModel_PlaneModelID')
BEGIN
    CREATE INDEX IX_PlaneModel_PlaneModelID ON PlaneModel (PlaneModelID);
END;

-------------------------------12---------------------------------------
------------------select * from PaymentMetthod--------------------------

-- Tabla METODO DE PAGO
IF OBJECT_ID('PaymentMetthod', 'U') IS NOT NULL 
DROP TABLE PaymentMetthod;
GO

CREATE TABLE PaymentMetthod (
    ID INT PRIMARY KEY IDENTITY(1,1),
    PaymentMetthodName VARCHAR(50) NOT NULL CHECK (PaymentMetthodName IN ('Tarjeta', 'Efectivo', 'Qr')),
    Description VARCHAR(255) NOT NULL
);
GO

-------------------------------13---------------------------------------
-----------------LLenado de datos a traves de excel---------------------
---------------------select * from Country------------------------------

-- Tabla PAIS
IF OBJECT_ID('Country', 'U') IS NOT NULL 
DROP TABLE Country;
GO

CREATE TABLE Country (
    CountryID INT PRIMARY KEY IDENTITY(1,1),
    CountryName VARCHAR(100) NOT NULL UNIQUE
);
GO

-- índice para el campo CountryID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Country_CountryID')
BEGIN
    CREATE INDEX IX_Country_CountryID ON Country (CountryID);
END;

-- índice para el campo CountryName
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Country_CountryName')
BEGIN
    CREATE INDEX IX_Country_CountryName ON Country (CountryName);
END;

------------------------------------------------------------------------
----------------------------TABLAS CON FK-------------------------------

-------------------------------14---------------------------------------

-- Tabla TARJETA DE VIAJERO FRECUENTE
IF OBJECT_ID('FrequentFlyerCard', 'U') IS NOT NULL 
DROP TABLE FrequentFlyerCard;
GO

CREATE TABLE FrequentFlyerCard (
    FFCNumber INT PRIMARY KEY,
    Miles INT CHECK (Miles >= 0),
    MealCode VARCHAR(50) NOT NULL CHECK (MealCode IN ('A', 'B', 'C')),
	CustomerID INT NULL,
    CONSTRAINT FK_FrequentFlyerCard_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE SET NULL
);
GO

-- Indice PARA FFCNumberID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FrequentFlyerCard_FFCNumber')
BEGIN
    CREATE INDEX IX_FrequentFlyerCard_FFCNumber ON FrequentFlyerCard (FFCNumber);
END;


-------------------------------15---------------------------------------

-- Tabla ASIGNACION DEL CLIENTE
IF OBJECT_ID('C_Assignment', 'U') IS NOT NULL 
    DROP TABLE C_Assignment;
GO

CREATE TABLE C_Assignment (
   AssigID INT PRIMARY KEY IDENTITY(1,1),
   CustomerID INT NOT NULL,
   CategoryID INT, 
   CONSTRAINT FK_C_Assignment_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
       ON DELETE CASCADE ON UPDATE CASCADE, 
   CONSTRAINT FK_C_Assignment_CustomerCategory FOREIGN KEY (CategoryID) REFERENCES CustomerCategory(CategoryID)
       ON DELETE SET NULL 
);
GO

-- Índices para CustomerID y CategoryID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_C_Assignment_CustomerID')
BEGIN
    CREATE INDEX IDX_C_Assignment_CustomerID ON C_Assignment(CustomerID);
END;
GO
-- Índices para CategoryID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_C_Assignment_CategoryID')
BEGIN
    CREATE INDEX IDX_C_Assignment_CategoryID ON C_Assignment(CategoryID);
END;
GO

-------------------------------16---------------------------------------

-- Tabla AVION 
IF OBJECT_ID('Airplane', 'U') IS NOT NULL 
DROP TABLE Airplane;
GO

CREATE TABLE Airplane (
    AirplaneID INT PRIMARY KEY IDENTITY(1,1),
    RegistrationNumber VARCHAR(50) NOT NULL UNIQUE,
    BeginOfOperation DATE NOT NULL,
    Status VARCHAR(50) NOT NULL CHECK (Status IN ('Operativo', 'Mantenimiento', 'Inactivo')),
    PlaneModID INT NULL,
    CONSTRAINT FK_Airplane_PlaneModel FOREIGN KEY (PlaneModID) REFERENCES PlaneModel(PlaneModelID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
GO

-- índice para RegistrationNumber
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Airplane_RegistrationNumber')
BEGIN
    CREATE INDEX IX_Airplane_RegistrationNumber ON Airplane (RegistrationNumber);
END;

-- índice para PlaneModID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Airplane_PlaneModID')
BEGIN
    CREATE INDEX IX_Airplane_PlaneModID ON Airplane (PlaneModID);
END;

-------------------------------17---------------------------------------

-- Tabla AEREOLINEA
IF OBJECT_ID('Airline', 'U') IS NOT NULL 
DROP TABLE Airline;
GO

CREATE TABLE Airline (
    AirlineID INT PRIMARY KEY IDENTITY(1,1),
										--cada aerolínea TIENE UN código que es asignado a cada aerolínea a nivel mundial.
    Name VARCHAR(100) NOT NULL,
	IATACode CHAR(2) UNIQUE NULL,       -- Código único IATA (2 letras)
										-- IATA (International Air Transport Association)
    ICAOCode CHAR(3) UNIQUE NULL,       -- Código único ICAO (3 letras)
										--ICAO (International Civil Aviation Organization)
    CONSTRAINT CK_Airline_AtLeastOneCode CHECK (
        IATACode IS NOT NULL OR ICAOCode IS NOT NULL -- Al menos UN CODIGO debe ser no nulo
    ),
	CountryID INT NULL,
    CONSTRAINT FK_Airplane_Country FOREIGN KEY (CountryID) REFERENCES Country(CountryID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
GO

-- Índice PARA Name
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Airline_Name')
BEGIN
    CREATE INDEX IX_Airline_Name ON Airline (Name);
END;
GO

-- Índice PARA IATACode
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Airline_IATACode')
BEGIN
    CREATE INDEX IX_Airline_IATACode ON Airline (IATACode);
END;
GO

-- Índice PARA ICAOCode
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Airline_ICAOCode')
BEGIN
    CREATE INDEX IX_Airline_ICAOCode ON Airline (ICAOCode);
END;
GO

-- Índice PARA CountryID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Airline_CountryID')
BEGIN
    CREATE INDEX IX_Airline_CountryID ON Airline (CountryID);
END;
GO

-------------------------------18---------------------------------------
-----------------LLenado de datos a traves de excel---------------------
----------------------select * from City--------------------------------

-- Tabla Ciudad 
IF OBJECT_ID('City', 'U') IS NOT NULL 
DROP TABLE City;
GO

CREATE TABLE City (
    CityID INT PRIMARY KEY IDENTITY(1,1),
    CityName VARCHAR(100) NOT NULL,
    CountryID INT,
    CONSTRAINT FK_City_Country FOREIGN KEY (CountryID) REFERENCES Country(CountryID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- índice para  el campo CityName
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_City_CityName')
BEGIN
    CREATE INDEX IX_City_CityName ON City (CityName);
END;

-------------------------------19---------------------------------------

-- Tabla AEROPUERTO
IF OBJECT_ID('Airport', 'U') IS NOT NULL 
DROP TABLE Airport;
GO

CREATE TABLE Airport (
    AirportID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL UNIQUE,
    CityID INT,
    CONSTRAINT FK_Airport_City FOREIGN KEY (CityID) REFERENCES City(CityID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
GO

-- índice para CityID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Airport_CityID')
BEGIN
    CREATE INDEX IX_Airport_CityID ON Airport (CityID);
END;

-- índice para Name
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Airport_Name')
BEGIN
    CREATE INDEX IX_Airport_Name ON Airport (Name);
END;

-------------------------------20---------------------------------------

-- Tabla NUEMERO DE VUELO
IF OBJECT_ID('FlightNumber', 'U') IS NOT NULL 
DROP TABLE FlightNumber;
GO

CREATE TABLE FlightNumber (
    FlightNumberID INT PRIMARY KEY IDENTITY(1,1),
    DepartureTime DATETIME NOT NULL,
    Description VARCHAR(255) NOT NULL,
    StartAirportID INT NOT NULL,
    GoalAirportID INT NULL,
    CONSTRAINT FK_FlightNumber_StartAirport FOREIGN KEY (StartAirportID) REFERENCES Airport(AirportID),
    CONSTRAINT FK_FlightNumber_GoalAirport FOREIGN KEY (GoalAirportID) REFERENCES Airport(AirportID)
       ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT CK_FlightNumber_Airports CHECK (StartAirportID <> GoalAirportID)
);
GO



-- índice para VER HORA DE SALIDA 
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FlightNumber_DepartureTime')
BEGIN
    CREATE INDEX IX_FlightNumber_DepartureTime ON FlightNumber (DepartureTime);
END;

-------------------------------21---------------------------------------

-- Tabla VUELO
IF OBJECT_ID('Flight', 'U') IS NOT NULL 
    DROP TABLE Flight;
GO

CREATE TABLE Flight (
    FlightID INT PRIMARY KEY IDENTITY(1,1), 
    BoardingTime TIME NOT NULL CHECK (BoardingTime >= CONVERT(TIME, GETDATE())), -- no puede ser en el pasado
    FlightDate DATE NOT NULL CHECK (FlightDate >= CONVERT(DATE, GETDATE())),     --no puede ser en el pasado
    Gate VARCHAR(50) NOT NULL,            
    CheckInCounter VARCHAR(50) NOT NULL,  
    FlightNumID INT NOT NULL, 
    AirlineID INT NULL, 
    CategoryID INT NULL, 
	PlaneModelID INT NULL,
    CONSTRAINT FK_Flight_FlightNumber FOREIGN KEY (FlightNumID) REFERENCES FlightNumber(FlightNumberID)
        ON DELETE CASCADE ON UPDATE CASCADE, 
    CONSTRAINT FK_Flight_Airline FOREIGN KEY (AirlineID) REFERENCES Airline(AirlineID)
		ON DELETE SET NULL,
    CONSTRAINT FK_Flight_FlightCategory FOREIGN KEY (CategoryID) REFERENCES FlightCategory(CategoryID)
		ON DELETE SET NULL,
	CONSTRAINT FK_Flight_PlaneModel FOREIGN KEY (PlaneModelID) REFERENCES PlaneModel(PlaneModelID)
       ON DELETE SET NULL ON UPDATE CASCADE,
);
GO

-- Índice PARA FlightDate
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Flight_FlightDate')
BEGIN
    CREATE INDEX IDX_Flight_FlightDate ON Flight(FlightDate);
END;
GO

-- Índice PARA FlightNumID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Flight_FlightNumID')
BEGIN
    CREATE INDEX IDX_Flight_FlightNumID ON Flight(FlightNumID);
END;
GO

-- Índice PARA AirlineID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Flight_AirlineID')
BEGIN
    CREATE INDEX IDX_Flight_AirlineID ON Flight(AirlineID);
END;
GO

-- Índice PARA PlaneModelID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Flight_PlaneModelID')
BEGIN
    CREATE INDEX IDX_Flight_PlaneModelID ON Flight(PlaneModelID);
END;
GO

-- Índice PARA CategoryID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Flight_CategoryID')
BEGIN
    CREATE INDEX IDX_Flight_CategoryID ON Flight(CategoryID);
END;
GO

-- Índice PARA FlightDate y FlightNumID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Flight_FlightDate_FlightNumID')
BEGIN
    CREATE INDEX IDX_Flight_FlightDate_FlightNumID ON Flight(FlightDate, FlightNumID);
END;
GO

-- Índice PARA Gate
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Flight_Gate')
BEGIN
    CREATE INDEX IDX_Flight_Gate ON Flight(Gate);
END;
GO

-- Índice PARA CheckInCounter
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Flight_CheckInCounter')
BEGIN
    CREATE INDEX IDX_Flight_CheckInCounter ON Flight(CheckInCounter);
END;
GO

-------------------------------22---------------------------------------

--  TABLA ESCALA
IF OBJECT_ID('Scale', 'U') IS NOT NULL 
DROP TABLE Scale;
GO

CREATE TABLE Scale (
    ScaleID INT PRIMARY KEY IDENTITY(1,1),
	StopoverDuration TIME NOT NULL CHECK (DATEPART(HOUR, StopoverDuration) * 60 + DATEPART(MINUTE, StopoverDuration) BETWEEN 30 AND 1440), 
    -- La duración se valida entre 30 minutos y 24 horas    
    FlightID INT,
	StartAirportID INT NOT NULL,
    GoalAirportID INT NULL,
	PlaneModelID INT NULL,
    CONSTRAINT FK_Scale_StartAirport FOREIGN KEY (StartAirportID) REFERENCES Airport(AirportID),
    CONSTRAINT FK_Scale_GoalAirport FOREIGN KEY (GoalAirportID) REFERENCES Airport(AirportID)
       ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT FK_Scale_Flight FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
        ON DELETE CASCADE,
	CONSTRAINT FK_Scale_PlaneModel FOREIGN KEY (PlaneModelID) REFERENCES PlaneModel(PlaneModelID)
       ON DELETE SET NULL ON UPDATE CASCADE
);
GO

-- Índice PARA FlightID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Scale_FlightID')
BEGIN
    CREATE INDEX IDX_Scale_FlightID ON Scale(FlightID);
END;
GO

-- Índice PARA StartAirportID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Scale_StartAirportID')
BEGIN
    CREATE INDEX IDX_Scale_StartAirportID ON Scale(StartAirportID);
END;
GO

-- Índice PARA GoalAirportID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Scale_GoalAirportID')
BEGIN
    CREATE INDEX IDX_Scale_GoalAirportID ON Scale(GoalAirportID);
END;
GO

-- Índice PARA PlaneModelID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Scale_PlaneModelID')
BEGIN
    CREATE INDEX IDX_Scale_PlaneModelID ON Scale(PlaneModelID);
END;
GO

-- Índice PARA StartAirportID y GoalAirportID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Scale_StartAirportID_GoalAirportID')
BEGIN
    CREATE INDEX IDX_Scale_StartAirportID_GoalAirportID ON Scale(StartAirportID, GoalAirportID);
END;
GO

-------------------------------23---------------------------------------

-- Tabla ASIENTO
IF OBJECT_ID('Seat', 'U') IS NOT NULL 
DROP TABLE Seat;
GO

CREATE TABLE Seat (
    SeatID INT PRIMARY KEY IDENTITY(1,1),
    Size VARCHAR(50) CHECK (Size IN ('Turista', 'Ejecutiva', 'Economica')),
    Number VARCHAR(10) NOT NULL,
    Location VARCHAR(100) NOT NULL,
    PlaneModelID INT,
    CONSTRAINT FK_Seat_PlaneModel FOREIGN KEY (PlaneModelID) REFERENCES PlaneModel(PlaneModelID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- Índice para PlaneModelID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Seat_PlaneModelID')
BEGIN
    CREATE INDEX IX_Seat_PlaneModelID ON Seat (PlaneModelID);
END;

-------------------------------24---------------------------------------

-- Tabla ASIGNACION DE VUELO
IF OBJECT_ID('FlightAssignment', 'U') IS NOT NULL 
    DROP TABLE FlightAssignment;
GO

CREATE TABLE FlightAssignment (
    AssigID INT PRIMARY KEY IDENTITY(1,1), 
    Description VARCHAR(255) NOT NULL, 
    FlightID INT NOT NULL, 
    FlightStatusID INT NULL, 
    CONSTRAINT FK_FlightAssignment_Flight FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
        ON DELETE CASCADE ON UPDATE CASCADE, 
    CONSTRAINT FK_FlightAssignment_FlightStatus FOREIGN KEY (FlightStatusID) REFERENCES FlightStatus(ID)
        ON DELETE SET NULL ON UPDATE CASCADE -- PERMITE NULL SI EL STATUS ES ELIMINADO
);
GO

-- Índice en FlightID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FlightAssignment_FlightID')
BEGIN
    CREATE INDEX IX_FlightAssignment_FlightID ON FlightAssignment (FlightID);
END;

-- Índice en FlightStatusID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FlightAssignment_FlightStatusID')
BEGIN
    CREATE INDEX IX_FlightAssignment_FlightStatusID ON FlightAssignment (FlightStatusID);
END;
GO

-------------------------------25---------------------------------------


-- Tabla ASIGNACION DEL ROL
IF OBJECT_ID('RoleAssignment', 'U') IS NOT NULL 
    DROP TABLE RoleAssignment;
GO

CREATE TABLE RoleAssignment (
    RoleAssinID INT PRIMARY KEY IDENTITY(1,1), 
    FlightID INT NOT NULL,  
    RoleID INT NULL,    
    CrewMemberID INT NULL,  
    ScaleID INT NULL,   
    CONSTRAINT FK_RoleAssignment_Flight FOREIGN KEY (FlightID) REFERENCES Flight(FlightID),
    CONSTRAINT FK_RoleAssignment_Role FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
        ON DELETE SET NULL ON UPDATE CASCADE, 
    CONSTRAINT FK_RoleAssignment_CrewMember FOREIGN KEY (CrewMemberID) REFERENCES CrewMember(CrewMemberID)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT FK_RoleAssignment_Scale FOREIGN KEY (ScaleID) REFERENCES Scale(ScaleID)
        ON DELETE SET NULL ON UPDATE CASCADE 
);
GO



-- Índices (sin cambios)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_RoleAssignment_FlightID')
BEGIN
    CREATE INDEX IDX_RoleAssignment_FlightID ON RoleAssignment(FlightID);
END;
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_RoleAssignment_RoleID')
BEGIN
    CREATE INDEX IDX_RoleAssignment_RoleID ON RoleAssignment(RoleID);
END;
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_RoleAssignment_CrewMemberID')
BEGIN
    CREATE INDEX IDX_RoleAssignment_CrewMemberID ON RoleAssignment(CrewMemberID);
END;
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_RoleAssignment_ScaleID')
BEGIN
    CREATE INDEX IDX_RoleAssignment_ScaleID ON RoleAssignment(ScaleID);
END;
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_RoleAssignment_FlightID_RoleID_CrewMemberID')
BEGIN
    CREATE INDEX IDX_RoleAssignment_FlightID_RoleID_CrewMemberID ON RoleAssignment(FlightID, RoleID, CrewMemberID);
END;
GO



-------------------------------26---------------------------------------

-- Tabla Reservation
IF OBJECT_ID('Reservation', 'U') IS NOT NULL 
    DROP TABLE Reservation;
GO

CREATE TABLE Reservation (
    ReservationID INT PRIMARY KEY IDENTITY(1,1),
    ReservationDate DATETIME NOT NULL DEFAULT GETDATE(), 
    CustomerID INT NOT NULL, 
    FlightID INT NULL, 
    CONSTRAINT FK_Reservation_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Reservation_Flight FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
        ON DELETE SET NULL ON UPDATE CASCADE 
);
GO

-- Índices para optimizar consultas
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Reservation_CustomerID')
BEGIN
    CREATE INDEX IDX_Reservation_CustomerID ON Reservation(CustomerID);
END;
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Reservation_FlightID')
BEGIN
    CREATE INDEX IDX_Reservation_FlightID ON Reservation(FlightID);
END;
GO

-------------------------------27---------------------------------------

--  TABLA PAGO DE RESERVA
IF OBJECT_ID('Payment', 'U') IS NOT NULL 
DROP TABLE Payment;
GO

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),        
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount > 0), 
    PaymentDate DATETIME NOT NULL DEFAULT GETDATE(),  -- Registra automáticamente la fecha y hora actual
	ReservationID INT,
    PaymentMetthodID INT,
    CONSTRAINT FK_Payment_Reservation FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID)
        ON DELETE CASCADE ON UPDATE CASCADE, 
	CONSTRAINT FK_Payment_PaymentMetthod FOREIGN KEY (PaymentMetthodID) REFERENCES PaymentMetthod(ID)
        ON DELETE SET NULL ON UPDATE CASCADE 
);
GO

-- índice PARA ReservationtID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Payment_ReservationtID')
BEGIN
    CREATE INDEX IX_Payment_ReservationID ON Payment (ReservationID);
END;
GO

-- índice PARA PaymentMetthodID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Payment_PaymentMetthodID')
BEGIN
    CREATE INDEX IX_Payment_PaymentMetthodID ON Payment (PaymentMetthodID);
END;
GO

-- índice PARA PaymentDate
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Payment_PaymentDate')
BEGIN
    CREATE INDEX IX_Payment_PaymentDate ON Payment (PaymentDate);
END;
GO

-- índice PARA ReservationtID y PaymentMetthodID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Payment_ReservationtID_PaymentMetthodID')
BEGIN
    CREATE INDEX IX_Payment_ReservationID_PaymentMetthodID ON Payment (ReservationID, PaymentMetthodID);
END;
GO

-------------------------------28---------------------------------------

--  TABLA ASIGNACION DE ESTADO
IF OBJECT_ID('StatusAssignment', 'U') IS NOT NULL 
DROP TABLE StatusAssignment;
GO

CREATE TABLE StatusAssignment (
    ID INT PRIMARY KEY IDENTITY(1,1),      
    Descripcion NVARCHAR(255) NOT NULL,
	ReservationID INT,
    StatusID INT,
    CONSTRAINT FK_StatusAssignment_Reservation FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID)
        ON DELETE CASCADE ON UPDATE CASCADE, 
	CONSTRAINT FK_StatusAssignment_Status FOREIGN KEY (StatusID) REFERENCES Status_reserva(StatusID)
        ON DELETE CASCADE ON UPDATE CASCADE 
);
GO

-- Índice PARA ReservationtID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('StatusAssignment') AND name = 'IX_StatusAssignment_ReservationtID')
BEGIN
    CREATE INDEX IX_StatusAssignment_ReservationID ON StatusAssignment (ReservationID);
END;
GO

-- Índice PARA StatusID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('StatusAssignment') AND name = 'IX_StatusAssignment_StatusID')
BEGIN
    CREATE INDEX IX_StatusAssignment_StatusID ON StatusAssignment (StatusID);
END;
GO

-------------------------------29---------------------------------------

--  TABLA ASIGNACION DE MULTA
IF OBJECT_ID('FineAssignment', 'U') IS NOT NULL 
DROP TABLE FineAssignment;
GO

CREATE TABLE FineAssignment (
    fineID INT PRIMARY KEY IDENTITY(1,1),  
    Descripcion NVARCHAR(255) NOT NULL,   
	FineTypeID INT,
	StatusID INT NULL, 
    CONSTRAINT FK_FineAssignment_FineType FOREIGN KEY (FineTypeID) REFERENCES FineType(ID)
        ON DELETE SET NULL ON UPDATE CASCADE, --PERMITE NULL PARA NO PERDER DATOS DE LAS MULTAS ASIGNADAS
    CONSTRAINT FK_FineAssignment_Status FOREIGN KEY (StatusID) REFERENCES StatusAssignment(ID)        
		ON DELETE SET NULL    -- Si se elimina el estado, permite NULL en StatusID
);
GO

-- Índice en FineTypeID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('FineAssignment') AND name = 'IX_FineAssignment_FineTypeID')
BEGIN
    CREATE INDEX IX_FineAssignment_FineTypeID ON FineAssignment (FineTypeID);
END;
GO

-- Índice en StatusID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('FineAssignment') AND name = 'IX_FineAssignment_StatusID')
BEGIN
    CREATE INDEX IX_FineAssignment_StatusID ON FineAssignment (StatusID);
END;
GO

-------------------------------30---------------------------------------

-- Tabla DOCUMENT
IF OBJECT_ID('Document', 'U') IS NOT NULL 
DROP TABLE Document;
GO

CREATE TABLE Document (
    DocumentID INT PRIMARY KEY IDENTITY(1,1),
    IssueDate DATE NOT NULL,
    ExpiryDate DATE,
    CountryID INT NOT NULL,
    CONSTRAINT FK_Document_Country FOREIGN KEY (CountryID) REFERENCES Country(CountryID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO


-- 1. Eliminar el índice relacionado con DocumentNumber si existe
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Document_DocumentNumber')
BEGIN
    DROP INDEX IX_Document_DocumentNumber ON Document;
END;
GO

-- 2. Eliminar la columna DocumentNumber de la tabla Document
ALTER TABLE Document
DROP COLUMN DocumentNumber;
GO


-------------------------------31---------------------------------------

IF OBJECT_ID('PassportType', 'U') IS NOT NULL 
DROP TABLE PassportType;
GO

CREATE TABLE PassportType (
    TypeID INT PRIMARY KEY IDENTITY(1,1),
    TypeName VARCHAR(50) NOT NULL
);
GO

-- Índice para TypeName
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PassportType_TypeName')
BEGIN
    CREATE INDEX IX_PassportType_TypeName ON PassportType (TypeName);
END;
GO

-------------------------------32---------------------------------------

IF OBJECT_ID('Passport', 'U') IS NOT NULL 
DROP TABLE Passport;
GO

CREATE TABLE Passport (
    PassportDocumentID INT PRIMARY KEY,
    PassportNumber VARCHAR(50) NOT NULL,
    TypeID INT NOT NULL,
    CONSTRAINT FK_Passport_Document FOREIGN KEY (PassportDocumentID) REFERENCES Document(DocumentID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Passport_PassportType FOREIGN KEY (TypeID) REFERENCES PassportType(TypeID)
        ON DELETE NO ACTION ON UPDATE CASCADE,
	CONSTRAINT UQ_Passport_PassportNumber UNIQUE (PassportNumber)
);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Passport_TypeID')
BEGIN
    CREATE INDEX IX_Passport_TypeID ON Passport (TypeID);
END;
GO





-------------------------------33---------------------------------------

IF OBJECT_ID('DNI', 'U') IS NOT NULL 
DROP TABLE DNI;
GO

CREATE TABLE DNI (
    DNIDocumentID INT PRIMARY KEY,
    DNINumber VARCHAR(50) NOT NULL,
    CONSTRAINT FK_DNI_Document FOREIGN KEY (DNIDocumentID) REFERENCES Document(DocumentID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT UQ_DNI_DNINumber UNIQUE (DNINumber) -- Hacer DNINumber único
);
GO

-- Índice para DNINumber (opcional, ya que la restricción UNIQUE crea un índice automáticamente)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DNI_DNINumber')
BEGIN
    CREATE INDEX IX_DNI_DNINumber ON DNI (DNINumber);
END;
GO


-------------------------------34---------------------------------------

-- Tabla Passenger
IF OBJECT_ID('Passenger', 'U') IS NOT NULL 
    DROP TABLE Passenger;
GO

CREATE TABLE Passenger (
    PassengerID INT PRIMARY KEY IDENTITY(1,1), 
    FirstName VARCHAR(100) NOT NULL, 
    LastName VARCHAR(100) NOT NULL, 
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
);
GO

-- Índice en FirstName
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Passenger_FirstName')
BEGIN
    CREATE INDEX IX_Passenger_FirstName ON Passenger (FirstName);
END;

-- Índice en LastName
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Passenger_LastName')
BEGIN
    CREATE INDEX IX_Passenger_LastName ON Passenger (LastName);
END;
GO

-------------------------------35---------------------------------------

-- Tabla Ticket
IF OBJECT_ID('Ticket', 'U') IS NOT NULL 
    DROP TABLE Ticket;
GO

CREATE TABLE Ticket (
    TicketingCode INT IDENTITY(1,1) PRIMARY KEY, 
    Number INT NOT NULL CHECK (Number > 0), 
    TicketCategoryID INT NULL, 
    ReservationID INT NULL, 
	PassengerID INT NOT NULL,
	DocumentID INT NOT NULL,
    CONSTRAINT FK_Ticket_TicketCategory FOREIGN KEY (TicketCategoryID) REFERENCES TicketCategory(CategoryID)
        ON DELETE SET NULL ON UPDATE CASCADE, 
    CONSTRAINT FK_Ticket_Reservation FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID)
        ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT FK_Ticket_Passenger FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID)
		ON DELETE CASCADE,
	CONSTRAINT FK_Ticket_Document FOREIGN KEY (DocumentID) REFERENCES Document(DocumentID),
	CONSTRAINT UQ_Ticket_Number UNIQUE (Number)  -- Atributo Number como único
);
GO



-- Índice en Number
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Ticket_Number')
BEGIN
    CREATE INDEX IX_Ticket_Number ON Ticket (Number);
END;


-------------------------------36---------------------------------------

-- Tabla cupón
IF OBJECT_ID('Coupon', 'U') IS NOT NULL 
DROP TABLE Coupon;
GO

CREATE TABLE Coupon (
    CouponID INT PRIMARY KEY IDENTITY(1,1),
    DateOfRedemption DATE CHECK (DateOfRedemption <= GETDATE()),
    Class VARCHAR(50) CHECK (Class IN ('Economica', 'Ejecutiva', 'Turista')),
    Standby VARCHAR(50) CHECK (Standby IN ('Si', 'No')),
    MealCode VARCHAR(50) NOT NULL CHECK (MealCode IN ('A', 'B', 'C')),
    TicketingCode INT NOT NULL,
    FlightID INT,
    CONSTRAINT FK_Coupon_Ticket FOREIGN KEY (TicketingCode) REFERENCES Ticket(TicketingCode)
        ON DELETE CASCADE,
    CONSTRAINT FK_Coupon_Flight FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
		ON DELETE CASCADE
);
GO

-- Indice en Class
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Coupon_Class')
BEGIN
    CREATE INDEX IX_Coupon_Class ON Coupon (Class);
END;

-- Indice en Standby
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Coupon_Standby')
BEGIN
    CREATE INDEX IX_Coupon_Standby ON Coupon (Standby);
END;

-------------------------------37---------------------------------------

-- Tabla PIEZAS DE EQUIPAJE
IF OBJECT_ID('PiecesOfLuggage', 'U') IS NOT NULL 
    DROP TABLE PiecesOfLuggage;
GO

CREATE TABLE PiecesOfLuggage (
    LuggageID INT PRIMARY KEY IDENTITY(1,1), 
    Number INT CHECK (Number > 0), 
    Weight DECIMAL(10, 2) CHECK (Weight > 0), 
    CouponID INT, 
    CheLuggaID INT NOT NULL, 
    CONSTRAINT FK_Luggage_Coupon FOREIGN KEY (CouponID) REFERENCES Coupon(CouponID)
        ON DELETE CASCADE ON UPDATE CASCADE, 
    CONSTRAINT FK_Luggage_CheckinLuggage FOREIGN KEY (CheLuggaID) REFERENCES CheckinLuggage(CheLuggaID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT UQ_PiecesOfLuggage_Number UNIQUE (Number)

);
GO


-- Índice en Weight
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PiecesOfLuggage_Weight')
BEGIN
    CREATE INDEX IX_PiecesOfLuggage_Weight ON PiecesOfLuggage (Weight);
END;
GO




-------------------------------38---------------------------------------

-- Tabla ASIENTO DISPONIBLE
IF OBJECT_ID('AvailableSeat', 'U') IS NOT NULL 
DROP TABLE AvailableSeat;
GO

CREATE TABLE AvailableSeat (
    AvailableSeatID INT PRIMARY KEY IDENTITY(1,1),
    SeatID INT,
    FlightID INT,
	CouponID INT,
    CONSTRAINT FK_AvailableSeat_Seat FOREIGN KEY (SeatID) REFERENCES Seat(SeatID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_AvailableSeat_Flight FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
        ON DELETE CASCADE,
	CONSTRAINT FK_AvailableSeat_Coupon FOREIGN KEY (CouponID) REFERENCES Coupon(CouponID)
);
GO

-- Indice en FlightID, SeatID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AvailableSeat_FlightID_SeatID')
BEGIN
    CREATE INDEX IX_AvailableSeat_FlightID_SeatID ON AvailableSeat (FlightID, SeatID);
END;

-- Indice en SeatID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AvailableSeat_SeatID')
BEGIN
    CREATE INDEX IX_AvailableSeat_SeatID ON AvailableSeat (SeatID);
END;

-----------------------TABLA DE NOMBRES--------------------------------

-----------------------select * from Name------------------------------

CREATE TABLE Name (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(225)NOT NULL,
);
GO


------------------------------------------------------------------------
---------------------------POBLACION DE TABLAS--------------------------


-- tabla FineType (TIPO DE MULTA)
INSERT INTO FineType (Name)
VALUES 
('Exceso de equipaje'),
('Cancelacion de vuelo'),
('Cambio de vuelo');

INSERT INTO Status_Reserva (Name)
VALUES 
('Confirmada'),
('Pendiente'),
('Cancelada');

--tabla CustomerCategory (CATEGORIA DEL CLIENTE)
INSERT INTO CustomerCategory (CategoryName)
VALUES 
('Regular'),
('Frecuente');

-- tabla TicketCategory (CATEGORIA DEL TICKET)
INSERT INTO TicketCategory (CategoryName)
VALUES 
('Primera clase'),
('Ejecutiva'),
('Premium'),
('Económica');

-- tabla CheckinLuggage (FACTURAR EQUIPAJE)
INSERT INTO CheckinLuggage (CategoryName)
VALUES 
('Maleta'),
('Mochila'),
('Bolsa'),
('Otro');

-- tabla FlightStatus (ESTADO DEL VUELO)
INSERT INTO FlightStatus (StatusName)
VALUES 
('Programado'),
('Retrasado'),
('Cancelado'),
('En Vuelo'),
('Aterrizado');

-- tabla Role (ROL)
INSERT INTO Role (RoleName)
VALUES 
('Piloto'),
('Copiloto'),
('Auxiliar de Vuelo'),
('Mecánico'),
('Administrador');


-- tabla CrewMember
WITH RandomData AS (
    SELECT 
        N.Name AS Name,                            -- Nombre aleatorio 
        C.CountryName AS Nationality,              -- Nacionalidad aleatoria 
        ABS(CHECKSUM(NEWID())) % 15 + 1 AS ExperienceYears -- Años de experiencia aleatorios (1 a 15)
    FROM 
        Name N
    CROSS JOIN 
        Country C
)
--insertar datos
INSERT INTO CrewMember (Name, Nationality, ExperienceYears)
SELECT TOP 569 
    Name,
    Nationality,
    ExperienceYears
FROM 
    RandomData
ORDER BY 
    NEWID();  -- Ordenar
GO

-- tabla FlightCategory (CATEGORIA DE VUELO)
INSERT INTO FlightCategory (CategoryName)
VALUES 
('Nacional'),
('Internacional');

-- tabla PlaneModel
INSERT INTO PlaneModel (Description, Graphic)
VALUES
    ('Boeing 737-800', 0x0102030405060708),
    ('Boeing 747-400', 0x090A0B0C0D0E0F10),
    ('Boeing 767-300', 0x1112131415161718),
    ('Boeing 777-200', 0x191A1B1C1D1E1F20),
    ('Boeing 787-9', 0x2122232425262728),
    ('Airbus A320neo', 0x292A2B2C2D2E2F30),
    ('Airbus A330-300', 0x3132333435363738),
    ('Airbus A340-600', 0x393A3B3C3D3E3F40),
    ('Airbus A350-900', 0x4142434445464748),
    ('Airbus A380-800', 0x495A4B4C4D4E4F50),
    ('Embraer E190-E2', 0x5152535455565758),
    ('Embraer E195-E2', 0x595A5B5C5D5E5F60),
    ('Bombardier CRJ-900', 0x6162636465666768),
    ('Bombardier Q400', 0x696A6B6C6D6E6F70),
    ('Mitsubishi MRJ90', 0x7172737475767778);

--tabla PaymentMetthod (METODO DE PAGO)
INSERT INTO PaymentMetthod (PaymentMetthodName, Description)
VALUES 
('Tarjeta', 'Pago con tarjeta de crédito o débito'),
('Efectivo', 'Pago en efectivo en el aeropuerto'),
('Qr', 'Pago mediante código QR');


--tabla airline
INSERT INTO Airline (Name, IATACode,  ICAOCode, CountryID)
VALUES
	('BOA', 'OB', 'BOV', 21),
	('TAM AIRLINE', 'JJ', 'TAM', 24),
	('FLYBONDI', 'FO', 'FOD', 7),
	('CONVIASA', 'VO', 'VCV', 191);


-- AEROPUERTO
INSERT INTO Airport(Name, CityID)
VALUES
    ('Aeropuerto Internacional Viru Viru', 5357),
	('Aeropuerto Internacional El Alto', 5358),
	('Aeropuerto Capitán Aníbal Arab Fadul', 5359),
	('Aeropuerto Capitán Nicolás Rojas', 5360),
	('Aeropuerto Internacional de Alcantarí', 5361),
	('Aeropuerto Juan Mendoza', 5362),
	('Aeropuerto Jorge Henrich Arauz', 5363),
	('Aeropuerto Teniente Jorge Henrich Arauz', 5364),
	('Aeropuerto de Cobija', 5365);


----------FlightNumber------------------------------------------------------

DECLARE @Counter INT = 1;
DECLARE @DepartureTime DATETIME;
DECLARE @Description VARCHAR(255);
DECLARE @StartAirportID INT;
DECLARE @GoalAirportID INT;


WHILE @Counter <= 2000
BEGIN
    
    SET @DepartureTime = DATEADD(HOUR, @Counter, GETDATE()); --fechas de salida 
    SET @Description = 'Vuelo ' + CAST(@Counter AS VARCHAR(10));
    SET @StartAirportID = (SELECT TOP 1 AirportID FROM Airport ORDER BY NEWID()); -- aeropuerto de inicio aleatorio
    SET @GoalAirportID = (SELECT TOP 1 AirportID FROM Airport WHERE AirportID <> @StartAirportID ORDER BY NEWID()); 

   
    INSERT INTO FlightNumber (DepartureTime, Description, StartAirportID, GoalAirportID)
    VALUES (@DepartureTime, @Description, @StartAirportID, @GoalAirportID);

    SET @Counter = @Counter + 1;
END;


----------------Flight-------------------------------------------------
--DBCC CHECKIDENT ('Flight', RESEED, 0);
DECLARE @Counter1 INT = 1;
DECLARE @BoardingTime TIME;
DECLARE @FlightDate DATE;
DECLARE @Gate VARCHAR(50);
DECLARE @CheckInCounter VARCHAR(50);
DECLARE @FlightNumID INT;
DECLARE @AirlineID INT;
DECLARE @CategoryID INT;
DECLARE @PlaneModelID INT;

WHILE @Counter1 <= 2000
BEGIN
    -- FlightDate  los próximos 60 días
    SET @FlightDate = DATEADD(DAY, FLOOR(RAND() * 60), GETDATE());

    -- BoardingTime  entre 1 minuto  y 4 horas 
    SET @BoardingTime = CONVERT(TIME, DATEADD(MINUTE, FLOOR(1 + RAND() * 240), GETDATE()));

    -- Gate y CheckInCounter 
    SET @Gate = CAST(FLOOR(RAND() * 20) + 1 AS VARCHAR(10));
    SET @CheckInCounter = CAST(FLOOR(RAND() * 100) + 1 AS VARCHAR(10));

    -- FlightNumID alea... de la tabla FlightNumber
    SET @FlightNumID = (SELECT TOP 1 FlightNumberID FROM FlightNumber ORDER BY NEWID());
    SET @AirlineID = (SELECT TOP 1 AirlineID FROM Airline ORDER BY NEWID());
    SET @CategoryID = (SELECT TOP 1 CategoryID FROM FlightCategory ORDER BY NEWID());
    SET @PlaneModelID = (SELECT TOP 1 PlaneModelID FROM PlaneModel ORDER BY NEWID());

   
    INSERT INTO Flight (BoardingTime, FlightDate, Gate, CheckInCounter, FlightNumID, AirlineID, CategoryID, PlaneModelID)
    VALUES (@BoardingTime, @FlightDate, @Gate, @CheckInCounter, @FlightNumID, @AirlineID, @CategoryID, @PlaneModelID);

    SET @Counter1 = @Counter1 + 1;
END;

------------------------------------FrequentFlyerCard------------------------------------

DECLARE @Counter2 INT = 1;
DECLARE @FFCNumber INT;
DECLARE @Miles INT;
DECLARE @MealCode CHAR(1);
DECLARE @CustomerID INT;

WHILE @Counter2 <= 200
BEGIN
    -- número de tarjeta 
    SET @FFCNumber = @Counter2 + 1000; 

    -- millas entre 0 y 100000
    SET @Miles = FLOOR(RAND() * 100000);

    -- código de comida  ('A', 'B', o 'C')
    SET @MealCode = CHAR(65 + FLOOR(RAND() * 3)); -- 'A' = 65 en ASCII, así que esto genera 'A', 'B', o 'C'

    -- CustomerID entre 1 y 1000
    SET @CustomerID = FLOOR(RAND() * 1000) + 1;

    INSERT INTO FrequentFlyerCard (FFCNumber, Miles, MealCode, CustomerID)
    VALUES (@FFCNumber, @Miles, @MealCode, @CustomerID);

    SET @Counter2 = @Counter2 + 1;
END;

------------------------ C_Assignment------------------------------------------------
DECLARE @Counter3 INT = 1;
DECLARE @CustomerID1 INT;
DECLARE @CategoryID1 INT;

WHILE @Counter3 <= 1000
BEGIN
    --  entre 1 y 1000
    SET @CustomerID1 = @Counter3;

    -- CategoryID entre 1 y 2 (Regular y Frecuente)
    SET @CategoryID1 = FLOOR(RAND() * 2) + 1;

    INSERT INTO C_Assignment (CustomerID, CategoryID)
    VALUES (@CustomerID1, @CategoryID1);

    SET @Counter3 = @Counter3 + 1;
END;

------------------------ Airplane------------------------------------------------

INSERT INTO Airplane (RegistrationNumber, BeginOfOperation, Status, PlaneModID)
VALUES
    ('BOE737-001', '2020-01-15', 'Operativo', 3),
    ('BOE747-002', '2018-05-10', 'Mantenimiento', 7),
    ('BOE767-003', '2019-07-20', 'Operativo', 1),
    ('BOE777-004', '2021-03-18', 'Operativo', 9),
    ('BOE787-005', '2022-09-25', 'Inactivo', 4),
    ('AIR320-006', '2020-12-11', 'Operativo', 12),
    ('AIR330-007', '2018-04-30', 'Mantenimiento', 15),
    ('AIR340-008', '2019-08-17', 'Operativo', 6),
    ('AIR350-009', '2021-02-22', 'Operativo', 10),
    ('AIR380-010', '2022-10-05', 'Mantenimiento', 2),
    ('EMB190-011', '2020-11-03', 'Operativo', 11),
    ('EMB195-012', '2019-06-15', 'Operativo', 8),
    ('BOMCRJ-013', '2018-09-10', 'Mantenimiento', 13),
    ('BOMQ400-014', '2021-07-28', 'Operativo', 5),
    ('MITMRJ-015', '2020-03-12', 'Inactivo', 14);


------------------------Reservation ------------------------------------------------
--DBCC CHECKIDENT ('Reservation', RESEED, 0); -- esto es para que reinicie el ID de 1 
DECLARE @Counter4 INT = 1;
DECLARE @CustomerID2 INT;
DECLARE @FlightID INT;
DECLARE @ReservationDate DATETIME;

WHILE @Counter4 <= 1000
BEGIN
    -- CustomerID entre 1 y 1000
    SET @CustomerID2 = FLOOR(RAND() * 1000) + 1;

    SET @FlightID = (SELECT TOP 1 FlightID FROM Flight ORDER BY NEWID());

    -- fecha de reserva  entre 0 y 3 días atrás
    SET @ReservationDate = DATEADD(DAY, -FLOOR(RAND() * 4), GETDATE());

    --  hora entre 0 y 23 horas, y minutos entre 0 y 59
    SET @ReservationDate = DATEADD(HOUR, FLOOR(RAND() * 24), @ReservationDate); -- Hora 
    SET @ReservationDate = DATEADD(MINUTE, FLOOR(RAND() * 60), @ReservationDate); -- Minutos 

    INSERT INTO Reservation (ReservationDate, CustomerID, FlightID)
    VALUES (@ReservationDate, @CustomerID2, @FlightID);

    SET @Counter4 = @Counter4 + 1;
END;


------------------------FlightAssignment ------------------------------------------------

--DBCC CHECKIDENT ('FlightAssignment', RESEED, 0); -- esto es para que reinicie el ID de 

DECLARE @Counter5 INT = 1;
DECLARE @FlightID1 INT;
DECLARE @FlightStatusID INT;
DECLARE @Description1 VARCHAR(255);

WHILE @Counter5 <= 2000
BEGIN
    -- entre 1 y 2000
    SET @FlightID1 = @Counter5;

    -- FlightStatusID entre 1 y 5
    SET @FlightStatusID = FLOOR(RAND() * 5) + 1;

    -- descripción según el estado del vuelo
    SET @Description1 = 
        CASE @FlightStatusID
            WHEN 1 THEN 'El vuelo ' + CAST(@FlightID1 AS VARCHAR(10)) + ' está programado.'
            WHEN 2 THEN 'El vuelo ' + CAST(@FlightID1 AS VARCHAR(10)) + ' está retrasado.'
            WHEN 3 THEN 'El vuelo ' + CAST(@FlightID1 AS VARCHAR(10)) + ' ha sido cancelado.'
            WHEN 4 THEN 'El vuelo ' + CAST(@FlightID1 AS VARCHAR(10)) + ' está en vuelo.'
            WHEN 5 THEN 'El vuelo ' + CAST(@FlightID1 AS VARCHAR(10)) + ' ha aterrizado.'
            ELSE 'El vuelo ' + CAST(@FlightID1 AS VARCHAR(10)) + ' tiene un estado desconocido.'
        END;

    INSERT INTO FlightAssignment (Description, FlightID, FlightStatusID)
    VALUES (@Description1, @FlightID1, @FlightStatusID);

    SET @Counter5 = @Counter5 + 1;
END;


-----------------------Seat-------------------------

DECLARE @C INT = 1;
DECLARE @PlaneModelID1 INT;
DECLARE @Size VARCHAR(50);
DECLARE @Number VARCHAR(10);
DECLARE @Location VARCHAR(100);
DECLARE @SeatClass INT;
DECLARE @MaxSeats INT;

WHILE @C <= 15
BEGIN
    -- PlaneModelID actual
    SET @PlaneModelID1 = @C;
    
    -- número máximo de asientos según el modelo de avión
    IF @PlaneModelID1 = 1 SET @MaxSeats = 175;   -- Boeing 737-800
    ELSE IF @PlaneModelID1 = 2 SET @MaxSeats = 408;  -- Boeing 747-400
    ELSE IF @PlaneModelID1 = 3 SET @MaxSeats = 250;  -- Boeing 767-300
    ELSE IF @PlaneModelID1 = 4 SET @MaxSeats = 355;  -- Boeing 777-200
    ELSE IF @PlaneModelID1 = 5 SET @MaxSeats = 270;  -- Boeing 787-9
    ELSE IF @PlaneModelID1 = 6 SET @MaxSeats = 190;  -- Airbus A320neo
    ELSE IF @PlaneModelID1 = 7 SET @MaxSeats = 350;  -- Airbus A330-300
    ELSE IF @PlaneModelID1 = 8 SET @MaxSeats = 400;  -- Airbus A340-600
    ELSE IF @PlaneModelID1 = 9 SET @MaxSeats = 325;  -- Airbus A350-900
    ELSE IF @PlaneModelID1 = 10 SET @MaxSeats = 675;  -- Airbus A380-800
    ELSE IF @PlaneModelID1 = 11 SET @MaxSeats = 105;  -- Embraer E190-E2
    ELSE IF @PlaneModelID1 = 12 SET @MaxSeats = 130;  -- Embraer E195-E2
    ELSE IF @PlaneModelID1 = 13 SET @MaxSeats = 83;   -- Bombardier CRJ-900
    ELSE IF @PlaneModelID1 = 14 SET @MaxSeats = 82;   -- Bombardier Q400
    ELSE IF @PlaneModelID1 = 15 SET @MaxSeats = 90;   -- Mitsubishi MRJ90

    DECLARE @SeatCounter INT = 1;

    -- asientos para el modelo de avión
    WHILE @SeatCounter <= @MaxSeats
    BEGIN
        -- tamaño del asiento 
        IF @SeatCounter <= @MaxSeats * 0.10
            SET @Size = 'Economica';
        ELSE IF @SeatCounter <= @MaxSeats * 0.30
            SET @Size = 'Ejecutiva';
        ELSE
            SET @Size = 'Turista';

        --número de asiento y ubicación
        SET @Number = 'A' + CAST(@SeatCounter AS VARCHAR(10)); -- A1, A2, ...
        SET @Location = 'Fila ' + CAST(CEILING(@SeatCounter / 6.0) AS VARCHAR(10)) + ' Asiento ' + CAST((@SeatCounter % 6) + 1 AS VARCHAR(10)); -- Fila 1 Asiento 1..


        INSERT INTO Seat (Size, Number, Location, PlaneModelID)
        VALUES (@Size, @Number, @Location, @PlaneModelID1);

        SET @SeatCounter = @SeatCounter + 1;
    END

    SET @C = @C + 1;
END;


----------------------Scale------------------

--DBCC CHECKIDENT ('Scale', RESEED, 0); 
DECLARE @C2 INT = 1;
DECLARE @StopoverDuration TIME;
DECLARE @FlightID2 INT;
DECLARE @StartAirportID1 INT;
DECLARE @GoalAirportID1 INT;
DECLARE @PlaneModelID2 INT;

WHILE @C2 <= 1800
BEGIN
    --  duración de escala entre 30 minutos y 24 horas
    SET @StopoverDuration = CONVERT(TIME, DATEADD(MINUTE, 30 + FLOOR(RAND() * (1440 - 30)), 0)); --  mínimo de 30 minutos y un máximo de 1440 minutos.

    -- FlightID entre 1 y 2000
    SET @FlightID2 = FLOOR(RAND() * 2000) + 1;

    SET @StartAirportID1 = (SELECT TOP 1 AirportID FROM Airport ORDER BY NEWID());

    SET @GoalAirportID1 = (SELECT TOP 1 AirportID FROM Airport WHERE AirportID <> @StartAirportID1 ORDER BY NEWID());

    SET @PlaneModelID2 = FLOOR(RAND() * 15) + 1;

    INSERT INTO Scale (StopoverDuration, FlightID, StartAirportID, GoalAirportID, PlaneModelID)
    VALUES (@StopoverDuration, @FlightID2, @StartAirportID1, @GoalAirportID1, @PlaneModelID2);

    SET @C2 = @C2 + 1;
END;

----------------------------------RoleAssignment-------------------
DECLARE @C3 INT = 1;
DECLARE @FlightID3 INT;
DECLARE @RoleID INT;
DECLARE @CrewMemberID INT;
DECLARE @ScaleID INT;

WHILE @C3 <= 14000
BEGIN
    -- FlightID entre 1 y 2000
    SET @FlightID3 = FLOOR(RAND() * 2000) + 1;

    -- RoleID entre 1 y 5 (Piloto, Copiloto, Auxiliar de Vuelo, Mecánico, Administrador)
    SET @RoleID = FLOOR(RAND() * 5) + 1;

    SET @CrewMemberID = FLOOR(RAND() * 569) + 1;

    SET @ScaleID = FLOOR(RAND() * 1800) + 1;

    INSERT INTO RoleAssignment (FlightID, RoleID, CrewMemberID, ScaleID)
    VALUES (@FlightID3, @RoleID, @CrewMemberID, @ScaleID);

    SET @C3 = @C3 + 1;
END;


------------------Payment------------------------

--DBCC CHECKIDENT ('Payment', RESEED, 0); 

DECLARE @C4 INT = 1;
DECLARE @Amount DECIMAL(10,2);
DECLARE @ReservationID INT;
DECLARE @PaymentMetthodID INT;
DECLARE @PaymentDate DATETIME;

WHILE @C4 <= 1000
BEGIN
    -- monto de pago entre 50.00 y 1000.00
    SET @Amount = CAST(50 + (RAND() * 950) AS DECIMAL(10,2));  

    SET @ReservationID = FLOOR(RAND() * 1000) + 1;

    SET @PaymentMetthodID = FLOOR(RAND() * 3) + 1;

    SET @PaymentDate = DATEADD(DAY, -FLOOR(RAND() * 4), GETDATE());  -- Fecha entre 0 y 3 días atrás
    SET @PaymentDate = DATEADD(HOUR, FLOOR(RAND() * 24), @PaymentDate);  -- Hora 
    SET @PaymentDate = DATEADD(MINUTE, FLOOR(RAND() * 60), @PaymentDate);  -- Minutos

    INSERT INTO Payment (Amount, PaymentDate, ReservationID, PaymentMetthodID)
    VALUES (@Amount, @PaymentDate, @ReservationID, @PaymentMetthodID);

    SET @C4 = @C4 + 1;
END;

-----------------------StatusAssignment-------------
DECLARE @C5 INT = 1;
DECLARE @Descripcion NVARCHAR(255);
DECLARE @ReservationID1 INT;
DECLARE @StatusID INT;

WHILE @C5 <= 1000
BEGIN
   
    SET @Descripcion = 'Estado de la reserva ' + CAST(@C5 AS NVARCHAR(10));
    SET @ReservationID1 = FLOOR(RAND() * 1000) + 1;

    --  StatusID  entre 1 y 3 (1: Confirmada, 2: Pendiente, 3: Cancelada)
    SET @StatusID = FLOOR(RAND() * 3) + 1;

    INSERT INTO StatusAssignment (Descripcion, ReservationID, StatusID)
    VALUES (@Descripcion, @ReservationID1, @StatusID);

    SET @C5 = @C5 + 1;
END;


-------------------------FineAssignment----------
DECLARE @C6 INT = 1;
DECLARE @Descripcion3 NVARCHAR(255);
DECLARE @FineTypeID INT;
DECLARE @StatusID1 INT;

WHILE @C6 <= 200
BEGIN

    SET @Descripcion3 = 'Multa asignada número ' + CAST(@C6 AS NVARCHAR(10));

    -- (1: Exceso de equipaje, 2: Cancelación de vuelo, 3: Cambio de vuelo)
    SET @FineTypeID = FLOOR(RAND() * 3) + 1;

    SET @StatusID1 = FLOOR(RAND() * 1000) + 1;

    INSERT INTO FineAssignment (Descripcion, FineTypeID, StatusID)
    VALUES (@Descripcion3, @FineTypeID, @StatusID1);

    SET @C6 = @C6 + 1;
END;

-------------------------FineAssignment----------

INSERT INTO PassportType (TypeName)
VALUES 
('Pasaporte Ordinario o Regular'),
('Pasaporte Diplomático'),
('Pasaporte Oficial o de Servicio'),
('Pasaporte Temporal o de Emergencia'),
('Pasaporte de Familia o Pasaporte Colectivo'),
('Pasaporte Especial'),
('Pasaporte Fronterizo'),
('Pasaporte de Apátrida o de Refugiado'),
('Pasaporte Consular'),
('Pasaporte Interno');


-------------------------Document-----------------

DECLARE @Count INT = 1;
DECLARE @IssueDate DATE;
DECLARE @ExpiryDate DATE;
DECLARE @CountryID INT;

WHILE @Count <= 3000
BEGIN
    -- fecha de emisión  en los últimos 20 años
    SET @IssueDate = DATEADD(DAY, -FLOOR(RAND() * 365 * 20), GETDATE());

    -- fecha de expiración entre 5 y 10 años después de la emisión
    SET @ExpiryDate = DATEADD(YEAR, 5 + FLOOR(RAND() * 5), @IssueDate);

    SET @CountryID = FLOOR(RAND() * 194) + 1;

    INSERT INTO Document (IssueDate, ExpiryDate, CountryID)
    VALUES (@IssueDate, @ExpiryDate, @CountryID);

    SET @Count = @Count + 1;
END;


----------------------------------------------------------------
-- 1500 DocumentID para DNI
-- 1500 DNI únicos

--DBCC CHECKIDENT ('Passenger', RESEED, 0); 

--tabla temporal Documento DNI
IF OBJECT_ID('tempdb..#DNI_DocumentIDs') IS NOT NULL
    DROP TABLE #DNI_DocumentIDs;

WITH CTE_DNI AS (
    SELECT TOP 1500 DocumentID 
    FROM Document 
    ORDER BY NEWID()  
)

SELECT DocumentID INTO #DNI_DocumentIDs FROM CTE_DNI; 

INSERT INTO DNI (DNIDocumentID, DNINumber)
SELECT DocumentID, CAST(ROW_NUMBER() OVER (ORDER BY NEWID()) + 1000000000 AS VARCHAR(50))  -- numero único para DNI
FROM #DNI_DocumentIDs;


WITH CTE_Passport AS (
    SELECT TOP 1500 DocumentID 
    FROM Document 
    WHERE DocumentID NOT IN (SELECT DocumentID FROM #DNI_DocumentIDs)  --IDs ya usados en DNI
    ORDER BY NEWID()  
)

INSERT INTO Passport (PassportDocumentID, PassportNumber, TypeID)
SELECT DocumentID, 'P' + CAST(ROW_NUMBER() OVER (ORDER BY NEWID()) + 1000000000 AS VARCHAR(50)), FLOOR(RAND() * 3) + 1  -- número único para Passport
FROM CTE_Passport;


-------------------------Ticket--------------------------

DECLARE @Cn1 INT = 1;
DECLARE @TicketNumber INT;
DECLARE @TicketCategoryID INT;
DECLARE @ReservationID3 INT;
DECLARE @PassengerID INT;
DECLARE @DocumentID INT;
DECLARE @UniqueNumbers TABLE (Number INT);

WHILE @Cn1 <= 3000
BEGIN
    
    SET @TicketNumber = FLOOR(RAND() * 8999) + 1000;

    -- Verificacion de Number = @TicketNumber
    WHILE EXISTS (SELECT 1 FROM @UniqueNumbers WHERE Number = @TicketNumber)
    BEGIN
        SET @TicketNumber = FLOOR(RAND() * 8999) + 1000;  -- nuevo número si ya existe
    END

    INSERT INTO @UniqueNumbers (Number) VALUES (@TicketNumber);

    -- (Primera clase, Ejecutiva, Premium, Económica)
    SET @TicketCategoryID = FLOOR(RAND() * 4) + 1;

    SET @ReservationID3 = FLOOR(RAND() * 1000) + 1;
    SET @PassengerID = FLOOR(RAND() * 3000) + 1;
    SET @DocumentID = FLOOR(RAND() * 3000) + 1;

    INSERT INTO Ticket (Number, TicketCategoryID, ReservationID, PassengerID, DocumentID)
    VALUES (@TicketNumber, @TicketCategoryID, @ReservationID3, @PassengerID, @DocumentID);

    SET @Cn1 = @Cn1 + 1;
END;


-----------------------------------------------Coupon----------------------

DECLARE @Cn2 INT = 1;
DECLARE @DateOfRedemption DATE;
DECLARE @Class VARCHAR(50);
DECLARE @Standby VARCHAR(50);
DECLARE @MealCode4 VARCHAR(50);
DECLARE @TicketingCode INT;
DECLARE @FlightID5 INT;

WHILE @Cn2 <= 6000
BEGIN
    -- fecha de redención en los últimos 5 años
    SET @DateOfRedemption = DATEADD(DAY, -FLOOR(RAND() * 365 * 5), GETDATE());

    -- (Economica, Ejecutiva, Turista)
    SET @Class = CASE WHEN RAND() < 0.33 THEN 'Economica'
                      WHEN RAND() < 0.66 THEN 'Ejecutiva'
                      ELSE 'Turista'
                 END;

    -- estado de espera (Standby: Si, No)
    SET @Standby = CASE WHEN RAND() < 0.5 THEN 'Si' ELSE 'No' END;

    SET @MealCode4 = CHAR(65 + FLOOR(RAND() * 3)); -- 'A' = 65 en ASCII, así que esto genera 'A', 'B', o 'C'
    SET @TicketingCode = FLOOR(RAND() * 3000) + 1;
    SET @FlightID5 = FLOOR(RAND() * 2000) + 1;


    INSERT INTO Coupon (DateOfRedemption, Class, Standby, MealCode, TicketingCode, FlightID)
    VALUES (@DateOfRedemption, @Class, @Standby, @MealCode4, @TicketingCode, @FlightID5);

    SET @Cn2 = @Cn2 + 1;
END;

-----------------------PiecesOfLuggage--------------------
DECLARE @Cn3 INT = 1;
DECLARE @Number1 INT;
DECLARE @Weight DECIMAL(10, 2);
DECLARE @CouponID INT;
DECLARE @CheLuggaID INT;

-- tabla temporal 
DECLARE @UniqueNumbers1 TABLE (Number INT);

WHILE @Cn3 <= 6000
BEGIN
   
    SET @Number1 = FLOOR(RAND() * 99999) + 1;
    WHILE EXISTS (SELECT 1 FROM @UniqueNumbers1 WHERE Number = @Number1)
    BEGIN
        SET @Number1 = FLOOR(RAND() * 99999) + 1;  
    END

    INSERT INTO @UniqueNumbers1 (Number) VALUES (@Number1);

    SET @Weight = CAST(5 + (RAND() * 45) AS DECIMAL(10, 2));

    SET @CouponID = FLOOR(RAND() * 6000) + 1;

    --  (Maleta, Mochila, Bolsa, Otro)
    SET @CheLuggaID = FLOOR(RAND() * 4) + 1;

    INSERT INTO PiecesOfLuggage (Number, Weight, CouponID, CheLuggaID)
    VALUES (@Number1, @Weight, @CouponID, @CheLuggaID);

    SET @Cn3 = @Cn3 + 1;
END;


------------------------AvailableSeat------------------------------------

DECLARE @Cn4 INT = 1;
DECLARE @SeatID INT;
DECLARE @FlightID6 INT;
DECLARE @CouponID3 INT;

WHILE @Cn4 <= 888
BEGIN

    SET @SeatID = FLOOR(RAND() * 3888) + 1;
    SET @FlightID6 = FLOOR(RAND() * 2000) + 1;
    SET @CouponID3 = FLOOR(RAND() * 6000) + 1;

    INSERT INTO AvailableSeat (SeatID, FlightID, CouponID)
    VALUES (@SeatID, @FlightID6, @CouponID3);


    SET @Cn4 = @Cn4 + 1;
END;
------ para borrar los registros de una tabla ---------
/*
DELETE FROM Flight;
DELETE FROM Reservation;
DELETE FROM Scale;
DELETE FROM Payment;
DELETE FROM FlightAssignment;
DELETE FROM Passenger



-- mostrar datos  21-Bolivia

Select * From Customer;     --1   *
Select * From FineType;		--2  *
Select * From Status_Reserva;     --3 *
Select * From CustomerCategory;  --4 *
Select * From TicketCategory;   --5 *
Select * From CheckinLuggage;     --6 *
Select * From FlightStatus;		--7    *
Select * From Role;				--8   *
Select * From CrewMember;         --9  *
Select * From FlightCategory;		--10  *
Select * From PlaneModel;          --11   *
Select * From PaymentMetthod;		--12   *
Select * From Country;				--13   *
Select * From FrequentFlyerCard;   --14    *
Select * From C_Assignment;		--15       *
Select * From Airplane;		-16        *
Select * From Airline;       --17   *
Select * From City;			 --18    *
Select * From Airport;			--19    *
Select * From FlightNumber ;   --20    *
Select * From Flight;    --21    *
Select * From Scale;     --22     *
Select * From Seat;        --23   *
Select * From FlightAssignment;   --24   *
Select * From RoleAssignment;   --25    *
Select * From Reservation;    --26    *
Select * From Payment;           --27  *
Select * From StatusAssignment;    --28  *
Select * From FineAssignment;   --29  * 
Select * From Document;    --30  *
Select * From PassportType; --31  *
Select * From Passport;   --32   *
Select * From DNI;         --33    *
Select * From Passenger;   --34      *
Select * From Ticket;    --35    *
Select * From Coupon;   --36   
Select * From PiecesOfLuggage;  --36
Select * From AvailableSeat; --38

Select * From Name;
*/