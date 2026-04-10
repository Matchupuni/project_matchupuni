const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// User operations
router.get('/', userController.getUsers);
router.post('/register', userController.register);
router.post('/login', userController.login);
router.put('/:id/profile', userController.updateProfile);
router.put('/:id/password', userController.changePassword);

module.exports = router;
