-- ========================================================
-- PROYECTO: Heladería "A tu Lado"
-- DESCRIPCIÓN: Sistema de Gestión Híbrida y Fidelización
-- MOTOR: PostgreSQL
-- ========================================================

-- 1. TIPOS PERSONALIZADOS (ENUMS)
CREATE TYPE tipo_contrato_enum AS ENUM ('Medio Tiempo', 'Tiempo Completo');
CREATE TYPE metodo_pago_enum AS ENUM ('Efectivo', 'Tarjeta');
CREATE TYPE canal_venta_enum AS ENUM ('Local', 'Yango', 'PedidosYa');

-- 2. TABLAS DE CONFIGURACIÓN Y MAESTROS
CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    id_categoria INT NOT NULL REFERENCES categorias(id_categoria),
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio_base NUMERIC(10, 2) NOT NULL CHECK (precio_base >= 0),
    es_propio BOOLEAN NOT NULL DEFAULT FALSE,
    puntos_otorgados INT NOT NULL DEFAULT 0 CHECK (puntos_otorgados >= 0)
);

CREATE TABLE sabores (
    id_sabor SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    stock_gramos NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (stock_gramos >= 0),
    costo_produccion_gramo NUMERIC(10, 4) NOT NULL DEFAULT 0
);

-- 3. PERSONAL Y TURNOS
CREATE TABLE empleados (
    id_empleado SERIAL PRIMARY KEY,
    nombre_completo VARCHAR(150) NOT NULL,
    tipo_contrato tipo_contrato_enum NOT NULL,
    fecha_ingreso DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE turnos_definicion (
    id_turno SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    CONSTRAINT chk_horario CHECK (hora_fin > hora_inicio)
);

CREATE TABLE asignacion_turnos (
    id_asignacion SERIAL PRIMARY KEY,
    id_empleado INT NOT NULL REFERENCES empleados(id_empleado),
    id_turno INT NOT NULL REFERENCES turnos_definicion(id_turno),
    fecha DATE NOT NULL,
    UNIQUE(id_empleado, fecha, id_turno)
);

-- 4. CLIENTES Y FIDELIDAD
CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    documento_identidad VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    puntos_acumulados INT NOT NULL DEFAULT 0 CHECK (puntos_acumulados >= 0)
);

CREATE TABLE premios (
    id_premio SERIAL PRIMARY KEY,
    descripcion VARCHAR(200) NOT NULL,
    puntos_requeridos INT NOT NULL CHECK (puntos_requeridos > 0),
    id_producto_vinculado INT NOT NULL REFERENCES productos(id_producto)
);

-- 5. VENTAS (CON PRECIOS HISTÓRICOS Y DESGLOSE)
CREATE TABLE ventas_cabecera (
    id_venta SERIAL PRIMARY KEY,
    id_cliente INT REFERENCES clientes(id_cliente),
    id_empleado INT NOT NULL REFERENCES empleados(id_empleado),
    id_turno INT NOT NULL REFERENCES turnos_definicion(id_turno),
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo_pago metodo_pago_enum NOT NULL,
    canal_venta canal_venta_enum NOT NULL,
    monto_base NUMERIC(10, 2) NOT NULL DEFAULT 0,
    comision_app NUMERIC(10, 2) DEFAULT 0,
    costo_envio NUMERIC(10, 2) DEFAULT 0,
    total_final NUMERIC(10, 2) NOT NULL
);

CREATE TABLE ventas_detalle (
    id_detalle SERIAL PRIMARY KEY,
    id_venta INT NOT NULL REFERENCES ventas_cabecera(id_venta) ON DELETE CASCADE,
    id_producto INT NOT NULL REFERENCES productos(id_producto),
    cantidad INT NOT NULL DEFAULT 1 CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal NUMERIC(10, 2) NOT NULL
);

CREATE TABLE detalle_sabores (
    id_detalle_sabor SERIAL PRIMARY KEY,
    id_detalle INT NOT NULL REFERENCES ventas_detalle(id_detalle) ON DELETE CASCADE,
    id_sabor INT NOT NULL REFERENCES sabores(id_sabor),
    gramos_descontados NUMERIC(10, 2) NOT NULL CHECK (gramos_descontados > 0)
);

CREATE TABLE canjes_registro (
    id_canje SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL REFERENCES clientes(id_cliente),
    id_premio INT NOT NULL REFERENCES premios(id_premio),
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    puntos_utilizados INT NOT NULL
);