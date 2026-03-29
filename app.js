require('dotenv').config();
const express = require('express');
const path = require('path');
const multer = require('multer');
const { generateUUID, generateCuid2 } = require('./utils/idGenerator');
const pool = require('./db');
const app = express();
const port = 3000;

app.use(express.json()); // Middleware for parsing JSON requests

// Serve static files from the 'public' directory
// Now you can access files inside 'public' via: http://localhost:3000/public/filename.ext
app.use('/public', express.static(path.join(__dirname, 'public')));

// Set up multer for file upload
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, 'public', 'uploads'));
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

app.post('/upload', upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }
  // Return the path that can be used to access the file
  const filePath = `/public/uploads/${req.file.filename}`;
  res.json({ path: filePath, filename: req.file.filename });
});

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.get('/generate-ids', (req, res) => {
  res.json({
    uuid: generateUUID(),
    cuid2: generateCuid2()
  });
});

// GET all users
app.get('/users', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// POST a new user
app.post('/users', async (req, res) => {
  try {
    const { full_name, email, password_hash, profile_img } = req.body;
    
    // Using generateCuid2 or UUID for the id column, which requires a varchar(50)
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
});

// GET all posts (with optional tag filtering and post_type)
app.get('/posts', async (req, res) => {
  try {
    const { tag, field, post_type, search } = req.query;
    let query = `
      SELECT 
        p.*, 
        COALESCE(array_remove(array_agg(DISTINCT t.tag_name), NULL), '{}') AS tags,
        COALESCE(array_remove(array_agg(DISTINCT f.field_name), NULL), '{}') AS fields
      FROM posts p
      LEFT JOIN post_tags pt ON p.id = pt.post_id
      LEFT JOIN tags t ON pt.tag_id = t.id
      LEFT JOIN post_fields pf ON p.id = pf.post_id
      LEFT JOIN fields f ON pf.field_id = f.id
    `;
    const queryParams = [];
    const whereClauses = [];

    if (tag && tag !== 'All') {
      let tagArray = Array.isArray(tag) ? tag : [tag];
      queryParams.push(tagArray);
      whereClauses.push(`
        p.id IN (
          SELECT pt2.post_id 
          FROM post_tags pt2 
          JOIN tags t2 ON pt2.tag_id = t2.id 
          WHERE t2.tag_name = ANY($${queryParams.length}::text[])
        )
      `);
    }

    if (field && field !== 'All') {
      let fieldArray = Array.isArray(field) ? field : [field];
      queryParams.push(fieldArray);
      whereClauses.push(`
        p.id IN (
          SELECT pf2.post_id 
          FROM post_fields pf2 
          JOIN fields f2 ON pf2.field_id = f2.id 
          WHERE f2.field_name = ANY($${queryParams.length}::text[])
        )
      `);
    }

    if (post_type) {
      queryParams.push(post_type);
      whereClauses.push(`p.post_type = $${queryParams.length}`);
    }

    if (search) {
      queryParams.push(`%${search}%`);
      whereClauses.push(`(p.name ILIKE $${queryParams.length} OR p.details ILIKE $${queryParams.length} OR p.role_needed ILIKE $${queryParams.length} OR p.required_skill ILIKE $${queryParams.length})`);
    }

    if (whereClauses.length > 0) {
      query += ` WHERE ` + whereClauses.join(' AND ');
    }

    query += ' GROUP BY p.id ORDER BY p.created_at DESC';

    const result = await pool.query(query, queryParams);
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// POST a new post
app.post('/posts', async (req, res) => {
  console.log("Receiving POST /posts payload:", req.body);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const { 
      name, details, due_date, register_link, image_path, tags, fields,
      post_type, role_needed, teammates_needed, required_skill, contact
    } = req.body;
    
    // Using generateCuid2 for the id column (varchar(50))
    const id = generateCuid2(); 

    const result = await client.query(
      `INSERT INTO posts (id, name, details, due_date, register_link, image_path, post_type, role_needed, teammates_needed, required_skill, contact) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) 
       RETURNING *`,
      [id, name, details, due_date, register_link, image_path, post_type || 'activity', role_needed, teammates_needed || null, required_skill, contact]
    );
    
    const insertedPost = result.rows[0];

    // Insert tags
    if (tags && Array.isArray(tags)) {
      for (const tagName of tags) {
        let tagRes = await client.query('SELECT id FROM tags WHERE tag_name = $1', [tagName]);
        let tagId;
        if (tagRes.rows.length > 0) {
          tagId = tagRes.rows[0].id;
        } else {
          const newTagRes = await client.query('INSERT INTO tags (tag_name) VALUES ($1) RETURNING id', [tagName]);
          tagId = newTagRes.rows[0].id;
        }
        await client.query('INSERT INTO post_tags (post_id, tag_id) VALUES ($1, $2)', [id, tagId]);
      }
    }

    // Insert fields
    if (fields && Array.isArray(fields)) {
      for (const fieldName of fields) {
        let fieldRes = await client.query('SELECT id FROM fields WHERE field_name = $1', [fieldName]);
        let fieldId;
        if (fieldRes.rows.length > 0) {
          fieldId = fieldRes.rows[0].id;
        } else {
          const newFieldRes = await client.query('INSERT INTO fields (field_name) VALUES ($1) RETURNING id', [fieldName]);
          fieldId = newFieldRes.rows[0].id;
        }
        await client.query('INSERT INTO post_fields (post_id, field_id) VALUES ($1, $2)', [id, fieldId]);
      }
    }

    await client.query('COMMIT');
    res.status(201).json(insertedPost);
  } catch (error) {
    await client.query('ROLLBACK');
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  } finally {
    client.release();
  }
});

// PUT an existing post (Update Post)
app.put('/posts/:id', async (req, res) => {
  const { id } = req.params;
  console.log(`Receiving PUT /posts/${id} payload:`, req.body);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const { 
      name, details, due_date, register_link, image_path, tags, fields,
      post_type, role_needed, teammates_needed, required_skill, contact
    } = req.body;
    
    const result = await client.query(
      `UPDATE posts SET name=$1, details=$2, due_date=$3, register_link=$4, image_path=$5,
       post_type=$6, role_needed=$7, teammates_needed=$8, required_skill=$9, contact=$10
       WHERE id=$11 RETURNING *`,
      [name, details, due_date, register_link, image_path, post_type || 'activity', role_needed, teammates_needed || null, required_skill, contact, id]
    );

    if (result.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Post not found' });
    }

    const updatedPost = result.rows[0];

    // Reset tags and fields for this post
    await client.query('DELETE FROM post_tags WHERE post_id = $1', [id]);
    await client.query('DELETE FROM post_fields WHERE post_id = $1', [id]);

    // Insert new tags
    if (tags && Array.isArray(tags)) {
      for (const tagName of tags) {
        let tagRes = await client.query('SELECT id FROM tags WHERE tag_name = $1', [tagName]);
        let tagId;
        if (tagRes.rows.length > 0) {
          tagId = tagRes.rows[0].id;
        } else {
          const newTagRes = await client.query('INSERT INTO tags (tag_name) VALUES ($1) RETURNING id', [tagName]);
          tagId = newTagRes.rows[0].id;
        }
        await client.query('INSERT INTO post_tags (post_id, tag_id) VALUES ($1, $2)', [id, tagId]);
      }
    }

    // Insert new fields
    if (fields && Array.isArray(fields)) {
      for (const fieldName of fields) {
        let fieldRes = await client.query('SELECT id FROM fields WHERE field_name = $1', [fieldName]);
        let fieldId;
        if (fieldRes.rows.length > 0) {
          fieldId = fieldRes.rows[0].id;
        } else {
          const newFieldRes = await client.query('INSERT INTO fields (field_name) VALUES ($1) RETURNING id', [fieldName]);
          fieldId = newFieldRes.rows[0].id;
        }
        await client.query('INSERT INTO post_fields (post_id, field_id) VALUES ($1, $2)', [id, fieldId]);
      }
    }

    await client.query('COMMIT');
    res.status(200).json(updatedPost);
  } catch (error) {
    await client.query('ROLLBACK');
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  } finally {
    client.release();
  }
});

// DELETE bulk posts
app.delete('/posts/bulk', async (req, res) => {
  const { ids } = req.body;
  console.log("Receiving DELETE /posts/bulk payload:", req.body);
  if (!ids || !Array.isArray(ids) || ids.length === 0) {
    return res.status(400).json({ error: 'No IDs provided' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    
    // Delete relationships first
    await client.query('DELETE FROM post_tags WHERE post_id = ANY($1)', [ids]);
    await client.query('DELETE FROM post_fields WHERE post_id = ANY($1)', [ids]);
    
    // Delete posts
    const result = await client.query('DELETE FROM posts WHERE id = ANY($1) RETURNING id', [ids]);
    
    await client.query('COMMIT');
    res.status(200).json({ deleted_ids: result.rows.map(r => r.id) });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  } finally {
    client.release();
  }
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});

