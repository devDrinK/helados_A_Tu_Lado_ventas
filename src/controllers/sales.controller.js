const db = require('../config/db');

exports.getSales = async (req, res) => {
  try {
    const query = `
      SELECT vc.*, c.nombre as cliente_nombre, e.nombre_completo as empleado_nombre
      FROM ventas_cabecera vc
      LEFT JOIN clientes c ON vc.id_cliente = c.id_cliente
      JOIN empleados e ON vc.id_empleado = e.id_empleado
      ORDER BY vc.fecha_hora DESC
    `;
    const result = await db.query(query);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.createSale = async (req, res) => {
  const { 
    id_cliente, id_empleado, id_turno, metodo_pago, canal_venta, 
    comision_app, costo_envio, items 
  } = req.body;

  const client = await db.pool.connect();

  try {
    await client.query('BEGIN');

    // 1. Insertar Cabecera
    const resCabecera = await client.query(
      `INSERT INTO ventas_cabecera 
       (id_cliente, id_empleado, id_turno, metodo_pago, canal_venta, comision_app, costo_envio) 
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [id_cliente, id_empleado, id_turno, metodo_pago, canal_venta, comision_app || 0, costo_envio || 0]
    );
    const id_venta = resCabecera.rows[0].id_venta;

    // 2. Insertar Detalle
    for (const item of items) {
      const resDetalle = await client.query(
        `INSERT INTO ventas_detalle (id_venta, id_producto, cantidad, precio_unitario) 
         VALUES ($1, $2, $3, $4) RETURNING *`,
        [id_venta, item.id_producto, item.cantidad, item.precio_unitario]
      );
      const id_detalle = resDetalle.rows[0].id_detalle;

      // 3. Insertar Sabores (si existen para este item)
      if (item.sabores && item.sabores.length > 0) {
        for (const sabor of item.sabores) {
          await client.query(
            `INSERT INTO detalle_sabores (id_detalle, id_sabor, gramos_descontados) 
             VALUES ($1, $2, $3)`,
            [id_detalle, sabor.id_sabor, sabor.gramos_descontados]
          );
        }
      }
    }

    await client.query('COMMIT');
    
    // El trigger tr_totales_venta habrá actualizado monto_base y total_final
    const finalSale = await db.query('SELECT * FROM ventas_cabecera WHERE id_venta = $1', [id_venta]);
    res.status(201).json(finalSale.rows[0]);

  } catch (err) {
    await client.query('ROLLBACK');
    res.status(400).json({ error: err.message });
  } finally {
    client.release();
  }
};

exports.getSaleDetail = async (req, res) => {
  const { id } = req.params;
  try {
    const cabecera = await db.query('SELECT * FROM ventas_cabecera WHERE id_venta = $1', [id]);
    if (cabecera.rows.length === 0) return res.status(404).json({ error: 'Venta no encontrada' });

    const detalle = await db.query(`
      SELECT vd.*, p.nombre as producto_nombre
      FROM ventas_detalle vd
      JOIN productos p ON vd.id_producto = p.id_producto
      WHERE vd.id_venta = $1
    `, [id]);

    // Obtener sabores para cada item del detalle
    for (let item of detalle.rows) {
      const sabores = await db.query(`
        SELECT ds.*, s.nombre as sabor_nombre
        FROM detalle_sabores ds
        JOIN sabores s ON ds.id_sabor = s.id_sabor
        WHERE ds.id_detalle = $1
      `, [item.id_detalle]);
      item.sabores = sabores.rows;
    }

    res.json({
      ...cabecera.rows[0],
      items: detalle.rows
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
