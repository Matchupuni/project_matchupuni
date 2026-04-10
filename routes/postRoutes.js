const express = require('express');
const router = express.Router();
const postController = require('../controllers/postController');
const authenticateToken = require('../middlewares/authMiddleware');

router.get('/', postController.getPosts);
router.post('/', authenticateToken, postController.createPost);
router.put('/:id', authenticateToken, postController.updatePost);
router.delete('/bulk', authenticateToken, postController.deleteBulkPosts);

module.exports = router;
