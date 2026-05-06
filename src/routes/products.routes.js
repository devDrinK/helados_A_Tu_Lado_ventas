const express = require('express');
const router = express.Router();
const productsController = require('../controllers/products.controller');

// Categorías
router.get('/categories', productsController.getCategories);
router.post('/categories', productsController.createCategory);

// Productos
router.get('/', productsController.getProducts);
router.post('/', productsController.createProduct);

// Sabores
router.get('/flavors', productsController.getFlavors);
router.put('/flavors/:id', productsController.updateFlavorStock);

module.exports = router;
