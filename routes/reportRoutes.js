const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');
const authenticateToken = require('../middlewares/authMiddleware');

// User must be logged in to submit a report
router.post('/', authenticateToken, reportController.submitReport);

module.exports = router;
