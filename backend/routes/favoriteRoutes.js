const express = require('express');
const router = express.Router();
const favoriteController = require('../controllers/favoriteController');

router.get('/:userId', favoriteController.getUserFavorites);
router.post('/', favoriteController.toggleFavorite);

module.exports = router;
