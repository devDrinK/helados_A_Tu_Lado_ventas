# Especificación Técnica de Relevamiento - Heladería "A tu Lado"

Este documento detalla la lógica de datos, restricciones y reglas de negocio respaldadas e implementadas por el modelo de base de datos relacional PostgreSQL.

## 1. Definición del Universo de Productos y Stock

El sistema categoriza los productos y maneja el inventario enfocándose estrictamente en la producción propia, diferenciándolos a través de la bandera booleana `es_propio` en la tabla principal de productos.

### 1.1 Productos Comerciales (`es_propio = FALSE`)
*   **Origen:** Proveedores externos (Delizia, Pil, etc.).
*   **Gestión de Inventario:** En la actual iteración de la BD, **no se maneja un kardex de stock físico por unidades** para estos ítems. Se controla únicamente su flujo de salida en ventas a través del campo `cantidad` en el detalle de la venta.

### 1.2 Producción Propia y Sabores (`es_propio = TRUE`)
*   **Origen:** Producción artesanal interna.
*   **Unidad de Medida:** Gramos (Numeric/Decimal).
*   **Complejidad:** Cada sabor se registra de forma independiente con un `costo_produccion_gramo` específico y un `stock_gramos` que monitorea las existencias.
*   **Lógica de Descuento:** Al vender un producto artesanal (ej. "Copa 2 Sabores"), el sistema registra la venta del producto principal y, simultáneamente, genera registros en la tabla de resolución `detalle_sabores`, especificando exactamente el ID del sabor y la cantidad de `gramos_descontados` para afectar el stock real.

## 2. Gestión de Precios y Canales de Venta

La base de datos soporta una estructura de precios dinámica y desglosada para auditar la rentabilidad, apoyándose en tipos de datos ENUM personalizados (`canal_venta_enum` y `metodo_pago_enum`).

### 2.1 Desglose de Venta Transaccional
Toda transacción comercial genera una cabecera de venta que registra la realidad financiera de la operación. Especialmente útil para plataformas (Yango, PedidosYa), la entidad obliga a desglosar:
*   **Monto Base:** Sumatoria del subtotal de los productos.
*   **Comisión App:** Valor retenido por la plataforma externa (permite nulos/cero en ventas de Local).
*   **Costo de Envío:** Tarifa adicional de logística.
*   **Total Final:** Sumatoria y cálculo real que cuadra con el pago del usuario.

## 3. Arquitectura del Personal y Control de Jornada

El modelo soporta la asignación dinámica de turnos manteniendo un registro histórico estricto de quién operó la caja.

### 3.1 Estructura de Turnos (`turnos_definicion`)
*   Los turnos son parametrizables (ej. T1, T2, T3) y están resguardados por una restricción de integridad temporal: la `hora_fin` siempre debe ser mayor a la `hora_inicio`.

### 3.2 Reglas de Asignación y Auditoría
*   **Asignación Dinámica:** Los empleados (`tipo_contrato_enum`: Medio Tiempo o Tiempo Completo) se vinculan a sus jornadas mediante la tabla `asignacion_turnos`, especificando la `fecha` exacta y el `id_turno`.
*   **Auditoría de Ventas:** La base de datos impone que **toda venta** (`ventas_cabecera`) esté conectada obligatoriamente por llave foránea a un `id_empleado` y a un `id_turno`, imposibilitando transacciones huérfanas o "ventas fantasma" fuera de turno.

## 4. Sistema de Fidelización y Canjes

La lógica de fidelización transita por un flujo paralelo al monetario para garantizar la limpieza de los reportes financieros.

### 4.1 Acumulación de Puntos por Producto
*   **Lógica Ajustada:** La base de datos **no** otorga puntos por dinero gastado (1 Bs = 1 Punto). En su lugar, utiliza un sistema focalizado donde **cada producto tiene un valor de `puntos_otorgados`**. Esto permite estrategias comerciales agresivas (ej. un producto en promoción puede otorgar más puntos independientemente de su precio).
*   **Balance del Cliente:** Se centraliza y acumula en el perfil del cliente (`puntos_acumulados`).

### 4.2 Lógica de Canjes (Premios)
*   Los premios existen en un catálogo (`premios`) y están vinculados físicamente a un producto base mediante `id_producto_vinculado`, definiendo un costo estricto en `puntos_requeridos`.
*   Al canjear, se graba en `canjes_registro` auditando la `fecha_hora`, el cliente, el premio y los `puntos_utilizados`, sin tocar el libro diario de `ventas_cabecera`.

## 5. Integridad y Restricciones de Datos (Constraints)

Las reglas de negocio delegadas al motor PostgreSQL para evitar datos corruptos son:

*   **Evitar Saldos y Precios Negativos:** Existen restricciones `CHECK` que impiden que el `precio_base`, `stock_gramos`, `gramos_descontados` y el `precio_unitario` sean menores a cero.
*   **Unicidad de Identidad:** El `documento_identidad` en la tabla de clientes es un campo `UNIQUE`. No pueden existir dos perfiles con el mismo CI/NIT. Lo mismo ocurre con el nombre de las categorías y los sabores.
*   **Consistencia de Turnos:** Un empleado no puede duplicar su presencia en el mismo turno el mismo día. Garantizado por el constraint `UNIQUE(id_empleado, fecha, id_turno)` en las asignaciones.
*   **Borrado en Cascada (Integridad Referencial):** Si se anula o elimina una venta (`ventas_cabecera`), la BD eliminará automáticamente su detalle (`ventas_detalle`) y el desglose de sus sabores (`detalle_sabores`) mediante `ON DELETE CASCADE`.

## 6. Diccionario de Datos Físico

Entidades y tablas maestras implementadas:
*   **`categorias`**: Clasificación maestra del menú.
*   **`productos`**: Catálogo comercial, precios y configuración de puntos otorgados.
*   **`sabores`**: Inventario de producción propia y costos base en gramos.
*   **`empleados`**: Datos de personal contratado e historial de ingreso.
*   **`turnos_definicion`**: Catálogo de horarios operativos.
*   **`asignacion_turnos`**: Planilla dinámica de trabajo diario.
*   **`clientes`**: Identidad de compradores y su billetera virtual de puntos.
*   **`premios`**: Catálogo de recompensas e integraciones con productos.
*   **`ventas_cabecera`**: Registro financiero central, canales y totales.
*   **`ventas_detalle`**: Líneas de factura y unidades vendidas.
*   **`detalle_sabores`**: Tabla de control para el descuento exacto de gramos por venta.
*   **`canjes_registro`**: Auditoría de premios entregados a clientes.