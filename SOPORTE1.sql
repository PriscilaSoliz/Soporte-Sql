﻿-- Usar la base de datos temporal para operaciones preliminares
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

-- Usar la base de datos recien creada
USE soporte_AERO;
GO

------------------------------------------------------------------------
------------------------------------------------------------------------

-- Tabla Frequent Flyer Card
IF OBJECT_ID('FrequentFlyerCard', 'U') IS NOT NULL 
DROP TABLE FrequentFlyerCard;
GO

CREATE TABLE FrequentFlyerCard (
    FFCNumber INT PRIMARY KEY,
    Miles INT CHECK (Miles >= 0),
    MealCode VARCHAR(50) CHECK (MealCode IN ('A', 'B', 'C'))
);
GO

------------------------------------------------------------------------

-- Tabla Country
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

-- Tabla Plane Model
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

------------------------------------------------------------------------

-- Tabla Role
IF OBJECT_ID('Role', 'U') IS NOT NULL 
DROP TABLE Role;
GO

CREATE TABLE Role (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName VARCHAR(50) NOT NULL UNIQUE,
    Description VARCHAR(255)
);
GO

------------------------------------------------------------------------

-- Tabla Service
IF OBJECT_ID('Service', 'U') IS NOT NULL 
DROP TABLE Service;
GO

CREATE TABLE Service (
    ServiceID INT PRIMARY KEY IDENTITY(1,1),
    ServiceType VARCHAR(50) NOT NULL,
    Description VARCHAR(255)
);
GO

------------------------------------------------------------------------
------------------------------------------------------------------------
-- Tabla categoría de cliente
IF OBJECT_ID('Customercategory', 'U') IS NOT NULL 
DROP TABLE Customercategory;
GO

CREATE TABLE Customercategory (
    id INT IDENTITY(1,1) PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    CONSTRAINT CHK_CustomerCategory_Name CHECK (category_name IN ('Regular', 'Frecuente'))
);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_CustomerCategory_Name')
BEGIN
    CREATE INDEX IX_CustomerCategory_Name ON customercategory (category_name);
END;

------------------------------------------------------------------------

-- Tabla Cliente
IF OBJECT_ID('Customer', 'U') IS NOT NULL 
DROP TABLE Customer;
GO

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    DateOfBirth DATE CHECK (DateOfBirth <= GETDATE() AND DateOfBirth >= DATEADD(YEAR, -100, GETDATE())),
    Name VARCHAR(100) NOT NULL,
    FFCNumberID INT NULL,
	CustomerCategoryID INT NULL,
    CONSTRAINT FK_Customer_FFCNumber FOREIGN KEY (FFCNumberID) REFERENCES FrequentFlyerCard(FFCNumber)
        ON DELETE SET NULL, 
	CONSTRAINT FK_Customer_Category FOREIGN KEY (CustomerCategoryID) REFERENCES Customercategory(id)
        ON DELETE SET NULL ON UPDATE CASCADE 
);
GO

-- Indice en la columna Name
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customer_Name')
BEGIN
	CREATE INDEX IX_Customer_Name ON Customer (Name);
END;

-- Indice en la columna FFCNumberID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customer_FFCNumberID')
BEGIN
    CREATE INDEX IX_Customer_FFCNumberID ON Customer (FFCNumberID);
END;

------------------------------------------------------------------------

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

------------------------------------------------------------------------

-- Tabla Document 
IF OBJECT_ID('Document', 'U') IS NOT NULL 
DROP TABLE Document;
GO

CREATE TABLE Document (
    DocumentID INT PRIMARY KEY IDENTITY(1,1),
    DocumentType VARCHAR(50) NOT NULL CHECK (DocumentType IN ('Pasaporte', 'Licencia de Conducir', 'ID Nacional')),
    DocumentNumber VARCHAR(50) NOT NULL UNIQUE,
    IssueDate DATE NOT NULL,
    ExpiryDate DATE,
    IssuingCountryID INT,
    CustomerID INT,
    CONSTRAINT FK_Document_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE, -- Permite que los documentos se eliminen o actualicen junto con customer.
    CONSTRAINT FK_Document_Country FOREIGN KEY (IssuingCountryID) REFERENCES Country(CountryID)
        ON DELETE SET NULL -- Permitir NULL si el país es eliminado
);
GO

-- Índice para DocumentType
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Document_DocumentType')
BEGIN
    CREATE INDEX IX_Document_DocumentType ON Document(DocumentType);
END;

-- Índice para IssuingCountryID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Document_IssuingCountryID')
BEGIN
    CREATE INDEX IX_Document_IssuingCountryID ON Document(IssuingCountryID);
END;

------------------------------------------------------------------------

-- Tabla Airport 
IF OBJECT_ID('Airport', 'U') IS NOT NULL 
DROP TABLE Airport;
GO

CREATE TABLE Airport (
    AirportID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL UNIQUE,
    CountryID INT,
    CONSTRAINT FK_Airport_Country FOREIGN KEY (CountryID) REFERENCES Country(CountryID)
        ON DELETE NO ACTION ON UPDATE CASCADE
);
GO

-- índice para optimizar CountryID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Airport_CountryID')
BEGIN
    CREATE INDEX IX_Airport_CountryID ON Airport (CountryID);
END;

-- índice para el campo Name
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Airport_Name')
BEGIN
    CREATE INDEX IX_Airport_Name ON Airport (Name);
END;

------------------------------------------------------------------------

-- Tabla Airplane
IF OBJECT_ID('Airplane', 'U') IS NOT NULL 
DROP TABLE Airplane;
GO

CREATE TABLE Airplane (
    AirplaneID INT PRIMARY KEY IDENTITY(1,1),
    RegistrationNumber VARCHAR(50) NOT NULL UNIQUE,
    BeginOfOperation DATE NOT NULL,
    Status VARCHAR(50) CHECK (Status IN ('Operativo', 'Mantenimiento', 'Inactivo')),
    PlaneModID INT NOT NULL,
    CONSTRAINT FK_Airplane_PlaneModel FOREIGN KEY (PlaneModID) REFERENCES PlaneModel(PlaneModelID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- índice para el campo RegistrationNumber
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Airplane_RegistrationNumber')
BEGIN
    CREATE INDEX IX_Airplane_RegistrationNumber ON Airplane (RegistrationNumber);
END;


-- índice para  el campo PlaneModID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Airplane_PlaneModID')
BEGIN
    CREATE INDEX IX_Airplane_PlaneModID ON Airplane (PlaneModID);
END;

------------------------------------------------------------------------

-- Tabla Seat
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

------------------------------------------------------------------------

-- Tabla FlightNumber
IF OBJECT_ID('FlightNumber', 'U') IS NOT NULL 
DROP TABLE FlightNumber;
GO

CREATE TABLE FlightNumber (
    FlightNumberID INT PRIMARY KEY IDENTITY(1,1),
    DepartureTime DATETIME NOT NULL,
    Description VARCHAR(255) NOT NULL,
    Type VARCHAR(50) CHECK (Type IN ('Nacional', 'Internacional')),
    Airline VARCHAR(100),
    StartAirportID INT,
    GoalAirportID INT,
    PlaneModelID INT,
    CONSTRAINT FK_FlightNumber_StartAirport FOREIGN KEY (StartAirportID) REFERENCES Airport(AirportID)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_FlightNumber_GoalAirport FOREIGN KEY (GoalAirportID) REFERENCES Airport(AirportID)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_FlightNumber_PlaneModel FOREIGN KEY (PlaneModelID) REFERENCES PlaneModel(PlaneModelID)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FlightNumber_DepartureTime')
BEGIN
    CREATE INDEX IX_FlightNumber_DepartureTime ON FlightNumber (DepartureTime);
END;

-- índice para optimizar el campo Type
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FlightNumber_Type')
BEGIN
    CREATE INDEX IX_FlightNumber_Type ON FlightNumber (Type);
END;

------------------------------------------------------------------------

-- Tabla Flight
IF OBJECT_ID('Flight', 'U') IS NOT NULL 
DROP TABLE Flight;
GO

CREATE TABLE Flight (
    FlightID INT PRIMARY KEY IDENTITY(1,1),
    BoardingTime TIME,
    FlightDate DATE NOT NULL,
    Gate VARCHAR(50),
    CheckInCounter VARCHAR(50),
    FlightNumID INT,
    CONSTRAINT FK_Flight_FlightNumber FOREIGN KEY (FlightNumID) REFERENCES FlightNumber(FlightNumberID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- Índice en FlightNumID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Flight_FlightNumID')
BEGIN
    CREATE INDEX IX_Flight_FlightNumID ON Flight (FlightNumID);
END;

------------------------------------------------------------------------

-- Tabla categoría de boleto
IF OBJECT_ID('ticketcategory', 'U') IS NOT NULL 
DROP TABLE ticketcategory;
GO

CREATE TABLE ticketcategory (
    id INT IDENTITY(1,1) PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    CONSTRAINT CHK_TicketCategory_Name CHECK (category_name IN ('Primera clase', 'Ejecutiva', 'Premium', 'Económica'))
);
GO

-- Índice para category_name
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_TicketCategory_Name')
BEGIN
    CREATE INDEX IX_TicketCategory_Name ON ticketcategory (category_name);
END;

------------------------------------------------------------------------
-- Tabla Ticket
IF OBJECT_ID('Ticket', 'U') IS NOT NULL 
DROP TABLE Ticket;
GO

CREATE TABLE Ticket (
    TicketingCode INT IDENTITY(1,1) PRIMARY KEY,
    Number INT NOT NULL CHECK (Number > 0),
    CustomerID INT,
	TicketCategoryID INT,
    CONSTRAINT FK_Ticket_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE,-- Eliminar o actualiza dependiendo al cliente
    CONSTRAINT FK_Ticket_TicketCategory FOREIGN KEY (TicketCategoryID) REFERENCES ticketcategory(id)
        ON DELETE SET NULL ON UPDATE CASCADE -- Permitir NULL o Actualizar si la categoría del ticket es eliminada o actualizada
);
GO

-- Índice en CustomerID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Ticket_CustomerID')
BEGIN
    CREATE INDEX IX_Ticket_CustomerID ON Ticket (CustomerID);
END;

-- Índice en Number
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Ticket_Number')
BEGIN
    CREATE INDEX IX_Ticket_Number ON Ticket (Number);
END;

------------------------------------------------------------------------

-- Tabla cupón
IF OBJECT_ID('Coupon', 'U') IS NOT NULL 
DROP TABLE Coupon;
GO

CREATE TABLE Coupon (
    CouponID INT PRIMARY KEY IDENTITY(1,1),
    DateOfRedemption DATE,
    Class VARCHAR(50) CHECK (Class IN ('Economica', 'Ejecutiva', 'Turista')),
    Standby VARCHAR(50) CHECK (Standby IN ('Si', 'No')),
    MealCode VARCHAR(50),
    TicketID INT,
    FlightID INT,
    CONSTRAINT FK_Coupon_Ticket FOREIGN KEY (TicketID) REFERENCES Ticket(TicketingCode)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_Coupon_Flight FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
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

------------------------------------------------------------------------

-- Tabla Available Seat
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
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_AvailableSeat_Coupon FOREIGN KEY (CouponID) REFERENCES Coupon(CouponID)
        ON DELETE CASCADE ON UPDATE CASCADE
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

------------------------------------------------------------------------

-- Tabla Pieces of Luggage
IF OBJECT_ID('PiecesOfLuggage', 'U') IS NOT NULL 
DROP TABLE PiecesOfLuggage;
GO

CREATE TABLE PiecesOfLuggage (
    LuggageID INT PRIMARY KEY IDENTITY(1,1),
    Number INT CHECK (Number > 0),
    Weight DECIMAL(10, 2) CHECK (Weight > 0),
    CouponID INT,
    CONSTRAINT FK_Luggage_Coupon FOREIGN KEY (CouponID) REFERENCES Coupon(CouponID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- Indice en Number
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PiecesOfLuggage_Number')
BEGIN
    CREATE INDEX IX_PiecesOfLuggage_Number ON PiecesOfLuggage (Number);
END;

-- Indice en Weight
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PiecesOfLuggage_Weight')
BEGIN
    CREATE INDEX IX_PiecesOfLuggage_Weight ON PiecesOfLuggage (Weight);
END;

------------------------------------------------------------------------

-- Tabla Employee
IF OBJECT_ID('Employee', 'U') IS NOT NULL 
DROP TABLE Employee;
GO

CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL,
    DateOfBirth DATE CHECK (DateOfBirth <= GETDATE() AND DateOfBirth >= DATEADD(YEAR, -70, GETDATE())),
    HireDate DATE CHECK (HireDate <= GETDATE()),
    Salary DECIMAL(10, 2) CHECK (Salary > 0),
    Status VARCHAR(50) CHECK (Status IN ('Activo', 'Inactivo')),
    RoleID INT,
    CONSTRAINT FK_Employee_Role FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
        ON DELETE NO ACTION ON UPDATE CASCADE
);
GO

-- Índice en RoleID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Employee_RoleID')
BEGIN
    CREATE INDEX IX_Employee_RoleID ON Employee (RoleID);
END;

------------------------------------------------------------------------

-- Tabla EmployeeFlightAssignment
IF OBJECT_ID('EmployeeFlightAssignment', 'U') IS NOT NULL 
DROP TABLE EmployeeFlightAssignment;
GO

CREATE TABLE EmployeeFlightAssignment (
    AssignmentID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT,
    FlightID INT,
    CONSTRAINT FK_Assignment_Employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Assignment_Flight FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- Índice para EmployeeID, FlightID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_EmployeeFlightAssignment_EmployeeID_FlightID')
BEGIN
    CREATE INDEX IX_EmployeeFlightAssignment_EmployeeID_FlightID ON EmployeeFlightAssignment (EmployeeID, FlightID);
END;

------------------------------------------------------------------------

-- Tabla InFlightService
IF OBJECT_ID('InFlightService', 'U') IS NOT NULL 
DROP TABLE InFlightService;
GO

CREATE TABLE InFlightService (
    ServiceProvidedID INT PRIMARY KEY IDENTITY(1,1),
    FlightID INT,
    ServiceID INT,
    ProvidedByEmployeeID INT,
    CONSTRAINT FK_Service_Flight FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Service_Service FOREIGN KEY (ServiceID) REFERENCES Service(ServiceID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Service_Employee FOREIGN KEY (ProvidedByEmployeeID) REFERENCES Employee(EmployeeID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
GO

-- Índice en FlightID y ServiceID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_InFlightService_FlightID_ServiceID')
BEGIN
    CREATE INDEX IX_InFlightService_FlightID_ServiceID ON InFlightService (FlightID, ServiceID);
END;

-- Índice en ProvidedByEmployeeID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_InFlightService_ProvidedByEmployeeID')
BEGIN
    CREATE INDEX IX_InFlightService_ProvidedByEmployeeID ON InFlightService (ProvidedByEmployeeID);
END;

------------------------------------------------------------------------

-- Tabla Booking
IF OBJECT_ID('Booking', 'U') IS NOT NULL 
DROP TABLE Booking;
GO

CREATE TABLE Booking (
    BookingID INT PRIMARY KEY IDENTITY(1,1),
    BookingDate DATE NOT NULL,
    Status VARCHAR(50) CHECK (Status IN ('Confirmada', 'Cancelada')),
    CustomerID INT,
    FlightID INT,
    CONSTRAINT FK_Booking_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Booking_Flight FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Booking_CustomerID')
BEGIN
    CREATE INDEX IX_Booking_CustomerID ON Booking (CustomerID);
END;

-- índice para optimizar el campo BookingDate

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Booking_BookingDate')
BEGIN
    CREATE INDEX IX_Booking_BookingDate ON Booking (BookingDate);
END;

------------------------------------------------------------------------

-- Tabla Payment
IF OBJECT_ID('Payment', 'U') IS NOT NULL 
DROP TABLE Payment;
GO

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    Amount DECIMAL(10, 2) CHECK (Amount > 0),
    PaymentDate DATE NOT NULL,
    PaymentMethod VARCHAR(50),
    BookingID INT,
    CONSTRAINT FK_Payment_Booking FOREIGN KEY (BookingID) REFERENCES Booking(BookingID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Payment_BookingID')
BEGIN
    CREATE INDEX IX_Payment_BookingID ON Payment (BookingID);
END;

-- índice para optimizar el campo PaymentDate

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Payment_PaymentDate')
BEGIN
    CREATE INDEX IX_Payment_PaymentDate ON Payment (PaymentDate);
END;

------------------------------------------------------------------------
------------------------------------------------------------------------

--  datos en FrequentFlyerCard
INSERT INTO FrequentFlyerCard (FFCNumber, Miles, MealCode) VALUES
(1001, 5000, 'A'),
(1002, 10000, 'B'),
(1003, 15000, 'C'),
(1004, 20000, 'A'),
(1005, 25000, 'B'),
(1006, 30000, 'C'),
(1007, 35000, 'A'),
(1008, 40000, 'B'),
(1009, 45000, 'C'),
(1010, 50000, 'A');

------------------------------------------------------------------------

-- datos en Customercategory
INSERT INTO Customercategory (category_name) VALUES
('Regular'),
('Frecuente');

------------------------------------------------------------------------

-- datos en Customer
INSERT INTO Customer (DateOfBirth, Name, FFCNumberID, CustomerCategoryID) VALUES
('1985-06-15', 'Juan Pérez', 1001, 1),  -- 1 corresponde a 'Regular'
('1990-04-22', 'Ana Gómez', 1002, 2),  --  2 corresponde a 'Frecuente'
('1982-09-10', 'Carlos Martínez', 1003, 1),
('1995-12-05', 'María Fernández', 1004, 2),
('1988-07-19', 'Luis Rodríguez', 1005, 1),
('1993-11-13', 'Laura Sánchez', 1006, 2),
('1979-03-09', 'Pedro López', 1007, 1),
('1987-08-21', 'Sofía Torres', 1008, 2),
('1991-05-30', 'Ricardo Ramírez', 1009, 1),
('1994-10-11', 'Elena Morales', 1010, 2);

------------------------------------------------------------------------

-- Datos en Country
INSERT INTO Country (CountryName) VALUES
('España'),
('Francia'),
('Alemania'),
('Italia'),
('Portugal');

------------------------------------------------------------------------

-- Datos en City
INSERT INTO City (CityName, CountryID) VALUES
('Madrid', 1),
('Barcelona', 1),
('Sevilla', 1),
('París', 2),
('Lyon', 2),
('Berlín', 3),
('Múnich', 3),
('Roma', 4),
('Milán', 4),
('Lisboa', 5);

------------------------------------------------------------------------

-- Datos en Airport
INSERT INTO Airport (Name, CountryID) VALUES
('Aeropuerto Internacional de Madrid', 1),
('Aeropuerto de Barcelona-El Prat', 1),
('Aeropuerto de Valencia', 1),
('Aeropuerto de Málaga-Costa del Sol', 1),
('Aeropuerto de Sevilla', 1),
('Aeropuerto de Bilbao', 1),
('Aeropuerto de Alicante', 1),
('Aeropuerto de Palma de Mallorca', 1),
('Aeropuerto de Gran Canaria', 1),
('Aeropuerto de Tenerife Sur', 1);

------------------------------------------------------------------------

--  datos en PlaneModel
INSERT INTO PlaneModel (Description, Graphic) VALUES
('Boeing 737', NULL),
('Airbus A320', NULL),
('Boeing 787 Dreamliner', NULL),
('Airbus A350', NULL),
('Boeing 747', NULL),
('Airbus A380', NULL),
('Embraer E190', NULL),
('Boeing 767', NULL),
('Airbus A321', NULL),
('Boeing 777', NULL);

------------------------------------------------------------------------

--  datos en Airplane
INSERT INTO Airplane (RegistrationNumber, BeginOfOperation, Status, PlaneModID) VALUES
('EC-MAD', '2015-01-01', 'Operativo', 1),
('EC-BCN', '2016-03-15', 'Mantenimiento', 2),
('EC-VAL', '2017-07-20', 'Operativo', 3),
('EC-MAL', '2018-11-01', 'Operativo', 4),
('EC-SEA', '2019-04-10', 'Inactivo', 5),
('EC-BIL', '2020-09-25', 'Operativo', 6),
('EC-ALI', '2021-02-18', 'Operativo', 7),
('EC-PAL', '2022-06-30', 'Mantenimiento', 8),
('EC-GCN', '2023-01-15', 'Operativo', 9),
('EC-TFS', '2024-05-05', 'Operativo', 10);

------------------------------------------------------------------------

--  datos en Seat
INSERT INTO Seat (Size, Number, Location, PlaneModelID) VALUES
('Turista', '12A', 'Pasillo', 1),
('Turista', '12B', 'Ventana', 1),
('Ejecutiva', '1A', 'Pasillo', 2),
('Ejecutiva', '1B', 'Ventana', 2),
('Ejecutiva', '3A', 'Central', 3),
('Ejecutiva', '3B', 'Central', 3),
('Turista', '15A', 'Ventana', 4),
('Turista', '15B', 'Pasillo', 4),
('Ejecutiva', '4A', 'Ventana', 5),
('Economica', '20A', 'Pasillo', 6);

------------------------------------------------------------------------

--  datos en FlightNumber
INSERT INTO FlightNumber (DepartureTime, Description, Type, Airline, StartAirportID, GoalAirportID, PlaneModelID) VALUES
('2024-08-04 10:00:00', 'Vuelo a Madrid', 'Internacional', 'Iberia', 1, 2, 1),
('2024-08-04 14:00:00', 'Vuelo a Barcelona', 'Nacional', 'Vueling', 2, 3, 2),
('2024-08-04 16:00:00', 'Vuelo a Valencia', 'Nacional', 'Air Europa', 3, 4, 3),
('2024-08-04 18:00:00', 'Vuelo a M�laga', 'Nacional', 'Ryanair', 4, 5, 4),
('2024-08-04 20:00:00', 'Vuelo a Sevilla', 'Nacional', 'Iberia', 5, 6, 5),
('2024-08-06 08:00:00', 'Vuelo a Bilbao', 'Nacional', 'Vueling', 6, 7, 6),
('2024-08-06 11:00:00', 'Vuelo a Alicante', 'Nacional', 'Air Europa', 7, 8, 7),
('2024-08-06 13:00:00', 'Vuelo a Palma de Mallorca', 'Nacional', 'Ryanair', 8, 9, 8),
('2024-08-06 15:00:00', 'Vuelo a Gran Canaria', 'Internacional', 'Iberia', 9, 10, 9),
('2024-08-06 17:00:00', 'Vuelo a Tenerife Sur', 'Internacional', 'Vueling', 10, 1, 10);

------------------------------------------------------------------------

--  datos en Flight
INSERT INTO Flight (BoardingTime, FlightDate, Gate, CheckInCounter, FlightNumID) VALUES
('09:30:00', '2024-08-04', 'A1', '1', 1),
('13:30:00', '2024-08-04', 'B2', '2', 2),
('15:30:00', '2024-08-04', 'C3', '3', 3),
('17:30:00', '2024-08-04', 'D4', '4', 4),
('19:30:00', '2024-08-04', 'E5', '5', 5),
('07:30:00', '2024-08-06', 'F6', '6', 6),
('10:30:00', '2024-08-06', 'G7', '7', 7),
('12:30:00', '2024-08-06', 'H8', '8', 8),
('14:30:00', '2024-08-06', 'I9', '9', 9),
('16:30:00', '2024-08-06', 'J10', '10', 10);

------------------------------------------------------------------------
-- datos en ticketcategory
INSERT INTO ticketcategory (category_name) VALUES
('Primera clase'),
('Ejecutiva'),
('Premium'),
('Económica');

------------------------------------------------------------------------

-- Datos en Ticket
INSERT INTO Ticket (Number, CustomerID, TicketCategoryID) VALUES
(12345, 1, 1), --  'Primera clase' tiene id 1
(12346, 2, 2), --  'Ejecutiva' tiene id 2
(12347, 3, 3), --  'Premium' tiene id 3
(12348, 4, 4), --  'Económica' tiene id 4
(12349, 5, 1),
(12350, 6, 2),
(12351, 7, 3),
(12352, 8, 4),
(12353, 9, 1),
(12354, 10, 2);

------------------------------------------------------------------------
--  Datos en Coupon
INSERT INTO Coupon (DateOfRedemption, Class, Standby, MealCode, TicketID, FlightID) VALUES
('2024-08-03', 'Economica', 'No', 'A-b', 1, 1),
('2024-08-04', 'Ejecutiva', 'Si', 'B-c', 2, 2),
('2024-08-03', 'Turista', 'No', 'C-d', 3, 3),
('2024-08-02', 'Economica', 'Si', 'A-ba', 4, 4),
('2024-08-05', 'Ejecutiva', 'No', 'B-ca', 5, 5),
('2024-08-05', 'Turista', 'Si', 'C-ba', 6, 6),
('2024-08-02', 'Economica', 'No', 'A-bai', 7, 7),
('2024-08-01', 'Ejecutiva', 'Si', 'B-cai', 8, 8),
('2024-08-01', 'Turista', 'No', 'C-bai', 9, 9),
('2024-07-31', 'Economica', 'Si', 'A-baio', 10, 10);

------------------------------------------------------------------------

--  datos en AvailableSeat
INSERT INTO AvailableSeat (SeatID, FlightID, CouponID) VALUES
(2, 1, 2),
(3, 2, 3),
(4, 2, 4),
(5, 3, 5),
(6, 3, 6),
(7, 4, 7),
(8, 4, 8),
(9, 5, 9),
(10, 5, 10);

------------------------------------------------------------------------

--  datos en PiecesOfLuggage
INSERT INTO PiecesOfLuggage (Number, Weight, CouponID) VALUES
(2, 15.0, 2),
(3, 18.2, 3),
(4, 22.0, 4),
(5, 20.5, 5),
(6, 17.8, 6),
(7, 19.3, 7),
(8, 21.0, 8),
(9, 25.4, 9),
(10, 16.7, 10);

------------------------------------------------------------------------

-- Datos en Role
INSERT INTO Role (RoleName, Description) VALUES
('Piloto', 'Responsable de volar el avión'),
('Copiloto', 'Asiste al piloto en el vuelo'),
('Azafata', 'Atiende a los pasajeros durante el vuelo'),
('Asistente de Servicio a Bordo', 'Ofrece servicios a bordo del avión');

------------------------------------------------------------------------

-- Datos en Employee
INSERT INTO Employee (Name, DateOfBirth, HireDate, Salary, Status, RoleID) VALUES
('Carlos Martínez', '1975-03-01', '2010-05-15', 3000.00, 'Activo', 1), -- Piloto
('Laura Fernández', '1980-09-10', '2012-08-23', 2500.00, 'Activo', 2), -- Copiloto
('Juan Pérez', '1988-02-20', '2015-12-01', 2200.00, 'Activo', 3), -- Azafata
('Sofía López', '1985-04-25', '2017-06-10', 2700.00, 'Activo', 4); -- Asistente de Servicio a Bordo

------------------------------------------------------------------------

-- Datos en EmployeeFlightAssignment
INSERT INTO EmployeeFlightAssignment (EmployeeID, FlightID) VALUES
(1, 1), 
(2, 1), 
(3, 1), 
(4, 1);

------------------------------------------------------------------------

-- Datos en Service
INSERT INTO Service (ServiceType, Description) VALUES
('Comida', 'Servicio de comida a bordo'),
('Bebida', 'Servicio de bebidas a bordo'),
('Entretenimiento', 'Sistema de entretenimiento a bordo'),
('Wi-Fi', 'Conexión a Internet durante el vuelo'),
('Asistencia Médica', 'Atención médica en caso de emergencias'),
('Acompañamiento', 'Acompañamiento para menores de edad'),
('Cargador de Dispositivos', 'Cargador para dispositivos electrónicos'),
('Kit de Higiene', 'Kit de higiene personal'),
('Almohada', 'Almohada para comodidad durante el vuelo'),
('Cobija', 'Cobija para mayor confort');

------------------------------------------------------------------------

-- datos en InFlightService
INSERT INTO InFlightService (FlightID, ServiceID, ProvidedByEmployeeID) VALUES
(1, 1, 3),
(1, 2, 4),
(5, 3, 1),
(5, 6, 2);

------------------------------------------------------------------------

--  datos en Booking
INSERT INTO Booking (BookingDate, Status, CustomerID, FlightID) VALUES
('2024-08-01', 'Confirmada', 1, 1),
('2024-08-02', 'Confirmada', 2, 2),
('2024-08-03', 'Cancelada', 3, 3),
('2024-08-04', 'Confirmada', 4, 4),
('2024-08-05', 'Confirmada', 5, 5),
('2024-08-06', 'Cancelada', 6, 6),
('2024-08-07', 'Confirmada', 7, 7),
('2024-08-08', 'Confirmada', 8, 8),
('2024-08-09', 'Confirmada', 9, 9),
('2024-08-10', 'Confirmada', 10, 10);

------------------------------------------------------------------------

-- Datos en Payment
INSERT INTO Payment (Amount, PaymentDate, PaymentMethod, BookingID) VALUES
(150.00, '2024-08-01', 'Tarjeta de Crédito', 1),
(200.00, '2024-08-02', 'Efectivo', 2),
(180.00, '2024-08-03', 'Tarjeta de Débito', 3),
(220.00, '2024-08-04', 'Tarjeta de Crédito', 4),
(250.00, '2024-08-05', 'Efectivo', 5),
(170.00, '2024-08-06', 'Tarjeta de Crédito', 6),
(160.00, '2024-08-07', 'Efectivo', 7),
(190.00, '2024-08-08', 'Tarjeta de Débito', 8),
(210.00, '2024-08-09', 'Tarjeta de Crédito', 9),
(230.00, '2024-08-10', 'Efectivo', 10);

------------------------------------------------------------------------

-- datos en Document
INSERT INTO Document (DocumentType, DocumentNumber, IssueDate, ExpiryDate, IssuingCountryID, CustomerID) VALUES
('Pasaporte', '123456789', '2020-01-01', '2030-01-01', 1, 1), -- País: España
('Licencia de Conducir', '987654321', '2018-05-05', '2028-05-05', 2, 2), -- País: Francia
('ID Nacional', '564738291', '2019-03-03', NULL, 3, 3),              -- País: Alemania
('Pasaporte', '192837465', '2021-02-02', '2031-02-02', 4, 4),        -- País: Italia
('Licencia de Conducir', '817263545', '2017-07-07', '2027-07-07', 5, 5); -- País: Portugal


------------------------------------------------------------------------
------------------------------------------------------------------------

-- mostrar datos
SELECT * FROM FrequentFlyerCard;
SELECT * FROM Customer;
SELECT * FROM Airport;
SELECT * FROM PlaneModel;
SELECT * FROM Airplane;
SELECT * FROM Seat;
SELECT * FROM FlightNumber;
SELECT * FROM Flight;
SELECT * FROM AvailableSeat;
SELECT * FROM Ticket;
SELECT * FROM Coupon;
SELECT * FROM PiecesOfLuggage;
SELECT * FROM Role;
SELECT * FROM Employee;
SELECT * FROM EmployeeFlightAssignment;
SELECT * FROM Service;
SELECT * FROM InFlightService;
SELECT * FROM Booking;
SELECT * FROM Payment;
SELECT * FROM Document;
SELECT * FROM Country;
SELECT * FROM City;