# Heladería "A tu Lado"

Repositorio oficial del proyecto **A tu Lado**, una solución tecnológica diseñada para la administración eficiente de una heladería artesanal con un modelo de negocio híbrido. Este sistema integra la gestión detallada de inventarios de producción propia, ventas multicanal y fidelización de clientes.

## Visión General
El proyecto nace de la necesidad de modernizar el control de stock y ventas en el sector heladero. "A tu Lado" no solo procesa transacciones, sino que optimiza la relación con el cliente, proporciona herramientas de auditoría sobre el personal y maneja un sistema de inventario basado en el peso de los ingredientes, permitiendo un control exacto de la rentabilidad.

## Características Principales

### Gestión de Inventario Híbrido
*   **Producción Propia (Artesanal):** Control de stock estricto basado en gramos. Cada sabor se monitorea individualmente, permitiendo un descuento exacto del inventario (`gramos_descontados`) por cada producto servido.
*   **Productos Comerciales:** Soporte para ítems preenvasados gestionados mediante unidades físicas en el registro de ventas (sin control de stock físico en esta iteración, pero separados lógicamente mediante la bandera `es_propio`).

### Logística de Ventas y Delivery
*   **Venta Omnicanal:** Registro diferenciado para ventas a través del canal 'Local' o mediante plataformas externas de delivery ('Yango', 'PedidosYa').
*   **Arquitectura de Precios Desglosada:** Separación técnica de los ingresos reales: monto base del producto, comisiones retenidas por plataformas y los costos de envío.
*   **Múltiples Métodos de Pago:** Soporte integrado para cierres de caja en 'Efectivo' o 'Tarjeta'.

### Programa de Fidelización "Puntos A tu Lado"
*   **Sistema de Recompensas por Producto:** La acumulación de puntos está atada al valor configurado en cada producto (`puntos_otorgados`), lo que permite realizar campañas de marketing focalizadas.
*   **Módulo de Canje Independiente:** Los premios se gestionan en un flujo separado (`Canjes_Registro`) para mantener la integridad y transparencia en los reportes financieros de ventas netas.

### Administración y Auditoría de Personal
*   **Estructura de Turnos:** Soporte para definir los bloques horarios operativos (ej. Mañana, Tarde, Noche) validando que la jornada tenga congruencia temporal.
*   **Asignación Dinámica:** Capacidad de registrar qué empleado cubre qué turno cada día específico (`fecha`).
*   **Trazabilidad Financiera:** Cada transacción de venta está rígidamente vinculada tanto al vendedor como al turno activo, previniendo descuadres y mejorando la rendición de cuentas.

## Arquitectura Técnica (Preview)

El sistema se fundamenta en una base de datos relacional diseñada para garantizar la integridad referencial y la trazabilidad de las operaciones.

*   **Modelado:** Diagrama Entidad-Relación Extendido (EER).
*   **Tipos Personalizados:** Uso exhaustivo de `ENUMS` nativos en base de datos para restringir dominios.
*   **Documentación:** Uso de Mermaid.js para diagramación "As-Code".

**Tecnologías:**
*   **Motor de DB:** PostgreSQL

## Estructura del Proyecto

*   `/docs`: Contiene el relevamiento detallado, requisitos de software y diagramas en formato Markdown/Mermaid.
*   `/sql`: Scripts de creación de base de datos (`DDL`), definiciones de tipos y constraints.
*   `/src`: Código fuente de la interfaz o API de conexión.

---

## Esquema de la Base de Datos Físico

El diseño de la base de datos se divide en módulos funcionales:

### 1. Módulo de Productos e Inventario

**Tabla: `categorias`**
*   `id_categoria` (SERIAL, PK)
*   `nombre` (VARCHAR, UNIQUE)

**Tabla: `productos`**
*   `id_producto` (SERIAL, PK)
*   `id_categoria` (INT, FK)
*   `nombre` (VARCHAR)
*   `descripcion` (TEXT)
*   `precio_base` (NUMERIC 10,2)
*   `es_propio` (BOOLEAN): Diferencia producción artesanal (medida por gramos) vs. comercial.
*   `puntos_otorgados` (INT): Cuántos puntos suma este producto al balance del cliente.

**Tabla: `sabores`**
*   `id_sabor` (SERIAL, PK)
*   `nombre` (VARCHAR, UNIQUE)
*   `stock_gramos` (NUMERIC 12,2): Existencias actuales.
*   `costo_produccion_gramo` (NUMERIC 10,4)

### 2. Módulo de Personal y Turnos

**Tipos:** `tipo_contrato_enum` ('Medio Tiempo', 'Tiempo Completo')

**Tabla: `empleados`**
*   `id_empleado` (SERIAL, PK)
*   `nombre_completo` (VARCHAR)
*   `tipo_contrato` (tipo_contrato_enum)
*   `fecha_ingreso` (DATE)

**Tabla: `turnos_definicion`**
*   `id_turno` (SERIAL, PK)
*   `nombre` (VARCHAR)
*   `hora_inicio` (TIME)
*   `hora_fin` (TIME)

**Tabla: `asignacion_turnos`**
*   `id_asignacion` (SERIAL, PK)
*   `id_empleado` (INT, FK)
*   `id_turno` (INT, FK)
*   `fecha` (DATE)

### 3. Módulo de Clientes y Fidelización

**Tabla: `clientes`**
*   `id_cliente` (SERIAL, PK)
*   `documento_identidad` (VARCHAR, UNIQUE)
*   `nombre` (VARCHAR)
*   `puntos_acumulados` (INT)

**Tabla: `premios`**
*   `id_premio` (SERIAL, PK)
*   `descripcion` (VARCHAR)
*   `puntos_requeridos` (INT)
*   `id_producto_vinculado` (INT, FK)

### 4. Módulo de Ventas y Delivery

**Tipos:** `metodo_pago_enum` ('Efectivo', 'Tarjeta'), `canal_venta_enum` ('Local', 'Yango', 'PedidosYa')

**Tabla: `ventas_cabecera`**
*   `id_venta` (SERIAL, PK)
*   `id_cliente` (INT, FK, Nullable): Permite ventas sin registrar usuario.
*   `id_empleado` (INT, FK): Audita vendedor.
*   `id_turno` (INT, FK): Audita jornada.
*   `fecha_hora` (TIMESTAMP)
*   `metodo_pago` (metodo_pago_enum)
*   `canal_venta` (canal_venta_enum)
*   `monto_base` (NUMERIC 10,2)
*   `comision_app` (NUMERIC 10,2)
*   `costo_envio` (NUMERIC 10,2)
*   `total_final` (NUMERIC 10,2)

**Tabla: `ventas_detalle`**
*   `id_detalle` (SERIAL, PK)
*   `id_venta` (INT, FK)
*   `id_producto` (INT, FK)
*   `cantidad` (INT)
*   `precio_unitario` (NUMERIC 10,2)
*   `subtotal` (NUMERIC 10,2)

**Tabla: `detalle_sabores`**
*(Relación que gestiona el descuento físico del producto artesanal)*
*   `id_detalle_sabor` (SERIAL, PK)
*   `id_detalle` (INT, FK)
*   `id_sabor` (INT, FK)
*   `gramos_descontados` (NUMERIC 10,2)

### 5. Módulo de Canjes (Premios)

**Tabla: `canjes_registro`**
*   `id_canje` (SERIAL, PK)
*   `id_cliente` (INT, FK)
*   `id_premio` (INT, FK)
*   `fecha_hora` (TIMESTAMP)
*   `puntos_utilizados` (INT)

---

## Diagramas

<p align="center">
  <img src="docs/heladeria_diagram.png" alt="Diagrama de la base de datos" width="600">
</p>

<p align="center">
  <img src="docs/mapeado_heladeria.png" alt="Mapeado de la base de datos" width="600">
</p>