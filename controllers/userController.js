const pool = require('../config/db');
const { generateCuid2 } = require('../utils/idGenerator');

const getUsers = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

const createUser = async (req, res) => {
  try {
    const { full_name, email, password_hash, profile_img } = req.body;
    
    const id = generateCuid2(); 

    const result = await pool.query(
      `INSERT INTO users (id, full_name, email, password_hash, profile_img) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING *`,
      [id, full_name, email, password_hash, profile_img]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    
    if (error.constraint === 'users_email_key') {
      return res.status(409).json({ error: 'Email already exists' });
    }
    
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

module.exports = {
  getUsers,
  createUser
};
