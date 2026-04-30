# Heladería "A tu Lado"

Repositorio oficial del proyecto **A tu Lado**, una solución tecnológica diseñada para la administración eficiente de una heladería artesanal con un modelo de negocio híbrido. Este sistema integra la gestión de inventarios pesados, ventas multicanal y fidelización de clientes.

## Visión General
El proyecto nace de la necesidad de modernizar el control de stock y ventas en el sector heladero, donde conviven productos por unidad (comerciales) y productos por peso (artesanales). "A tu Lado" no solo procesa transacciones, sino que optimiza la relación con el cliente y la logística de personal.

## Características Principales

### Gestión de Inventario Híbrido
*   **Productos Artesanales:** Control de stock basado en gramos para helados propios, permitiendo un descuento preciso de inventario por cada bola de helado servida.
*   **Productos Comerciales:** Soporte para inventario de proveedores externos (Delizia, Pil, etc.) gestionado por unidades físicas.
*   **Gestión de Toppings:** Control independiente de extras y salsas que complementan la experiencia del usuario.

### Logística de Ventas y Delivery
*   **Venta Omnicanal:** Registro diferenciado para ventas en mostrador y pedidos a través de plataformas externas (Yango, PedidosYa).
*   **Arquitectura de Precios:** Desglose técnico de costos, separando el precio base del producto, las comisiones de plataforma y los costos de envío.
*   **Múltiples Métodos de Pago:** Soporte integrado para transacciones en efectivo y tarjetas.

### Programa de Fidelización "Puntos A tu Lado"
*   **Sistema de Recompensas:** Los clientes acumulan puntos basados en sus consumos, los cuales pueden ser canjeados por productos del catálogo de premios.
*   **Módulo de Canje Independiente:** Los premios se gestionan en un flujo separado para mantener la transparencia en los reportes financieros de ventas netas.

### Administración de Talento Humano
*   **Gestión por Turnos:** Estructura operativa dividida en tres bloques:
    *   Mañana: 08:00 - 12:00
    *   Tarde: 14:30 - 18:30
    *   Noche: 18:30 - 22:30
*   **Asignación Flexible:** Capacidad de registrar dependientes en modalidades de medio tiempo o tiempo completo (doble turno).

## Arquitectura Técnica (Preview)

El sistema se fundamenta en una base de datos relacional diseñada para garantizar la integridad referencial y la trazabilidad de cada gramo de producto.

**Tecnologías Sugeridas:**
*   **Motor de DB:** MySQL / PostgreSQL
*   **Modelado:** Diagrama Entidad-Relación (DER) con normalización en 3FN.
*   **Documentación:** Mermaid.js para diagramas de flujo y esquemas de tablas.

## Estructura del Proyecto

*   `/docs`: Contiene el relevamiento detallado y requisitos de software.
*   `/sql`: Scripts de creación de base de datos, vistas y procedimientos almacenados.
*   `/src`: (Opcional) Código fuente de la interfaz o API de conexión.

## Objetivos del Proyecto Universitario
1.  Aplicar conceptos avanzados de normalización de bases de datos.
2.  Implementar disparadores (triggers) para el control automático de stock en gramos.
3.  Generar reportes estadísticos sobre los sabores más rentables y eficiencia de turnos.

## Contribución y Desarrollo
Este proyecto ha sido desarrollado siguiendo estándares de documentación técnica clara y precisa, enfocada en la escalabilidad y la facilidad de mantenimiento para futuros desarrolladores o administradores del sistema.