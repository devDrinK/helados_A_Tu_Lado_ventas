const express = require('express');
const router = express.Router();
const customersController = require('../controllers/customers.controller');

router.get('/', customersController.getCustomers);
router.get('/:id', customersController.getCustomerById);
router.post('/', customersController.createCustomer);

// Fidelización / Canjes
router.get('/prizes', customersController.getPrizes);
router.post('/redeem', customersController.redeemPrize);

module.exports = router;
