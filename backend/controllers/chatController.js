const pool = require('../config/db');

const getMessages = async (req, res) => {
  const { targetUserId } = req.params;
  const userId = req.user.id;

  try {
    const result = await pool.query(
      `SELECT m.*, 
              s.full_name as sender_name, s.profile_img as sender_img,
              r.full_name as receiver_name, r.profile_img as receiver_img
       FROM messages m
       JOIN users s ON m.sender_id = s.id
       JOIN users r ON m.receiver_id = r.id
       WHERE (m.sender_id = $1 AND m.receiver_id = $2)
          OR (m.sender_id = $2 AND m.receiver_id = $1)
       ORDER BY m.created_at ASC`,
      [userId, targetUserId]
    );

    // mark as read
    await pool.query(
      `UPDATE messages SET is_read = TRUE WHERE receiver_id = $1 AND sender_id = $2 AND is_read = FALSE`,
      [userId, targetUserId]
    );

    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message || 'Internal Server Error', stack: error.stack });
  }
};

const sendMessage = async (req, res) => {
  const { receiverId, message } = req.body;
  const senderId = req.user.id;

  if (!receiverId || !message) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO messages (sender_id, receiver_id, message) 
       VALUES ($1, $2, $3) RETURNING *`,
      [senderId, receiverId, message]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message || 'Internal Server Error', stack: error.stack });
  }
};

const getUnreadCount = async (req, res) => {
  const userId = req.user.id;
  try {
    const result = await pool.query(
      `SELECT COUNT(*) as unread_count FROM messages WHERE receiver_id = $1 AND is_read = FALSE`,
      [userId]
    );
    res.json({ unread_count: parseInt(result.rows[0].unread_count, 10) });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message || 'Internal Server Error', stack: error.stack });
  }
};

const getChatList = async (req, res) => {
  const userId = req.user.id;
  try {
    // Uses DISTINCT ON to get only the latest message per target_user_id
    const result = await pool.query(`
      SELECT 
          target_user_id,
          u.full_name as target_user_name,
          u.profile_img as target_user_img,
          m.message as last_message,
          m.created_at as last_message_time,
          m.is_read as is_read,
          m.sender_id as last_sender_id
      FROM (
          SELECT DISTINCT ON (
              CASE WHEN sender_id = $1 THEN receiver_id ELSE sender_id END
          )
              CASE WHEN sender_id = $1 THEN receiver_id ELSE sender_id END as target_user_id,
              message,
              created_at,
              is_read,
              sender_id
          FROM messages
          WHERE sender_id = $1 OR receiver_id = $1
          ORDER BY 
              CASE WHEN sender_id = $1 THEN receiver_id ELSE sender_id END, 
              created_at DESC
      ) m
      JOIN users u ON m.target_user_id = u.id
      ORDER BY m.created_at DESC
    `, [userId]);

    res.json(result.rows);
  } catch (error) {
    console.error("Error in getChatList:", error);
    res.status(500).json({ error: error.message || 'Internal Server Error', stack: error.stack });
  }
};

module.exports = {
  getMessages,
  sendMessage,
  getUnreadCount,
  getChatList
};
