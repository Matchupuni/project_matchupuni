require('dotenv').config();
const express = require('express');
const path = require('path');

const userRoutes = require('./routes/userRoutes');
const postRoutes = require('./routes/postRoutes');
const uploadRoutes = require('./routes/uploadRoutes');
const utilsRoutes = require('./routes/utilsRoutes');

const app = express();
const port = 3000;

app.use(express.json()); // Middleware for parsing JSON requests

// Serve static files from the 'public' directory
// Now you can access files inside 'public' via: http://localhost:3000/public/filename.ext
app.use('/public', express.static(path.join(__dirname, 'public')));

// Mount routes
app.use('/users', userRoutes);
app.use('/posts', postRoutes);
app.use('/upload', uploadRoutes);
app.use('/', utilsRoutes); // To keep /generate-ids at the root level as before

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
