const fs = require('fs');
const path = require('path');
const { pool } = require('./config/db');

const initDb = async () => {
  const isSeed = process.argv[2] === 'seed';
  
  try {
    if (!isSeed) {
      const arquitecturaSql = fs.readFileSync(path.join(__dirname, '../arquitectura.sql'), 'utf8');
      const logicaSql = fs.readFileSync(path.join(__dirname, '../logica.sql'), 'utf8');

      console.log('Iniciando creación de tablas...');
      await pool.query(arquitecturaSql);
      console.log('Tablas creadas exitosamente.');

      console.log('Iniciando creación de lógica (triggers/funciones)...');
      await pool.query(logicaSql);
      console.log('Lógica de base de datos aplicada exitosamente.');
    } else {
      const seedSql = fs.readFileSync(path.join(__dirname, '../datos_iniciales.sql'), 'utf8');
      console.log('Iniciando inserción de datos de prueba...');
      await pool.query(seedSql);
      console.log('Datos de prueba insertados exitosamente.');
    }

    process.exit(0);
  } catch (err) {
    console.error('Error inicializando la base de datos:', err);
    process.exit(1);
  }
};

initDb();
