const db = require('../config/db');

exports.getEmployees = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM empleados');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getShifts = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM turnos_definicion');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.assignShift = async (req, res) => {
  const { id_empleado, id_turno, fecha } = req.body;
  try {
    const result = await db.query(
      'INSERT INTO asignacion_turnos (id_empleado, id_turno, fecha) VALUES ($1, $2, $3) RETURNING *',
      [id_empleado, id_turno, fecha]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
