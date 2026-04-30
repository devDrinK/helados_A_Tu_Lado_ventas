# Especificación Técnica de Relevamiento - Heladería "A tu Lado"

Este documento detalla la lógica de datos, restricciones y reglas de negocio necesarias para la implementación del modelo de base de datos relacional.

## 1. Definición del Universo de Productos

El sistema debe gestionar la coexistencia de dos modelos de inventario distintos dentro de la misma arquitectura:

### 1.1 Inventario por Unidades (Comerciales)
*   **Origen:** Proveedores externos (Delizia, Pil, etc.).
*   **Unidad de Medida:** Números enteros (Integer).
*   **Comportamiento:** Descuento lineal (1 venta = -1 unidad).

### 1.2 Inventario por Peso (Artesanales)
*   **Origen:** Producción propia.
*   **Unidad de Medida:** Gramos (Decimal/Float).
*   **Complejidad:** Cada sabor tiene un costo base diferenciado.
*   **Lógica de Descuento:** Al vender un producto de tipo "Vaso" o "Copa", el sistema debe iterar sobre los sabores seleccionados y descontar una cantidad estándar de gramos (definida por parámetro, ej. 75g o 150g) de la existencia actual del sabor.

## 2. Gestión de Precios y Canales de Venta

La base de datos debe soportar una estructura de precios dinámica según el canal de origen para auditar la rentabilidad real.

### 2.1 Desglose de Venta por Delivery
Para transacciones vía plataformas externas (Yango, PedidosYa), la entidad de ventas debe registrar:
*   **Monto Base:** Precio de lista del helado.
*   **Comisión App:** Valor retenido por la plataforma (ej. 15-20%).
*   **Tarifa de Envío:** Costo del motorizado (externo a la heladería).
*   **Total Usuario:** Sumatoria de los tres conceptos anteriores.

## 3. Arquitectura del Personal y Control de Jornada

El sistema de turnos es rígido en tiempos pero flexible en asignación de personal.

### 3.1 Estructura de Turnos
*   **T1 (Mañana):** 08:00 - 12:00
*   **T2 (Tarde):** 14:30 - 18:30
*   **T3 (Noche):** 18:30 - 22:30

### 3.2 Reglas de Asignación
*   **Dependiente de Medio Tiempo:** Posee una relación 1:1 con la tabla de turnos por día.
*   **Dependiente de Tiempo Completo:** Posee una relación 1:2 con la tabla de turnos por día.
*   **Auditoría de Ventas:** Cada venta debe estar vinculada al ID del empleado y al ID del turno activo para detectar descuadres de caja.

## 4. Sistema de Fidelización y Canjes

Para evitar la contaminación de los reportes financieros, la lógica de fidelización se separa del flujo de caja ordinario.

### 4.1 Acumulación de Puntos
*   **Ratio:** 1 Bs gastado = 1 Punto acumulado (configurable).
*   **Restricción:** Solo se acumulan puntos en ventas cerradas y pagadas.

### 4.2 Lógica de Canjes (Premios)
*   Los premios deben existir en una tabla de catálogo con un "Costo en Puntos".
*   Al procesar un canje, se genera un registro en una tabla de `Canjes`, restando los puntos al cliente y los gramos/unidades al inventario, pero con un valor monetario de 0 en el libro de ventas principal.

## 5. Integridad y Restricciones de Datos (Constraints)

*   **Stock Mínimo:** El sistema debe disparar una alerta cuando un sabor artesanal baje de los 500g o un producto comercial baje de 5 unidades.
*   **Unicidad:** Los clientes se identifican de forma única mediante su número de documento (CI/NIT).
*   **Consistencia de Turnos:** Un empleado no puede ser asignado a dos turnos que se solapen en horario.

## 6. Diccionario de Datos Preliminar

Entidades identificadas para el modelo relacional:
*   **PRODUCTOS:** Almacena info base de helados y toppings.
*   **SABORES:** Especificación de helados artesanales (propios).
*   **INVENTARIO:** Stock actual en gramos/unidades.
*   **CLIENTES:** Perfil y balance de puntos.
*   **VENTAS:** Cabecera de la transacción y desglose de delivery.
*   **DETALLE_VENTA:** Relación de productos y sabores elegidos.
*   **EMPLEADOS:** Datos personales y tipo de contrato.
*   **TURNOS_ASIGNADOS:** Calendario operativo de la heladería.
*   **PREMIOS:** Catálogo de productos canjeables por puntos.