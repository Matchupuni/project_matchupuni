const pool = require('../config/db');

const getUserFavorites = async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Exact same query as getting posts, but INNER JOIN with favorites to filter by user
    const query = `
      SELECT 
        p.*, 
        COALESCE(array_remove(array_agg(DISTINCT t.tag_name), NULL), '{}') AS tags,
        COALESCE(array_remove(array_agg(DISTINCT f.field_name), NULL), '{}') AS fields
      FROM posts p
      INNER JOIN favorites fav ON p.id = fav.post_id
      LEFT JOIN post_tags pt ON p.id = pt.post_id
      LEFT JOIN tags t ON pt.tag_id = t.id
      LEFT JOIN post_fields pf ON p.id = pf.post_id
      LEFT JOIN fields f ON pf.field_id = f.id
      WHERE fav.user_id = $1
      GROUP BY p.id, fav.created_at
      ORDER BY fav.created_at DESC
    `;
    
    const result = await pool.query(query, [userId]);
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

const toggleFavorite = async (req, res) => {
  try {
    const { user_id, post_id } = req.body;
    
    if (!user_id || !post_id) {
       return res.status(400).json({ error: 'Missing user_id or post_id' });
    }

    // Check if favorite exists
    const favCheck = await pool.query('SELECT * FROM favorites WHERE user_id = $1 AND post_id = $2', [user_id, post_id]);
    
    if (favCheck.rows.length > 0) {
      // Exists already, so delete it (toggle off)
      await pool.query('DELETE FROM favorites WHERE user_id = $1 AND post_id = $2', [user_id, post_id]);
      return res.json({ message: 'Favorite removed', status: 'removed' });
    } else {
      // Does not exist, create it (toggle on)
      await pool.query('INSERT INTO favorites (user_id, post_id) VALUES ($1, $2)', [user_id, post_id]);
      return res.json({ message: 'Favorite added', status: 'added' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

module.exports = {
  getUserFavorites,
  toggleFavorite
};
