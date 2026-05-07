-- ========================================================
-- ARCHIVO 3: DATOS DE PRUEBA (SEED)
-- PROYECTO: Heladería "A tu Lado"
-- ========================================================

-- 1. Categorías
INSERT INTO categorias (nombre) VALUES 
('Helados Artesanales'), 
('Paletas'), 
('Copeas'), 
('Línea Delizia'), 
('Línea PIL'), 
('Postres Fríos');

-- 2. Productos
-- Artesanales (es_propio = TRUE)
INSERT INTO productos (id_categoria, nombre, descripcion, precio_base, es_propio, puntos_otorgados, imagen_url) VALUES 
(1, 'Helado de Chirimoya Real', 'Hecho con fruta natural del valle', 15.00, TRUE, 10, 'https://images.unsplash.com/photo-1501443762994-82bd5dace89a?auto=format&fit=crop&w=400&q=80'),
(1, 'Sorbe de Singani con Limón', 'Sabor tradicional boliviano', 18.00, TRUE, 15, 'https://images.unsplash.com/photo-1534706936160-d5ee67737249?auto=format&fit=crop&w=400&q=80'),
(1, 'Dulce de Leche con Nueces', 'Cremoso y artesanal', 15.00, TRUE, 10, 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=400&q=80'),
(2, 'Paleta de Frutilla Silvestre', 'Frutilla entera congelada', 8.00, TRUE, 5, 'https://images.unsplash.com/photo-1488900128323-21503983a07e?auto=format&fit=crop&w=400&q=80'),
(2, 'Paleta de Chocolate Intenso', 'Cacao al 70%', 10.00, TRUE, 5, 'https://images.unsplash.com/photo-1553177595-4de2bb0842b9?auto=format&fit=crop&w=400&q=80'),

-- De Terceros (es_propio = FALSE)
(4, 'Mega Delizia Chocolate', 'Paleta clásica de Delizia', 12.00, FALSE, 2, 'https://images.unsplash.com/photo-1560008447-07444c138f2a?auto=format&fit=crop&w=400&q=80'),
(4, 'ChocoBar Delizia', 'Barra bañada en chocolate', 7.00, FALSE, 2, 'https://images.unsplash.com/photo-1516730106033-f673c5216f84?auto=format&fit=crop&w=400&q=80'),
(5, 'Bombón PIL Vainilla', 'Helado de vainilla PIL', 6.00, FALSE, 2, 'https://images.unsplash.com/photo-1570197788417-0e82375c9371?auto=format&fit=crop&w=400&q=80'),
(5, 'Copa PIL Dulce de Leche', 'Copa individual PIL', 9.00, FALSE, 2, 'https://images.unsplash.com/photo-1565463632938-2049e7b23180?auto=format&fit=crop&w=400&q=80'),
(6, 'Tarta Helada Familiar', 'Postre para compartir', 45.00, TRUE, 30, 'https://images.unsplash.com/photo-1505394033223-267f74667504?auto=format&fit=crop&w=400&q=80');

-- 3. Sabores (Stock en gramos)
INSERT INTO sabores (nombre, stock_gramos, costo_produccion_gramo) VALUES 
('Vainilla Silvestre', 5000.00, 0.05),
('Chocolate Amargo', 4500.00, 0.08),
('Chirimoya de Temporada', 3000.00, 0.06),
('Frutilla del Campo', 6000.00, 0.04),
('Dulce de Leche Casero', 5000.00, 0.05),
('Singani Premium', 2000.00, 0.12),
('Menta Granizada', 4000.00, 0.06),
('Maracuyá Tropical', 3500.00, 0.05),
('Coco Cremoso', 4000.00, 0.05),
('Café de Altura', 3000.00, 0.07);

-- 4. Empleados
INSERT INTO empleados (nombre_completo, tipo_contrato) VALUES 
('Juan Pérez', 'Tiempo Completo'),
('María García', 'Medio Tiempo'),
('Carlos Rodríguez', 'Tiempo Completo'),
('Ana Martínez', 'Medio Tiempo'),
('Luis Flores', 'Tiempo Completo');

-- 5. Turnos Definición
INSERT INTO turnos_definicion (nombre, hora_inicio, hora_fin) VALUES 
('Mañana', '08:00:00', '14:00:00'),
('Tarde', '14:00:00', '20:00:00'),
('Noche (Cierre)', '18:00:00', '23:00:00');

-- 6. Clientes
INSERT INTO clientes (documento_identidad, nombre, puntos_acumulados) VALUES 
('1234567', 'Neil Choque', 150),
('8765432', 'Grover Smith', 45),
('1122334', 'Elena Galindo', 10),
('5566778', 'Roberto Carlos', 0),
('9900112', 'Paola Vaca', 300),
('4433221', 'Fernando Paz', 85);

-- 7. Premios
INSERT INTO premios (descripcion, puntos_requeridos, id_producto_vinculado) VALUES 
('1 Helado de Chirimoya Gratis', 100, 1),
('Paleta de Frutilla Gratis', 50, 4),
('Tarta Helada (Premio Mayor)', 500, 10);

-- 8. Asignación de Turnos (Ejemplos)
INSERT INTO asignacion_turnos (id_empleado, id_turno, fecha) VALUES 
(1, 1, CURRENT_DATE),
(2, 2, CURRENT_DATE),
(3, 1, CURRENT_DATE + 1);

-- 9. Ventas de ejemplo para el Dashboard
-- Venta 1: Cliente 1 compra 2 helados
INSERT INTO ventas_cabecera (id_cliente, id_empleado, id_turno, metodo_pago, canal_venta, monto_base, total_final) 
VALUES (1, 1, 1, 'Efectivo', 'Local', 30.00, 30.00);

INSERT INTO ventas_detalle (id_venta, id_producto, cantidad, precio_unitario, subtotal) 
VALUES (1, 1, 2, 15.00, 30.00);

-- Venta 2: Venta por PedidosYa
INSERT INTO ventas_cabecera (id_cliente, id_empleado, id_turno, metodo_pago, canal_venta, monto_base, comision_app, costo_envio, total_final) 
VALUES (NULL, 2, 2, 'Tarjeta', 'PedidosYa', 15.00, 3.00, 5.00, 23.00);

INSERT INTO ventas_detalle (id_venta, id_producto, cantidad, precio_unitario, subtotal) 
VALUES (2, 3, 1, 15.00, 15.00);
