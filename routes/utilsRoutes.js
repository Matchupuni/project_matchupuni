const express = require('express');
const router = express.Router();
const utilsController = require('../controllers/utilsController');

router.get('/generate-ids', utilsController.generateIds);

module.exports = router;
