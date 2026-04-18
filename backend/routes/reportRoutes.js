const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');

// Submit a new report
router.post('/', reportController.submitReport);

module.exports = router;
