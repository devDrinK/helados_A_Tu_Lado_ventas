const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

// Routes
const productRoutes = require('./routes/products.routes');
const customerRoutes = require('./routes/customers.routes');
const employeeRoutes = require('./routes/employees.routes');
const salesRoutes = require('./routes/sales.routes');

app.use('/api/products', productRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/employees', employeeRoutes);
app.use('/api/sales', salesRoutes);

// Health check
app.use('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Backend helados funcionando correctamente' });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Algo salió mal!' });
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
