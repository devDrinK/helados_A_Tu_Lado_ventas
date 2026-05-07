const express = require('express');
const router = express.Router();
const salesController = require('../controllers/sales.controller');

router.get('/', salesController.getSales);
router.get('/:id', salesController.getSaleDetail);
router.post('/', salesController.createSale);
router.put('/:id/status', salesController.updateSaleStatus);

module.exports = router;
