const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/uploadController');
const upload = require('../middlewares/upload');

router.post('/', upload.single('file'), uploadController.uploadFile);

module.exports = router;
