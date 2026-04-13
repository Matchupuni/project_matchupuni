require('dotenv').config();
const express = require('express');
const path = require('path');

const userRoutes = require('./routes/userRoutes');
const postRoutes = require('./routes/postRoutes');
const uploadRoutes = require('./routes/uploadRoutes');
const favoriteRoutes = require('./routes/favoriteRoutes');
const chatRoutes = require('./routes/chatRoutes');
const reportRoutes = require('./routes/reportRoutes');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json()); // Middleware for parsing JSON requests

// Serve static files from the 'public' directory
// Now you can access files inside 'public' via: http://localhost:3000/public/filename.ext
app.use('/public', express.static(path.join(__dirname, 'public')));

// Mount routes
app.use('/users', userRoutes);
app.use('/posts', postRoutes);
app.use('/upload', uploadRoutes);
app.use('/favorites', favoriteRoutes);
app.use('/chat', chatRoutes);
app.use('/reports', reportRoutes);

app.get('/', (req, res) => {
  res.send('Hello World!');
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('🔥 [Unhandled Error]:', err.stack || err.message || err);
  
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error',
    stack: err.stack,
  });
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
