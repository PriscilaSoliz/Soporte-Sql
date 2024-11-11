-- Crear la base de datos
CREATE DATABASE reservasDM;
GO

-- Usar la base de datos
USE reservasDM;
GO

-- Tabla DimAeropuerto
CREATE TABLE DimAeropuerto (
    IDAeropuerto INT IDENTITY(1,1) PRIMARY KEY,  -- Clave subrogada
    IDAirport INT UNIQUE,                        -- ID original del sistema de origen
    Name VARCHAR(100),
    CityName VARCHAR(100),
    CountryName VARCHAR(100)
);

-- Tabla DimAerolinea
CREATE TABLE DimAerolinea (
    IDAerolinea INT IDENTITY(1,1) PRIMARY KEY,  -- Clave subrogada
    IDAirline INT UNIQUE,                       -- ID original del sistema de origen
    Name VARCHAR(100),
    CountryName VARCHAR(100)
);

-- Tabla DimCliente
CREATE TABLE DimCliente (
    IDCliente INT IDENTITY(1,1) PRIMARY KEY,    -- Clave subrogada
    IDCustomer INT UNIQUE,                      -- ID original del sistema de origen
    Name VARCHAR(200),
    CategoryName VARCHAR(50)
);

-- Tabla DimMetodoPago
CREATE TABLE DimMetodoPago (
    IDMetodoPago INT IDENTITY(1,1) PRIMARY KEY,    -- Clave subrogada
	IDPaymentMetthod INT UNIQUE,
	Name VARCHAR(50)
);

-- Tabla DimCategoriaTicket
CREATE TABLE DimCategoriaTicket (
    IDCategoriaTicket INT IDENTITY(1,1) PRIMARY KEY,    -- Clave subrogada
	IDCategory INT UNIQUE,
	Name VARCHAR(50)
);

-- Tabla DimCategoriaVuelo
CREATE TABLE DimCategoriaVuelo (
    IDCategoriaVuelo INT IDENTITY(1,1) PRIMARY KEY,    -- Clave subrogada
	IDCategory INT UNIQUE,
	Name VARCHAR(50)
);

-- Tabla DimEstadoVuelo
CREATE TABLE DimEstadoVuelo (
    IDEstadoVuelo INT IDENTITY(1,1) PRIMARY KEY,    -- Clave subrogada
	IDStatus INT UNIQUE,
	Name VARCHAR(50)
);

-- Tabla DimAvion
CREATE TABLE DimAvion (
    IDAvion INT IDENTITY(1,1) PRIMARY KEY,    -- Clave subrogada
	IDPlaneModel INT UNIQUE,
	modelo VARCHAR(255)
);

-- Tabla Hecho Reservas (tabla de hechos) 
CREATE TABLE hecho_reservas (
    IDReserva INT IDENTITY(1,1) PRIMARY KEY,    -- Clave subrogada única
    IDCliente INT,                              -- Clave de dimensión para cliente
    IDAeropuerto INT,                           -- Clave de dimensión para aeropuerto
    IDAerolinea INT,                            -- Clave de dimensión para aerolínea
    CantidadTickets INT,                        -- Cantidad de tickets asociados a la reserva
    AnticipacionReservaDias INT,                -- Número de días de anticipación de la reserva
	FechaReserva DATE,							-- Fecha para su analisis
    FOREIGN KEY (IDCliente) REFERENCES DimCliente(IDCliente),
    FOREIGN KEY (IDAeropuerto) REFERENCES DimAeropuerto(IDAeropuerto),
    FOREIGN KEY (IDAerolinea) REFERENCES DimAerolinea(IDAerolinea)
);

-- Tabla Hecho Pagos (tabla de hechos) 
CREATE TABLE hecho_pagos (
    IDPago INT IDENTITY(1,1) PRIMARY KEY,          -- Clave subrogada
    IDCliente INT,                                  -- Clave de dimensión para cliente
    IDMetodoPago INT,                               -- Clave de dimensión para el método de pago
    MontoPago DECIMAL(10, 2),                       -- Monto total del pago
    CantidadTickets INT,                            -- Cantidad de tickets asociados al pago
    DiasReservaPago INT,                            -- Días entre la reserva y el pago
	FechaPago DATE,									-- Fecha para su analisis
    FOREIGN KEY (IDCliente) REFERENCES DimCliente(IDCliente),
    FOREIGN KEY (IDMetodoPago) REFERENCES DimMetodoPago(IDMetodoPago)
);

-- Tabla Hecho Tickets (tabla de hechos) 
CREATE TABLE hecho_tickets (
    IDTicketHecho INT IDENTITY(1,1) PRIMARY KEY,    -- Clave subrogada
    IDMetodoPago INT,                               -- Clave de la dimensión para el método de pago
    IDCategoriaTicket INT,                          -- Clave de la dimensión para la categoría del ticket
    PrecioTicket DECIMAL(10, 2),                    -- Precio del ticket según su categoría
    PesoTotalEquipaje DECIMAL(10, 2) DEFAULT 0,     -- Peso total de maletas asociadas al ticket
    CantidadPiezasEquipaje INT DEFAULT 0,           -- Cantidad de maletas asociadas al ticket
	FechaTicket DATE,								-- Fecha para su analisis
    FOREIGN KEY (IDMetodoPago) REFERENCES DimMetodoPago(IDMetodoPago),
    FOREIGN KEY (IDCategoriaTicket) REFERENCES DimCategoriaTicket(IDCategoriaTicket)
);

-- Tabla Hecho Vuelos (tabla de hechos)
CREATE TABLE hecho_vuelos (
    IDVuelo INT IDENTITY(1,1) PRIMARY KEY,         -- Clave subrogada única
    IDCategoriaVuelo INT,                          -- Clave de la dimensión para categoría de vuelo
    IDEstadoVuelo INT,                             -- Clave de la dimensión para el estado del vuelo
    IDAerolinea INT,                               -- Clave de la dimensión para la aerolínea
    IDAeropuerto INT,								-- Clave de la dimensión para el aeropuerto de origen
    IDAvion INT,                                   -- Clave de la dimensión para el modelo de avión
    CantidadEscalas INT,                           -- Cantidad de escalas realizadas en el vuelo
    CantidadAsientos INT,                          -- Cantidad total de asientos en el vuelo
    CantidadReservas INT,                          -- Cantidad total de reservas asociadas al vuelo
    CantidadAsientosDisponibles INT,               -- Cantidad de asientos que quedaron disponibles
    CantidadAsientosOcupados INT,					-- Cantidad de asientos que fueron asignados
    PromedioPesoEquipaje DECIMAL(10, 2),           -- Promedio de peso de equipaje por vuelo
	FechaVuelo DATE,							   -- Fecha para su analisis
    FOREIGN KEY (IDCategoriaVuelo) REFERENCES DimCategoriaVuelo(IDCategoriaVuelo),
    FOREIGN KEY (IDEstadoVuelo) REFERENCES DimEstadoVuelo(IDEstadoVuelo),
    FOREIGN KEY (IDAerolinea) REFERENCES DimAerolinea(IDAerolinea),
    FOREIGN KEY (IDAeropuerto) REFERENCES DimAeropuerto(IDAeropuerto),
    FOREIGN KEY (IDAvion) REFERENCES DimAvion(IDAvion)
);