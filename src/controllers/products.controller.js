const db = require('../config/db');

// --- Categorías ---
exports.getCategories = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM categorias ORDER BY nombre ASC');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.createCategory = async (req, res) => {
  const { nombre } = req.body;
  try {
    const result = await db.query(
      'INSERT INTO categorias (nombre) VALUES ($1) RETURNING *',
      [nombre]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// --- Productos ---
exports.getProducts = async (req, res) => {
  try {
    const query = `
      SELECT p.*, c.nombre as categoria_nombre 
      FROM productos p 
      JOIN categorias c ON p.id_categoria = c.id_categoria 
      ORDER BY p.nombre ASC
    `;
    const result = await db.query(query);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.createProduct = async (req, res) => {
  const { id_categoria, nombre, descripcion, precio_base, es_propio, puntos_otorgados } = req.body;
  try {
    const result = await db.query(
      'INSERT INTO productos (id_categoria, nombre, descripcion, precio_base, es_propio, puntos_otorgados) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [id_categoria, nombre, descripcion, precio_base, es_propio, puntos_otorgados]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// --- Sabores ---
exports.getFlavors = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM sabores ORDER BY nombre ASC');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateFlavorStock = async (req, res) => {
  const { id } = req.params;
  const { stock_gramos } = req.body;
  try {
    const result = await db.query(
      'UPDATE sabores SET stock_gramos = $1 WHERE id_sabor = $2 RETURNING *',
      [stock_gramos, id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
