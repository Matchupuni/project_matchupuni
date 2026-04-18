const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const authenticateToken = require('../middlewares/authMiddleware');

router.get('/', authenticateToken, chatController.getChatList);
router.get('/unread', authenticateToken, chatController.getUnreadCount);
router.get('/:targetUserId', authenticateToken, chatController.getMessages);
router.post('/', authenticateToken, chatController.sendMessage);

module.exports = router;
