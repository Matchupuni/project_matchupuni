const pool = require('../config/db');
const { generateCuid2 } = require('../utils/idGenerator');
const { hashPassword, verifyPassword } = require('../utils/password');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'matchupuni_secret_key';

const getUsers = async (req, res) => {
  try {
    const result = await pool.query('SELECT id, full_name, email, profile_img, created_at FROM users ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

const register = async (req, res) => {
  try {
    const { full_name, email, password, profile_img } = req.body;
    
    if (!full_name || !email || !password) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const id = generateCuid2(); 
    const hashedPassword = await hashPassword(password);

    const result = await pool.query(
      `INSERT INTO users (id, full_name, email, password_hash, profile_img) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING id, full_name, email, profile_img, created_at`,
      [id, full_name, email, hashedPassword, profile_img || null]
    );
    
    res.status(201).json({ message: 'User registered successfully', user: result.rows[0] });
  } catch (error) {
    console.error(error);
    if (error.constraint === 'users_email_key') {
      return res.status(409).json({ error: 'Email already exists' });
    }
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Missing email or password' });
    }

    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const user = result.rows[0];
    const isMatch = await verifyPassword(user.password_hash, password);

    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, full_name: user.full_name },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        profile_img: user.profile_img,
      }
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

const updateProfile = async (req, res) => {
  try {
    const { id } = req.params;
    const { full_name, email, password } = req.body;

    if (!full_name || !email) {
      return res.status(400).json({ error: 'Missing full_name or email' });
    }

    // Check if the user exists
    const userCheck = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
    if (userCheck.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const currentUser = userCheck.rows[0];

    // Require password if email is being changed
    if (email !== currentUser.email) {
      if (!password) {
        return res.status(401).json({ error: 'Password is required to change email' });
      }
      const isMatch = await verifyPassword(currentUser.password_hash, password);
      if (!isMatch) {
         return res.status(401).json({ error: 'Invalid password' });
      }
    }

    // Check if the new email is already taken by another user
    const emailCheck = await pool.query('SELECT * FROM users WHERE email = $1 AND id != $2', [email, id]);
    if (emailCheck.rows.length > 0) {
      return res.status(409).json({ error: 'Email already exists' });
    }

    const result = await pool.query(
      `UPDATE users SET full_name = $1, email = $2 WHERE id = $3 RETURNING id, full_name, email, profile_img, created_at`,
      [full_name, email, id]
    );

    res.json({ message: 'Profile updated successfully', user: result.rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

const changePassword = async (req, res) => {
  try {
    const { id } = req.params;
    const { old_password, new_password } = req.body;

    if (!old_password || !new_password) {
      return res.status(400).json({ error: 'Missing old_password or new_password' });
    }

    // Check if the user exists
    const userCheck = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
    if (userCheck.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = userCheck.rows[0];
    
    // Verify old password
    const isMatch = await verifyPassword(user.password_hash, old_password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid old password' });
    }

    // Hash the new password and update
    const hashedPassword = await hashPassword(new_password);
    await pool.query('UPDATE users SET password_hash = $1 WHERE id = $2', [hashedPassword, id]);

    res.json({ message: 'Password changed successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

const deleteAccount = async (req, res) => {
  try {
    const { id } = req.params;
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required to delete account' });
    }

    // Check if the user exists
    const result = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = result.rows[0];
    
    // Verify email
    if (user.email !== email) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Verify password
    const isMatch = await verifyPassword(user.password_hash, password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Delete user
    await pool.query('DELETE FROM users WHERE id = $1', [id]);

    res.json({ message: 'Account deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

module.exports = {
  getUsers,
  register,
  login,
  updateProfile,
  changePassword,
  deleteAccount
};
