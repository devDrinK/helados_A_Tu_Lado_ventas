-- Inserción de Categorías
INSERT INTO categorias (nombre) VALUES 
('Helados Artesanales'), 
('Cremas Silvestres'), 
('Paletas Naturales'), 
('Delizia (Terceros)'), 
('Pil (Terceros)'), 
('Postres Especiales')
ON CONFLICT (nombre) DO NOTHING;

-- Inserción de Empleados (Arquitectura Original)
INSERT INTO empleados (nombre_completo, tipo_contrato) VALUES 
('Cristian Aguilar', 'Tiempo Completo'),
('Maria Elena Diaz', 'Tiempo Completo'),
('Juan Pablo Rocha', 'Medio Tiempo')
ON CONFLICT DO NOTHING;

-- Inserción de Productos con Imágenes Reales
INSERT INTO productos (id_categoria, nombre, precio_base, puntos_otorgados, es_propio, imagen_url) VALUES 
(1, 'Helado de Chirimoya', 15.00, 10, true, 'https://images.unsplash.com/photo-1505394033343-e381dff9f270?auto=format&fit=crop&w=500&q=80'),
(1, 'Helado de Chocolate', 15.00, 10, true, 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=500&q=80'),
(2, 'Copa Silvestre Mixta', 25.00, 20, true, 'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=500&q=80'),
(3, 'Paleta de Frutilla', 8.00, 5, true, 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=500&q=80'),
(3, 'Paleta de Coco', 8.00, 5, true, 'https://images.unsplash.com/photo-1520021876352-780879685375?auto=format&fit=crop&w=500&q=80'),
(4, 'Cono Delizia Mix', 12.00, 3, false, 'https://images.unsplash.com/photo-1501443762994-82bd5dace89a?auto=format&fit=crop&w=500&q=80'),
(4, 'Gigante Delizia', 18.00, 5, false, 'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=500&q=80'),
(5, 'Paleta Pil de Mora', 7.00, 2, false, 'https://images.unsplash.com/photo-1560008511-11c63416e52d?auto=format&fit=crop&w=500&q=80'),
(6, 'Brownie con Helado', 30.00, 25, true, 'https://images.unsplash.com/photo-1564355808539-22fda35bed7e?auto=format&fit=crop&w=500&q=80'),
(6, 'Tarta de Manzana Helada', 35.00, 30, true, 'https://images.unsplash.com/photo-1519915028121-7d3463d20b13?auto=format&fit=crop&w=500&q=80')
ON CONFLICT DO NOTHING;

-- Inserción de Clientes Iniciales
INSERT INTO clientes (documento_identidad, nombre, puntos_acumulados) VALUES 
('1234567', 'Juan Perez', 50),
('7654321', 'Maria Garcia', 120),
('0', 'Cliente General', 0)
ON CONFLICT (documento_identidad) DO NOTHING;
