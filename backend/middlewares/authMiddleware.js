const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || 'matchupuni_secret_key';

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Expecting "Bearer <token>"

  if (!token) return res.status(401).json({ error: 'Access denied, token missing' });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = user; // { id, email, full_name, iat, exp }
    next();
  });
};

module.exports = authenticateToken;
