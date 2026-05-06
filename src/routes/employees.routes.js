const express = require('express');
const router = express.Router();
const employeesController = require('../controllers/employees.controller');

router.get('/', employeesController.getEmployees);
router.get('/shifts', employeesController.getShifts);
router.post('/shifts/assign', employeesController.assignShift);

module.exports = router;
