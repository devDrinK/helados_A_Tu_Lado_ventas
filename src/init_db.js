const fs = require('fs');
const path = require('path');
const { pool } = require('./config/db');

const initDb = async () => {
  try {
    const arquitecturaSql = fs.readFileSync(path.join(__dirname, '../arquitectura.sql'), 'utf8');
    const logicaSql = fs.readFileSync(path.join(__dirname, '../logica.sql'), 'utf8');

    console.log('Iniciando creación de tablas...');
    await pool.query(arquitecturaSql);
    console.log('Tablas creadas exitosamente.');

    console.log('Iniciando creación de lógica (triggers/funciones)...');
    await pool.query(logicaSql);
    console.log('Lógica de base de datos aplicada exitosamente.');

    process.exit(0);
  } catch (err) {
    console.error('Error inicializando la base de datos:', err);
    process.exit(1);
  }
};

initDb();
