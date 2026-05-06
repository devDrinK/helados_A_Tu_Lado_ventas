const db = require('../config/db');

exports.getCustomers = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM clientes ORDER BY nombre ASC');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getCustomerById = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await db.query('SELECT * FROM clientes WHERE id_cliente = $1', [id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Cliente no encontrado' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.createCustomer = async (req, res) => {
  const { documento_identidad, nombre } = req.body;
  try {
    const result = await db.query(
      'INSERT INTO clientes (documento_identidad, nombre) VALUES ($1, $2) RETURNING *',
      [documento_identidad, nombre]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// --- Canjes ---
exports.getPrizes = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM premios');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.redeemPrize = async (req, res) => {
  const { id_cliente, id_premio, puntos_utilizados } = req.body;
  try {
    const result = await db.query(
      'INSERT INTO canjes_registro (id_cliente, id_premio, puntos_utilizados) VALUES ($1, $2, $3) RETURNING *',
      [id_cliente, id_premio, puntos_utilizados]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    // El trigger tr_registrar_canje manejará la validación de puntos
    res.status(400).json({ error: err.message });
  }
};
