create database soporte;
use soporte

-- Tabla Frequent Flyer Card
CREATE TABLE FrequentFlyerCard (
    FFCNumber INT PRIMARY KEY,
    Miles INT,
    MealCode VARCHAR(50)
);

-- Tabla Customer
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    DateOfBirth DATE,
    Name VARCHAR(100),
    FFCNumberID INT NULL,
    FOREIGN KEY (FFCNumberID) REFERENCES FrequentFlyerCard(FFCNumber)
);

-- Tabla Airport
CREATE TABLE Airport (
    AirportID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100)
);

-- Tabla Plane Model
CREATE TABLE PlaneModel (
    PlaneModelID INT PRIMARY KEY IDENTITY(1,1),
    Description VARCHAR(255),
    Graphic VARBINARY(MAX)
);

-- Tabla Airplane
CREATE TABLE Airplane (
    AirplaneID INT PRIMARY KEY IDENTITY(1,1),
    RegistrationNumber VARCHAR(50),
    BeginOfOperation DATE,
    Status VARCHAR(50),
    PlaneModID INT,
    FOREIGN KEY (PlaneModID) REFERENCES PlaneModel(PlaneModelID)
);

-- Tabla Seat
CREATE TABLE Seat (
    SeatID INT PRIMARY KEY IDENTITY(1,1),
    Size VARCHAR(50),
    Number VARCHAR(10),
    Location VARCHAR(100),
    PlaneModelID INT,
    FOREIGN KEY (PlaneModelID) REFERENCES PlaneModel(PlaneModelID)
);

-- Tabla FlightNumber
CREATE TABLE FlightNumber (
    FlightNumberID INT PRIMARY KEY IDENTITY(1,1),
    DepartureTime DATETIME,
    Description VARCHAR(255),
    Type VARCHAR(50),
    Airline VARCHAR(100),
    StartAirportID INT,
    GoalAirportID INT,
    PlaneModelID INT,
    FOREIGN KEY (StartAirportID) REFERENCES Airport(AirportID),
    FOREIGN KEY (GoalAirportID) REFERENCES Airport(AirportID),
    FOREIGN KEY (PlaneModelID) REFERENCES PlaneModel(PlaneModelID)
);

-- Tabla Flight
CREATE TABLE Flight (
    FlightID INT PRIMARY KEY IDENTITY(1,1),
    BoardingTime TIME,
    FlightDate DATE,
    Gate VARCHAR(50),
    CheckInCounter VARCHAR(50),
    FlightNumID INT,
    FOREIGN KEY (FlightNumID) REFERENCES FlightNumber(FlightNumberID)
);


-- Tabla Available Seat
CREATE TABLE AvailableSeat (
    AvailableSeatID INT PRIMARY KEY IDENTITY(1,1),
    SeatID INT,
    FlightID INT,
    FOREIGN KEY (SeatID) REFERENCES Seat(SeatID),
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
);

-- Tabla Ticket
CREATE TABLE Ticket (
    TicketID INT PRIMARY KEY IDENTITY(1,1),
    TicketingCode VARCHAR(50),
    Number INT,
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- Tabla Coupon
CREATE TABLE Coupon (
    CouponID INT PRIMARY KEY IDENTITY(1,1),
    DateOfRedemption DATE,
    Class VARCHAR(50),
    Standby VARCHAR(50),
    MealCode VARCHAR(50),
    TicketID INT,
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID),
    FlightID INT,
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID),
    AvailableSeatID INT,
    FOREIGN KEY (AvailableSeatID) REFERENCES AvailableSeat(AvailableSeatID) 
);

-- Tabla Pieces of Luggage
CREATE TABLE PiecesOfLuggage (
    LuggageID INT PRIMARY KEY IDENTITY(1,1),
    Number INT,
    Weight DECIMAL(10, 2),
    CouponID INT,
    FOREIGN KEY (CouponID) REFERENCES Coupon(CouponID)
);

-- Almacenar información sobre los pasajeros asociados a un boleto -- YA TENGO
CREATE TABLE Passenger (
    PassengerID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100),
    DateOfBirth DATE,
    PassportNumber VARCHAR(50),
    Nationality VARCHAR(50),
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- Roles dentro de la aerolinea -- NO TENGO
CREATE TABLE Role (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName VARCHAR(50),
    Description VARCHAR(255)
);

-- Informacion de los empleados
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100),
    DateOfBirth DATE,
    HireDate DATE,
    Salary DECIMAL(10, 2),
    Status VARCHAR(50),
    RoleID INT,
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
);

-- Asignar empleados a vuelos específicos
CREATE TABLE EmployeeFlightAssignment (
    AssignmentID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT,
    FlightID INT,
    AssignedRole VARCHAR(50),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
);

-- Planificar y gestionar las revisiones y mantenimiento regular de los aviones.
CREATE TABLE MaintenanceSchedule (
    ScheduleID INT PRIMARY KEY IDENTITY(1,1),
    AirplaneID INT,
    ScheduledDate DATE,
    MaintenanceType VARCHAR(100),
    Description VARCHAR(255),
    Status VARCHAR(50),
    FOREIGN KEY (AirplaneID) REFERENCES Airplane(AirplaneID)
);

-- Todos los servicios que la aerolínea puede ofrecer durante un vuelo.
CREATE TABLE Service (
    ServiceID INT PRIMARY KEY IDENTITY(1,1),
    ServiceType VARCHAR(50),
    Description VARCHAR(255)
);

-- Registrar los servicios ofrecidos durante un vuelo, como comidas, entretenimiento, y atención médica
CREATE TABLE InFlightService (
    ServiceProvidedID INT PRIMARY KEY IDENTITY(1,1),
    FlightID INT,
    ServiceID INT,
    ProvidedByEmployeeID INT,
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID),
    FOREIGN KEY (ServiceID) REFERENCES Service(ServiceID),
    FOREIGN KEY (ProvidedByEmployeeID) REFERENCES Employee(EmployeeID)
);

-- Tabla Booking Almacena las reservas de vuelos realizadas por los clientes.
CREATE TABLE Booking (
    BookingID INT PRIMARY KEY IDENTITY(1,1),
    BookingDate DATE,
    Status VARCHAR(50),
    CustomerID INT,
    FlightID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
);

-- Tabla Payment Almacena los pagos realizados por las reservas.
CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    Amount DECIMAL(10, 2),
    PaymentDate DATE,
    PaymentMethod VARCHAR(50),
    BookingID INT,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID)
);

-- Datos para FrequentFlyerCard
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

-- Datos para Customer
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

-- Datos para Airport
INSERT INTO Airport (Name) VALUES
('Aeropuerto Internacional de Madrid'),
('Aeropuerto de Barcelona-El Prat'),
('Aeropuerto de Valencia'),
('Aeropuerto de Málaga-Costa del Sol'),
('Aeropuerto de Sevilla'),
('Aeropuerto de Bilbao'),
('Aeropuerto de Alicante'),
('Aeropuerto de Palma de Mallorca'),
('Aeropuerto de Gran Canaria'),
('Aeropuerto de Tenerife Sur');

-- Datos para PlaneModel
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

-- Datos para Airplane
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

-- Datos para Seat
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

-- Datos para FlightNumber
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



-- Datos para Flight
INSERT INTO Flight (BoardingTime, FlightDate, Gate, CheckInCounter, FlightNumID) VALUES
('09:30:00', '2024-08-04', 'A1', '1', 1),
('13:30:00', '2024-08-04', 'B2', '2', 2),
('15:30:00', '2024-08-04', 'C3', '3', 3),
('17:30:00', '2024-08-04', 'D4', '4', 4),
('19:30:00', '2024-08-04', 'E5', '5', 5),
('07:30:00', '2024-08-06', 'F6', '6', 6),
('10:30:00', '2024-08-06', 'G7', '7', 7),
('12:30:00', '2024-08-06', 'H8', '8', 8),
('4:30:00', '2024-08-06', 'I9', '9', 9),
('16:30:00', '2024-08-06', 'J10', '10', 10);

-- Datos para AvailableSeat
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

-- Datos para Ticket
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

-- Datos para Coupon
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

-- Datos para PiecesOfLuggage
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

-- Datos para Passenger
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

-- Datos para Role
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

-- Datos para Employee
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

-- Datos para EmployeeFlightAssignment
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

-- Datos para MaintenanceSchedule
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

-- Datos para Service
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

-- Datos para InFlightService
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

-- Datos para Booking
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

-- Datos para Payment
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


-- Mostrar datos de FrequentFlyerCard
SELECT * FROM FrequentFlyerCard;

-- Mostrar datos de Customer
SELECT * FROM Customer;

-- Mostrar datos de Airport
SELECT * FROM Airport;

-- Mostrar datos de PlaneModel
SELECT * FROM PlaneModel;

-- Mostrar datos de Airplane
SELECT * FROM Airplane;

-- Mostrar datos de Seat
SELECT * FROM Seat;

-- Mostrar datos de FlightNumber
SELECT * FROM FlightNumber;

-- Mostrar datos de Flight
SELECT * FROM Flight;

-- Mostrar datos de AvailableSeat
SELECT * FROM AvailableSeat;

-- Mostrar datos de Ticket
SELECT * FROM Ticket;

-- Mostrar datos de Coupon
SELECT * FROM Coupon;

-- Mostrar datos de PiecesOfLuggage
SELECT * FROM PiecesOfLuggage;

-- Mostrar datos de Passenger
SELECT * FROM Passenger;

-- Mostrar datos de Role
SELECT * FROM Role;

-- Mostrar datos de Employee
SELECT * FROM Employee;

-- Mostrar datos de EmployeeFlightAssignment
SELECT * FROM EmployeeFlightAssignment;

-- Mostrar datos de MaintenanceSchedule
SELECT * FROM MaintenanceSchedule;

-- Mostrar datos de Service
SELECT * FROM Service;

-- Mostrar datos de InFlightService
SELECT * FROM InFlightService;

-- Mostrar datos de Booking
SELECT * FROM Booking;

-- Mostrar datos de Payment
SELECT * FROM Payment;