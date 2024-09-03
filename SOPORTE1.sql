-- Usar la base de datos temporal para operaciones preliminares
USE tempdb;
GO

-- Verificar si la base de datos existe y eliminarla si es necesario
IF EXISTS (SELECT name FROM master.sys.databases WHERE name = N'soporte_AERO')
BEGIN
    ALTER DATABASE soporte_AERO SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE soporte_AERO;
END
GO

-- Crear la base de datos
CREATE DATABASE soporte_AERO;
GO

-- Usar la base de datos recién creada
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

-- Tabla Customer
IF OBJECT_ID('Customer', 'U') IS NOT NULL 
DROP TABLE Customer;
GO

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    DateOfBirth DATE CHECK (DateOfBirth <= GETDATE()),
    Name VARCHAR(100) NOT NULL,
    FFCNumberID INT NULL,
    CONSTRAINT FK_Customer_FFCNumber FOREIGN KEY (FFCNumberID) REFERENCES FrequentFlyerCard(FFCNumber)
        ON DELETE SET NULL ON UPDATE CASCADE
);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customer_FFCNumberID')
BEGIN
    CREATE INDEX IX_Customer_FFCNumberID ON Customer (FFCNumberID);
END;

------------------------------------------------------------------------

-- Tabla City 
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
    CustomerID INT,
    CONSTRAINT FK_Document_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

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

------------------------------------------------------------------------

-- Tabla Available Seat
IF OBJECT_ID('AvailableSeat', 'U') IS NOT NULL 
DROP TABLE AvailableSeat;
GO

CREATE TABLE AvailableSeat (
    AvailableSeatID INT PRIMARY KEY IDENTITY(1,1),
    SeatID INT,
    FlightID INT,
    CONSTRAINT FK_AvailableSeat_Seat FOREIGN KEY (SeatID) REFERENCES Seat(SeatID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_AvailableSeat_Flight FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

------------------------------------------------------------------------

-- Tabla Ticket
IF OBJECT_ID('Ticket', 'U') IS NOT NULL 
DROP TABLE Ticket;
GO

CREATE TABLE Ticket (
    TicketID INT PRIMARY KEY IDENTITY(1,1),
    TicketingCode VARCHAR(50) NOT NULL,
    Number INT NOT NULL CHECK (Number > 0),
    CustomerID INT,
    CONSTRAINT FK_Ticket_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Ticket_CustomerID')
BEGIN
    CREATE INDEX IX_Ticket_CustomerID ON Ticket (CustomerID);
END;

------------------------------------------------------------------------

-- Tabla Coupon
IF OBJECT_ID('Coupon', 'U') IS NOT NULL 
DROP TABLE Coupon;
GO

--  tabla Coupon 
CREATE TABLE Coupon (
    CouponID INT PRIMARY KEY IDENTITY(1,1),
    DateOfRedemption DATE,
    Class VARCHAR(50) CHECK (Class IN ('Economica', 'Ejecutiva', 'Turista')),
    Standby VARCHAR(50) CHECK (Standby IN ('Sí', 'No')),
    MealCode VARCHAR(50),
    TicketID INT,
    FlightID INT,
    AvailableSeatID INT,
    CONSTRAINT FK_Coupon_Ticket FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_Coupon_Flight FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_Coupon_AvailableSeat FOREIGN KEY (AvailableSeatID) REFERENCES AvailableSeat(AvailableSeatID)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO

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

------------------------------------------------------------------------

-- Tabla Passenger
IF OBJECT_ID('Passenger', 'U') IS NOT NULL 
DROP TABLE Passenger;
GO

CREATE TABLE Passenger (
    PassengerID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL,
    DateOfBirth DATE CHECK (DateOfBirth <= GETDATE()),
    PassportNumber VARCHAR(50) NOT NULL,
    Nationality VARCHAR(50),
    CustomerID INT,
    CONSTRAINT FK_Passenger_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

------------------------------------------------------------------------

-- Tabla Employee
IF OBJECT_ID('Employee', 'U') IS NOT NULL 
DROP TABLE Employee;
GO

CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL,
    DateOfBirth DATE CHECK (DateOfBirth <= GETDATE()),
    HireDate DATE CHECK (HireDate <= GETDATE()),
    Salary DECIMAL(10, 2) CHECK (Salary > 0),
    Status VARCHAR(50) CHECK (Status IN ('Activo', 'Inactivo')),
    RoleID INT,
    CONSTRAINT FK_Employee_Role FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
        ON DELETE NO ACTION ON UPDATE CASCADE
);
GO

------------------------------------------------------------------------

-- Tabla EmployeeFlightAssignment
IF OBJECT_ID('EmployeeFlightAssignment', 'U') IS NOT NULL 
DROP TABLE EmployeeFlightAssignment;
GO

CREATE TABLE EmployeeFlightAssignment (
    AssignmentID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT,
    FlightID INT,
    AssignedRole VARCHAR(50),
    CONSTRAINT FK_Assignment_Employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Assignment_Flight FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

------------------------------------------------------------------------

-- Tabla MaintenanceSchedule
IF OBJECT_ID('MaintenanceSchedule', 'U') IS NOT NULL 
DROP TABLE MaintenanceSchedule;
GO

CREATE TABLE MaintenanceSchedule (
    ScheduleID INT PRIMARY KEY IDENTITY(1,1),
    AirplaneID INT,
    ScheduledDate DATE NOT NULL,
    MaintenanceType VARCHAR(100),
    Description VARCHAR(255),
    Status VARCHAR(50) CHECK (Status IN ('Programado', 'En Progreso', 'Completado')),
    CONSTRAINT FK_Maintenance_Airplane FOREIGN KEY (AirplaneID) REFERENCES Airplane(AirplaneID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

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

-- datos en Customer
INSERT INTO Customer (DateOfBirth, Name, FFCNumberID) VALUES
('1985-06-15', 'Juan Pérez', 1001),
('1990-04-22', 'Ana Gómez', 1002),
('1982-09-10', 'Carlos Martínez', 1003),
('1995-12-05', 'María Fernández', 1004),
('1988-07-19', 'Luis Rodríguez', 1005),
('1993-11-13', 'Laura Sánchez', 1006),
('1979-03-09', 'Pedro López', 1007),
('1987-08-21', 'Sofía Torres', 1008),
('1991-05-30', 'Ricardo Ramírez', 1009),
('1994-10-11', 'Elena Morales', 1010);

------------------------------------------------------------------------

--  datos en Country
INSERT INTO Country (CountryName) VALUES
('España'),
('Francia'),
('Alemania'),
('Italia'),
('Portugal');

------------------------------------------------------------------------

--  datos en City
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

--datos en Airport
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
('2024-08-04 18:00:00', 'Vuelo a Málaga', 'Nacional', 'Ryanair', 4, 5, 4),
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

--  datos en AvailableSeat
INSERT INTO AvailableSeat (SeatID, FlightID) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2),
(5, 3),
(6, 3),
(7, 4),
(8, 4),
(9, 5),
(10, 5);

------------------------------------------------------------------------

--  datos en Ticket
INSERT INTO Ticket (TicketingCode, Number, CustomerID) VALUES
('TK1001', 12345, 1),
('TK1002', 12346, 2),
('TK1003', 12347, 3),
('TK1004', 12348, 4),
('TK1005', 12349, 5),
('TK1006', 12350, 6),
('TK1007', 12351, 7),
('TK1008', 12352, 8),
('TK1009', 12353, 9),
('TK1010', 12354, 10);

------------------------------------------------------------------------

--  datos en Coupon
INSERT INTO Coupon (DateOfRedemption, Class, Standby, MealCode, TicketID, FlightID, AvailableSeatID) VALUES
('2024-08-03', 'Economica', 'No', 'A-b', 1, 1, 1),
('2024-08-04', 'Ejecutiva', 'Sí', 'B-c', 2, 2, 2),
('2024-08-03', 'Turista', 'No', 'C-d', 3, 3, 3),
('2024-08-02', 'Economica', 'Sí', 'A-ba', 4, 4, 4),
('2024-08-05', 'Ejecutiva', 'No', 'B-ca', 5, 5, 5),
('2024-08-05', 'Turista', 'Sí', 'C-ba', 6, 6, 6),
('2024-08-02', 'Economica', 'No', 'A-bai', 7, 7, 7),
('2024-08-01', 'Ejecutiva', 'Sí', 'B-cai', 8, 8, 8),
('2024-08-01', 'Turista', 'No', 'C-bai', 9, 9, 9),
('2024-07-31', 'Economica', 'Sí', 'A-baio', 10, 10, 10);

------------------------------------------------------------------------

--  datos en PiecesOfLuggage
INSERT INTO PiecesOfLuggage (Number, Weight, CouponID) VALUES
(1, 23.5, 1),
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

--  datos en Passenger
INSERT INTO Passenger (Name, DateOfBirth, PassportNumber, Nationality, CustomerID) VALUES
('José Álvarez', '1980-12-11', 'A1234567', 'Española', 1),
('Isabel Martínez', '1992-03-20', 'B2345678', 'Española', 2),
('Fernando López', '1985-06-25', 'C3456789', 'Española', 3),
('Rosa González', '1978-11-09', 'D4567890', 'Española', 4),
('Jorge Sánchez', '1990-04-15', 'E5678901', 'Española', 5),
('Marta Gómez', '1983-07-28', 'F6789012', 'Española', 6),
('Alberto Ruiz', '1987-09-14', 'G7890123', 'Española', 7),
('Sonia Pérez', '1991-10-30', 'H8901234', 'Española', 8),
('Manuel Fernández', '1984-01-20', 'I9012345', 'Española', 9),
('Ana Belén Morales', '1993-02-17', 'J0123456', 'Española', 10);

------------------------------------------------------------------------

--  datos en Role
INSERT INTO Role (RoleName, Description) VALUES
('Piloto', 'Responsable de volar el avión'),
('Copiloto', 'Asiste al piloto en el vuelo'),
('Azafata', 'Atiende a los pasajeros durante el vuelo'),
('Mecánico', 'Encargado del mantenimiento del avión'),
('Operador de Ventas', 'Gestiona la venta de boletos'),
('Agente de Check-in', 'Realiza el check-in de los pasajeros'),
('Gerente de Aeropuerto', 'Supervisa las operaciones en el aeropuerto'),
('Especialista en Seguridad', 'Asegura la seguridad en el aeropuerto'),
('Administrador de Flotas', 'Gestiona la flota de aviones'),
('Asistente de Servicio a Bordo', 'Ofrece servicios a bordo del avión');

------------------------------------------------------------------------

--  datos en Employee
INSERT INTO Employee (Name, DateOfBirth, HireDate, Salary, Status, RoleID) VALUES
('Carlos Martínez', '1975-03-01', '2010-05-15', 3000.00, 'Activo', 1),
('Laura Fernández', '1980-09-10', '2012-08-23', 2500.00, 'Activo', 2),
('Juan Pérez', '1988-02-20', '2015-12-01', 2200.00, 'Activo', 3),
('Sofía López', '1985-04-25', '2017-06-10', 2700.00, 'Activo', 4),
('Antonio Gómez', '1990-11-11', '2018-03-18', 2900.00, 'Activo', 5),
('Marta Rodríguez', '1982-07-30', '2019-09-05', 2600.00, 'Activo', 6),
('Ricardo Sánchez', '1978-01-15', '2020-04-12', 2800.00, 'Activo', 7),
('Isabel Morales', '1984-10-30', '2021-02-22', 3000.00, 'Activo', 8),
('Javier Ramírez', '1992-06-18', '2022-07-16', 3100.00, 'Activo', 9),
('Ana Ruiz', '1987-03-25', '2023-01-10', 3200.00, 'Activo', 10);

------------------------------------------------------------------------

-- datos en EmployeeFlightAssignment
INSERT INTO EmployeeFlightAssignment (EmployeeID, FlightID, AssignedRole) VALUES
(1, 1, 'Piloto'),
(2, 1, 'Copiloto'),
(3, 1, 'Azafata'),
(4, 2, 'Azafata'),
(5, 2, 'Operador de Ventas'),
(6, 3, 'Agente de Check-in'),
(7, 4, 'Especialista en Seguridad'),
(8, 4, 'Mecánico'),
(9, 5, 'Gerente de Aeropuerto'),
(10, 5, 'Administrador de Flotas');

------------------------------------------------------------------------

--  datos en MaintenanceSchedule
INSERT INTO MaintenanceSchedule (AirplaneID, ScheduledDate, MaintenanceType, Description, Status) VALUES
(1, '2024-09-15', 'Revisión General', 'Revisión de sistemas y motores', 'Programado'),
(2, '2024-10-20', 'Cambio de Aceite', 'Cambio de aceite y filtros', 'Programado'),
(3, '2024-11-05', 'Revisión de Motores', 'Inspección de motores', 'Completado'),
(4, '2024-12-10', 'Revisión de Aviónica', 'Revisión de sistemas avionicos', 'Completado'),
(5, '2025-01-15', 'Mantenimiento de Ruedas', 'Inspección y cambio de ruedas', 'En Progreso'),
(6, '2025-02-20', 'Revisión de Sistemas de Combustible', 'Inspección de sistemas de combustible', 'Programado'),
(7, '2025-03-10', 'Revisión de Estructura', 'Inspección estructural', 'Programado'),
(8, '2025-04-25', 'Revisión de Cabina', 'Inspección de sistemas de cabina', 'Completado'),
(9, '2025-05-30', 'Revisión de Sistemas de Navegación', 'Revisión de sistemas de navegación', 'En Progreso'),
(10, '2025-06-15', 'Mantenimiento de Motor', 'Mantenimiento preventivo del motor', 'Programado');

------------------------------------------------------------------------

--  datos en Service
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
(2, 1, 5),
(2, 3, 6),
(3, 2, 7),
(3, 4, 8),
(4, 1, 9),
(4, 5, 10),
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

-- datos en Payment
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
INSERT INTO Document (DocumentType, DocumentNumber, IssueDate, ExpiryDate, CustomerID) VALUES
('Pasaporte', '123456789', '2020-01-01', '2030-01-01', 1),
('Licencia de Conducir', '987654321', '2018-05-05', '2028-05-05', 2),
('ID Nacional', '564738291', '2019-03-03', NULL, 3),
('Pasaporte', '192837465', '2021-02-02', '2031-02-02', 4),
('Licencia de Conducir', '817263545', '2017-07-07', '2027-07-07', 5);

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
SELECT * FROM Passenger;
SELECT * FROM Role;
SELECT * FROM Employee;
SELECT * FROM EmployeeFlightAssignment;
SELECT * FROM MaintenanceSchedule;
SELECT * FROM Service;
SELECT * FROM InFlightService;
SELECT * FROM Booking;
SELECT * FROM Payment;
SELECT * FROM Document;
SELECT * FROM Country;
SELECT * FROM City;
